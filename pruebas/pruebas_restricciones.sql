-- =====================================================================
-- pruebas_restricciones.sql
-- Cada sentencia DEBE ser rechazada por el servidor. Se ejecuta con
--   psql -v ON_ERROR_STOP=0 -f pruebas/pruebas_restricciones.sql
-- para ver el mensaje de cada rechazo. Ninguna deja datos en la base.
-- =====================================================================

-- P1. Prestar un ejemplar que ya está prestado (ejemplar 1 de "Cien años
--     de soledad", préstamo 15 activo).          -> uq_prestamos_ejemplar_activo
INSERT INTO prestamos (id_libro, num_ejemplar, id_socio, id_bibliotecario,
                       fecha_prestamo, fecha_devolucion_esperada)
VALUES (1, 1, 3, 1, '2026-10-28', '2026-11-12');

-- P2. Registrar como estudiante a un socio que es docente (socio 6).
--     Disyunción de la especialización.           -> fk_estudiantes_socio
INSERT INTO estudiantes (id_socio, programa, semestre)
VALUES (6, 'Ingeniería de Sistemas', 3);

-- P3. Socio con un tipo que no existe.            -> ck_socios_tipo
INSERT INTO socios (nombre, tipo_socio, codigo_institucional)
VALUES ('Tomás Arango Ruiz', 'egresado', '20199999');

-- P4. Código institucional repetido.              -> uq_socios_codigo_institucional
INSERT INTO socios (nombre, tipo_socio, codigo_institucional)
VALUES ('Sofía Arango Ruiz', 'estudiante', '20231001');

-- P5. Estado de ejemplar fuera del dominio.       -> ck_ejemplares_estado
UPDATE ejemplares SET estado = 'perdido' WHERE id_libro = 2 AND num_ejemplar = 1;

-- P6. Devolución esperada antes del préstamo.     -> ck_prestamos_fecha_esperada
INSERT INTO prestamos (id_libro, num_ejemplar, id_socio, id_bibliotecario,
                       fecha_prestamo, fecha_devolucion_esperada)
VALUES (2, 1, 3, 1, '2026-10-28', '2026-10-20');

-- P7. Multa con monto negativo.                   -> ck_multas_monto_positivo
INSERT INTO multas (id_prestamo, monto, motivo) VALUES (15, -5000, 'atraso');

-- P8. Multa marcada como pagada sin fecha de pago. -> ck_multas_pago_coherente
INSERT INTO multas (id_prestamo, monto, motivo, estado) VALUES (16, 5000, 'atraso', 'pagada');

-- P9. Segunda multa por atraso al mismo préstamo. -> uq_multas_prestamo_motivo
INSERT INTO multas (id_prestamo, monto, motivo, fecha_generacion)
VALUES (2, 7000, 'atraso', '2026-08-27');

-- P10. Segunda reserva vigente del mismo socio sobre el mismo libro.
--                                                 -> uq_reservas_socio_libro_vigente
INSERT INTO reservas (id_libro, id_socio, fecha_reserva) VALUES (4, 3, '2026-10-28');

-- P11. Borrar un autor que es autor principal de libros.
--                                                 -> fk_libros_autor_principal (RESTRICT)
DELETE FROM autores WHERE id_autor = 1;

-- P12. Borrar un socio con historial de préstamos. -> fk_prestamos_socio (RESTRICT)
DELETE FROM socios WHERE id_socio = 1;

-- P13. Préstamo de un ejemplar que no existe.     -> fk_prestamos_ejemplar
INSERT INTO prestamos (id_libro, num_ejemplar, id_socio, id_bibliotecario,
                       fecha_prestamo, fecha_devolucion_esperada)
VALUES (7, 9, 3, 1, '2026-10-28', '2026-11-12');

-- P14. Registrar dos veces al mismo coautor en un libro (Korth en el libro 5).
--                                                 -> pk_libro_coautores
INSERT INTO libro_coautores (id_libro, id_autor, orden) VALUES (5, 8, 4);

-- P15. Coautor en la posición 1, que es la del autor principal.
--                                                 -> ck_libro_coautores_orden
INSERT INTO libro_coautores (id_libro, id_autor, orden) VALUES (1, 5, 1);

-- P16. Dos coautores en la misma posición de firma (libro 5, posición 2).
--                                                 -> uq_libro_coautores_orden
INSERT INTO libro_coautores (id_libro, id_autor, orden) VALUES (5, 10, 2);

-- P17. Borrar un autor que solo es coautor (Korth). -> fk_libro_coautores_autor (RESTRICT)
DELETE FROM autores WHERE id_autor = 8;

-- ---------------------------------------------------------------------
-- Contraprueba de CASCADE (esta SÍ se acepta, dentro de una transacción
-- que se deshace): al borrar el socio 10, que no tiene préstamos, se
-- borran en cascada su fila de docentes y su reserva pendiente.
-- ---------------------------------------------------------------------
BEGIN;
SELECT 'antes' AS momento,
       (SELECT COUNT(*) FROM docentes WHERE id_socio = 10) AS fila_docente,
       (SELECT COUNT(*) FROM reservas WHERE id_socio = 10) AS reservas;
DELETE FROM socios WHERE id_socio = 10;
SELECT 'después' AS momento,
       (SELECT COUNT(*) FROM docentes WHERE id_socio = 10) AS fila_docente,
       (SELECT COUNT(*) FROM reservas WHERE id_socio = 10) AS reservas;
ROLLBACK;
