-- =====================================================================
-- evidencia_indice.sql
-- Método del curso: consulta -> plan antes -> índice -> plan después.
-- Índice evaluado: idx_prestamos_fecha_prestamo (migración 005).
--
-- Con 22 préstamos cualquier plan es un recorrido secuencial, así que
-- se simula el historial de diez años (200.000 préstamos devueltos)
-- DENTRO de una transacción que al final se deshace: la base queda
-- exactamente como estaba.
-- =====================================================================

BEGIN;

-- Se quita el índice (si la 005 ya se aplicó) para medir el "antes".
DROP INDEX IF EXISTS idx_prestamos_fecha_prestamo;

-- Historial simulado: préstamos devueltos entre jul-2016 y jun-2026,
-- repartidos entre los ejemplares, socios y bibliotecarios existentes.
INSERT INTO prestamos (id_libro, num_ejemplar, id_socio, id_bibliotecario,
                       fecha_prestamo, fecha_devolucion_esperada, fecha_devolucion_real)
SELECT e.id_libro, e.num_ejemplar,
       1 + (g % 10), 1 + (g % 4),
       DATE '2016-07-01' + (g % 3650),
       DATE '2016-07-01' + (g % 3650) + 15,
       DATE '2016-07-01' + (g % 3650) + 10 + (g % 8)
FROM generate_series(1, 200000) AS g
JOIN LATERAL (SELECT id_libro, num_ejemplar FROM ejemplares
              ORDER BY id_libro, num_ejemplar
              OFFSET (g % 18) LIMIT 1) e ON true;

ANALYZE prestamos;

-- La consulta: ¿cuántos préstamos atendió cada bibliotecario en marzo de 2026?
-- ANTES
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF)
SELECT id_bibliotecario, COUNT(*) AS prestamos
FROM prestamos
WHERE fecha_prestamo >= DATE '2026-03-01'
  AND fecha_prestamo <  DATE '2026-04-01'
GROUP BY id_bibliotecario;

CREATE INDEX idx_prestamos_fecha_prestamo ON prestamos (fecha_prestamo);

ANALYZE prestamos;

-- DESPUÉS
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF)
SELECT id_bibliotecario, COUNT(*) AS prestamos
FROM prestamos
WHERE fecha_prestamo >= DATE '2026-03-01'
  AND fecha_prestamo <  DATE '2026-04-01'
GROUP BY id_bibliotecario;

-- Resultado de la consulta (para comprobar que el índice no cambia la respuesta).
SELECT id_bibliotecario, COUNT(*) AS prestamos
FROM prestamos
WHERE fecha_prestamo >= DATE '2026-03-01'
  AND fecha_prestamo <  DATE '2026-04-01'
GROUP BY id_bibliotecario
ORDER BY id_bibliotecario;

-- Hallazgo adicional: la consulta de préstamos activos vencidos NO necesita
-- índice propio; ya la atiende el índice único parcial de la migración 003.
EXPLAIN (ANALYZE, COSTS OFF)
SELECT id_prestamo, id_socio, fecha_devolucion_esperada
FROM prestamos
WHERE fecha_devolucion_real IS NULL
  AND fecha_devolucion_esperada < DATE '2026-10-28';

ROLLBACK;
