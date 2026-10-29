-- =====================================================================
-- banco_consultas.sql
-- Cada consulta responde una pregunta real del mostrador o de la
-- coordinación de la biblioteca. Resultados verificados contra la
-- semilla con fecha de referencia 28-oct-2026.
-- =====================================================================


-- ---------------------------------------------------------------------
-- C1. [Reunión de 5 tablas]
-- ¿Qué préstamos están vencidos hoy, quién los tiene, qué libro es y
-- quién lo entregó? (para llamar al socio)
-- ---------------------------------------------------------------------
SELECT p.id_prestamo,
       s.nombre                                   AS socio,
       s.codigo_institucional,
       l.titulo,
       a.nombre                                   AS autor_principal,
       p.num_ejemplar,
       b.nombre                                   AS atendido_por,
       p.fecha_devolucion_esperada,
       CURRENT_DATE - p.fecha_devolucion_esperada AS dias_retraso
FROM prestamos p
JOIN socios s         ON s.id_socio = p.id_socio
JOIN libros l         ON l.id_libro = p.id_libro
JOIN autores a        ON a.id_autor = l.id_autor_principal
JOIN bibliotecarios b ON b.id_bibliotecario = p.id_bibliotecario
WHERE p.fecha_devolucion_real IS NULL
  AND p.fecha_devolucion_esperada < CURRENT_DATE
ORDER BY dias_retraso DESC;


-- ---------------------------------------------------------------------
-- C2. [Reunión de 4 tablas, usa la especialización de socio]
-- ¿Cuántos préstamos ha hecho cada programa académico (estudiantes) y
-- cada departamento (docentes)? Sirve para orientar las compras.
-- ---------------------------------------------------------------------
SELECT s.tipo_socio,
       COALESCE(e.programa, d.departamento) AS unidad_academica,
       COUNT(p.id_prestamo)                 AS prestamos
FROM socios s
LEFT JOIN estudiantes e ON e.id_socio = s.id_socio
LEFT JOIN docentes d    ON d.id_socio = s.id_socio
JOIN prestamos p        ON p.id_socio = s.id_socio
GROUP BY s.tipo_socio, COALESCE(e.programa, d.departamento)
ORDER BY prestamos DESC, unidad_academica;


-- ---------------------------------------------------------------------
-- C3. [Reunión externa: "los que no tienen"]
-- ¿Qué socios inscritos nunca han pedido un préstamo?
-- (campaña de promoción de la biblioteca)
-- ---------------------------------------------------------------------
SELECT s.id_socio, s.nombre, s.tipo_socio, s.codigo_institucional
FROM socios s
LEFT JOIN prestamos p ON p.id_socio = s.id_socio
WHERE p.id_prestamo IS NULL
ORDER BY s.nombre;


-- ---------------------------------------------------------------------
-- C4. [Reunión externa: "los que no tienen"]
-- ¿Qué libros del catálogo nunca se han prestado? (candidatos a no
-- volver a comprar o a mover de estante)
-- ---------------------------------------------------------------------
SELECT l.id_libro, l.titulo, a.nombre AS autor_principal
FROM libros l
JOIN autores a        ON a.id_autor = l.id_autor_principal
LEFT JOIN prestamos p ON p.id_libro = l.id_libro
WHERE p.id_prestamo IS NULL
ORDER BY l.titulo;


-- ---------------------------------------------------------------------
-- C5. [GROUP BY + HAVING]
-- ¿Qué libros se han prestado 3 veces o más? (libros más solicitados,
-- candidatos a comprar más ejemplares)
-- ---------------------------------------------------------------------
SELECT l.id_libro, l.titulo, COUNT(*) AS veces_prestado
FROM libros l
JOIN prestamos p ON p.id_libro = l.id_libro
GROUP BY l.id_libro, l.titulo
HAVING COUNT(*) >= 3
ORDER BY veces_prestado DESC, l.titulo;


-- ---------------------------------------------------------------------
-- C6. [CTE]
-- ¿Qué socios tienen multas pendientes, cuánto deben y cuántos préstamos
-- activos tienen? (no pueden recibir préstamos nuevos hasta pagar)
-- Se agrega cada tabla por separado ANTES de reunir, para no inflar la
-- suma de multas con las filas de préstamos.
-- ---------------------------------------------------------------------
WITH deuda AS (
    SELECT p.id_socio, COUNT(*) AS multas_pendientes, SUM(m.monto) AS total_adeudado
    FROM multas m
    JOIN prestamos p ON p.id_prestamo = m.id_prestamo
    WHERE m.estado = 'pendiente'
    GROUP BY p.id_socio
),
activos AS (
    SELECT id_socio, COUNT(*) AS prestamos_activos
    FROM prestamos
    WHERE fecha_devolucion_real IS NULL
    GROUP BY id_socio
)
SELECT s.nombre, s.codigo_institucional,
       d.multas_pendientes, d.total_adeudado,
       COALESCE(a.prestamos_activos, 0) AS prestamos_activos
FROM deuda d
JOIN socios s       ON s.id_socio = d.id_socio
LEFT JOIN activos a ON a.id_socio = d.id_socio
ORDER BY d.total_adeudado DESC;


-- ---------------------------------------------------------------------
-- C7. [Subconsulta]
-- ¿Qué socios piden más préstamos que el promedio de los socios que usan
-- la biblioteca? (lectores frecuentes)
-- ---------------------------------------------------------------------
SELECT s.nombre, s.tipo_socio, COUNT(*) AS prestamos
FROM socios s
JOIN prestamos p ON p.id_socio = s.id_socio
GROUP BY s.id_socio, s.nombre, s.tipo_socio
HAVING COUNT(*) > (
    SELECT AVG(n)
    FROM (SELECT COUNT(*) AS n FROM prestamos GROUP BY id_socio) AS por_socio
)
ORDER BY prestamos DESC;


-- ---------------------------------------------------------------------
-- C8. [Vista creada en 006 y consultada]
-- ¿Qué libros no tienen ningún ejemplar disponible ahora mismo?
-- (son los únicos sobre los que se acepta una reserva)
-- ---------------------------------------------------------------------
SELECT titulo, autor_principal, total_ejemplares, prestados, en_reparacion
FROM vw_disponibilidad_libros
WHERE disponibles = 0
ORDER BY titulo;


-- ---------------------------------------------------------------------
-- C9. [Agregación por mes]
-- ¿Cuánto dinero se ha recaudado por multas cada mes y por qué motivo?
-- ---------------------------------------------------------------------
SELECT to_char(date_trunc('month', fecha_pago), 'YYYY-MM') AS mes,
       motivo,
       COUNT(*)   AS multas_pagadas,
       SUM(monto) AS recaudado
FROM multas
WHERE estado = 'pagada'
GROUP BY date_trunc('month', fecha_pago), motivo
ORDER BY mes, motivo;


-- ---------------------------------------------------------------------
-- C10. [Reunión de 3 tablas + función de ventana]
-- ¿En qué orden se deben atender las reservas pendientes de cada libro?
-- (cuando vuelva un ejemplar, se avisa al primero de la fila)
-- ---------------------------------------------------------------------
SELECT l.titulo,
       ROW_NUMBER() OVER (PARTITION BY r.id_libro ORDER BY r.fecha_reserva) AS turno,
       s.nombre AS socio,
       r.fecha_reserva
FROM reservas r
JOIN libros l ON l.id_libro = r.id_libro
JOIN socios s ON s.id_socio = r.id_socio
WHERE r.estado = 'pendiente'
ORDER BY l.titulo, turno;


-- ---------------------------------------------------------------------
-- C11. [Reunión de 4 tablas con reunión externa + agregación de texto]
-- ¿Quiénes firman cada libro, en orden (autor principal y coautores)?
-- Es lo que se imprime en la ficha del catálogo. Los libros sin
-- coautores salen solo con su autor principal.
-- ---------------------------------------------------------------------
SELECT l.titulo,
       ap.nombre                                                AS autor_principal,
       COUNT(lc.id_autor)                                       AS num_coautores,
       COALESCE(string_agg(ac.nombre, ', ' ORDER BY lc.orden), '—') AS coautores
FROM libros l
JOIN autores ap               ON ap.id_autor = l.id_autor_principal
LEFT JOIN libro_coautores lc  ON lc.id_libro = l.id_libro
LEFT JOIN autores ac          ON ac.id_autor = lc.id_autor
GROUP BY l.id_libro, l.titulo, ap.nombre
ORDER BY num_coautores DESC, l.titulo;
