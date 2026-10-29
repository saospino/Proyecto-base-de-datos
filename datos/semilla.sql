-- =====================================================================
-- semilla.sql
-- Datos ficticios pero coherentes. Se ejecuta UNA vez, después de las
-- migraciones, sobre la base recién creada (los SERIAL arrancan en 1,
-- por eso los ids de las FK se escriben directamente).
-- Las personas (socios y bibliotecarios) son inventadas; los autores y
-- títulos son obras publicadas, para que el catálogo sea realista.
-- Fecha de referencia del escenario: 28 de octubre de 2026.
-- =====================================================================

BEGIN;

-- ---------------------------------------------------------------------
-- Autores (13). Piedad Bonnett (7) no tiene libros: caso "los que no tienen".
-- Los autores 8–13 solo figuran como coautores.
-- ---------------------------------------------------------------------
INSERT INTO autores (nombre, nacionalidad) VALUES
 ('Gabriel García Márquez', 'Colombia'),        -- 1  (principal de tres libros)
 ('Isabel Allende',          'Chile'),           -- 2
 ('Abraham Silberschatz',    'Estados Unidos'),  -- 3  (principal de dos libros)
 ('Ramez Elmasri',           'Egipto'),          -- 4
 ('Laura Restrepo',          'Colombia'),        -- 5
 ('Andrew S. Tanenbaum',     'Estados Unidos'),  -- 6  (principal de dos libros)
 ('Piedad Bonnett',          'Colombia'),        -- 7  (sin libros)
 ('Henry F. Korth',          'Estados Unidos'),  -- 8  coautor
 ('S. Sudarshan',            'India'),           -- 9  coautor
 ('Shamkant B. Navathe',     'India'),           -- 10 coautor
 ('David J. Wetherall',      NULL),              -- 11 coautor (nacionalidad sin confirmar)
 ('Peter Baer Galvin',       'Estados Unidos'),  -- 12 coautor
 ('Greg Gagne',              'Estados Unidos');  -- 13 coautor

-- ---------------------------------------------------------------------
-- Libros (10). Cada uno con su autor principal.
-- ---------------------------------------------------------------------
INSERT INTO libros (id_autor_principal, titulo, genero, editorial, anio_publicacion) VALUES
 (1, 'Cien años de soledad',                        'Novela',     'Sudamericana',   1967), -- 1
 (1, 'El amor en los tiempos del cólera',           'Novela',     'Oveja Negra',    1985), -- 2
 (1, 'Crónica de una muerte anunciada',             'Novela',     'Oveja Negra',    1981), -- 3
 (2, 'La casa de los espíritus',                    'Novela',     'Plaza & Janés',  1982), -- 4
 (3, 'Fundamentos de bases de datos',               'Ingeniería', 'McGraw-Hill',    2014), -- 5
 (4, 'Fundamentos de sistemas de bases de datos',   'Ingeniería', 'Pearson',        2007), -- 6
 (5, 'Delirio',                                     'Novela',     'Alfaguara',      2004), -- 7  (nunca prestado)
 (6, 'Redes de computadoras',                       'Ingeniería', 'Pearson',        2012), -- 8
 (6, 'Sistemas operativos modernos',                'Ingeniería', 'Pearson',        2009), -- 9  (nunca prestado)
 (3, 'Fundamentos de sistemas operativos',          'Ingeniería', 'McGraw-Hill',    2006); -- 10

-- ---------------------------------------------------------------------
-- Coautores (6). Orden de firma desde 2 (el 1 es el autor principal).
-- Libros 5 y 10: dos coautores. Libros 6 y 8: uno. Las novelas: ninguno.
-- ---------------------------------------------------------------------
INSERT INTO libro_coautores (id_libro, id_autor, orden) VALUES
 (5,  8,  2),   -- Fundamentos de bases de datos: Korth
 (5,  9,  3),   --                                Sudarshan
 (6,  10, 2),   -- Fund. de sistemas de bases de datos: Navathe
 (8,  11, 2),   -- Redes de computadoras: Wetherall
 (10, 12, 2),   -- Fund. de sistemas operativos: Galvin
 (10, 13, 3);   --                               Gagne

-- ---------------------------------------------------------------------
-- Ejemplares (18). El estado 'prestado' coincide exactamente con los
-- préstamos activos de más abajo.
-- ---------------------------------------------------------------------
INSERT INTO ejemplares (id_libro, num_ejemplar, estado) VALUES
 (1, 1, 'prestado'),   (1, 2, 'disponible'), (1, 3, 'baja'),
 (2, 1, 'disponible'), (2, 2, 'disponible'),
 (3, 1, 'disponible'),
 (4, 1, 'prestado'),
 (5, 1, 'prestado'),   (5, 2, 'prestado'),   (5, 3, 'reparacion'),
 (6, 1, 'disponible'), (6, 2, 'prestado'),
 (7, 1, 'disponible'),
 (8, 1, 'prestado'),   (8, 2, 'disponible'),
 (9, 1, 'disponible'),
 (10, 1, 'disponible'), (10, 2, 'reparacion');

-- ---------------------------------------------------------------------
-- Socios (10) y su especialización: 5 estudiantes y 5 docentes.
-- Los socios 5, 8 y 10 nunca han pedido un préstamo.
-- ---------------------------------------------------------------------
INSERT INTO socios (nombre, tipo_socio, codigo_institucional) VALUES
 ('Valentina Ríos Cárdenas',   'estudiante', '20231001'),  -- 1
 ('Santiago Mejía Londoño',    'estudiante', '20221045'),  -- 2
 ('Mariana Ospina Duarte',     'estudiante', '20241012'),  -- 3
 ('Julián Castaño Restrepo',   'estudiante', '20211088'),  -- 4
 ('Daniela Correa Vélez',      'estudiante', '20251003'),  -- 5
 ('Andrés Felipe Zuluaga',     'docente',    'D-0157'),    -- 6
 ('Catalina Herrera Gómez',    'docente',    'D-0231'),    -- 7
 ('Ricardo Bermúdez Arango',   'docente',    'D-0310'),    -- 8
 ('Lucía Montoya Salazar',     'docente',    'D-0412'),    -- 9
 ('Hernán Giraldo Pérez',      'docente',    'D-0098');    -- 10

INSERT INTO estudiantes (id_socio, programa, semestre) VALUES
 (1, 'Ingeniería de Sistemas', 5),
 (2, 'Ingeniería de Sistemas', 7),
 (3, 'Derecho',                2),
 (4, 'Contaduría Pública',     9),
 (5, 'Psicología',             1);

INSERT INTO docentes (id_socio, departamento, tipo_vinculacion) VALUES
 (6,  'Ingeniería',           'planta'),
 (7,  'Ciencias Humanas',     'catedra'),
 (8,  'Ciencias Básicas',     'ocasional'),
 (9,  'Ingeniería',           'catedra'),
 (10, 'Ciencias Económicas',  'planta');

-- ---------------------------------------------------------------------
-- Bibliotecarios (5). Beatriz (5) aún no ha atendido préstamos.
-- ---------------------------------------------------------------------
INSERT INTO bibliotecarios (nombre) VALUES
 ('Gloria Patricia Arias'),   -- 1
 ('Jorge Iván Muñoz'),        -- 2
 ('Sandra Milena Toro'),      -- 3
 ('Camilo Andrés Pineda'),    -- 4
 ('Beatriz Elena Cano');      -- 5

-- ---------------------------------------------------------------------
-- Préstamos (22). Plazo estándar: 15 días.
-- 1–14 y 21–22: devueltos (historial). 15–20: activos.
-- ---------------------------------------------------------------------
INSERT INTO prestamos (id_libro, num_ejemplar, id_socio, id_bibliotecario,
                       fecha_prestamo, fecha_devolucion_esperada, fecha_devolucion_real) VALUES
 (1, 2, 1, 1, '2026-08-03', '2026-08-18', '2026-08-15'),  -- 1
 (2, 1, 2, 2, '2026-08-05', '2026-08-20', '2026-08-27'),  -- 2  7 días tarde
 (5, 1, 1, 1, '2026-08-10', '2026-08-25', '2026-08-24'),  -- 3
 (3, 1, 6, 3, '2026-08-12', '2026-08-27', '2026-08-26'),  -- 4
 (1, 1, 3, 2, '2026-08-20', '2026-09-04', '2026-09-10'),  -- 5  6 días tarde
 (6, 1, 2, 1, '2026-09-01', '2026-09-16', '2026-09-15'),  -- 6
 (5, 3, 4, 3, '2026-09-02', '2026-09-17', '2026-09-25'),  -- 7  8 días tarde + daño
 (8, 2, 7, 4, '2026-09-05', '2026-09-20', '2026-09-18'),  -- 8
 (2, 2, 1, 2, '2026-09-10', '2026-09-25', '2026-09-24'),  -- 9
 (10, 2, 6, 1, '2026-09-12', '2026-09-27', '2026-09-30'), -- 10 3 días tarde + daño
 (1, 2, 9, 4, '2026-09-20', '2026-10-05', '2026-10-03'),  -- 11
 (5, 1, 2, 3, '2026-09-26', '2026-10-11', '2026-10-09'),  -- 12
 (3, 1, 3, 1, '2026-10-01', '2026-10-16', '2026-10-14'),  -- 13
 (1, 3, 4, 2, '2026-07-15', '2026-07-30', '2026-07-28'),  -- 14 devuelto destruido -> baja
 (1, 1, 1, 1, '2026-10-06', '2026-10-21', NULL),          -- 15 activo, vencido
 (4, 1, 2, 2, '2026-10-08', '2026-10-23', NULL),          -- 16 activo, vencido
 (5, 1, 6, 3, '2026-10-15', '2026-10-30', NULL),          -- 17 activo
 (5, 2, 1, 4, '2026-10-20', '2026-11-04', NULL),          -- 18 activo
 (6, 2, 9, 1, '2026-10-22', '2026-11-06', NULL),          -- 19 activo
 (8, 1, 7, 2, '2026-10-10', '2026-10-25', NULL),          -- 20 activo, vencido
 (4, 1, 7, 1, '2026-09-01', '2026-09-16', '2026-09-14'),  -- 21
 (4, 1, 9, 3, '2026-09-15', '2026-09-30', '2026-09-29');  -- 22 retiro de la reserva 1

-- ---------------------------------------------------------------------
-- Multas (7). Tarifa de atraso: $1.000 por día.
-- El socio 4 tiene dos multas pendientes y por eso no tiene préstamos
-- nuevos; los demás pagaron antes de volver a pedir.
-- ---------------------------------------------------------------------
INSERT INTO multas (id_prestamo, monto, motivo, estado, fecha_generacion, fecha_pago) VALUES
 (2,   7000.00, 'atraso', 'pagada',    '2026-08-27', '2026-08-29'),
 (5,   6000.00, 'atraso', 'pagada',    '2026-09-10', '2026-09-12'),
 (7,   8000.00, 'atraso', 'pendiente', '2026-09-25', NULL),
 (7,  45000.00, 'dano',   'pendiente', '2026-09-25', NULL),
 (10,  3000.00, 'atraso', 'pagada',    '2026-09-30', '2026-10-02'),
 (10, 25000.00, 'dano',   'pagada',    '2026-09-30', '2026-10-02'),
 (14, 80000.00, 'dano',   'pagada',    '2026-07-28', '2026-08-05');

-- ---------------------------------------------------------------------
-- Reservas (6). Solo sobre libros sin ejemplares disponibles en la fecha
-- de la solicitud: el libro 4 tiene un único ejemplar y el libro 5 tiene
-- sus dos ejemplares útiles prestados y el tercero en reparación.
-- ---------------------------------------------------------------------
INSERT INTO reservas (id_libro, id_socio, fecha_reserva, estado) VALUES
 (4, 9,  '2026-09-05', 'completada'),  -- 1  se retiró con el préstamo 22
 (4, 8,  '2026-10-09', 'cancelada'),   -- 2
 (4, 3,  '2026-10-12', 'pendiente'),   -- 3
 (4, 5,  '2026-10-14', 'pendiente'),   -- 4
 (5, 7,  '2026-10-21', 'pendiente'),   -- 5
 (5, 10, '2026-10-22', 'pendiente');   -- 6

COMMIT;
