-- =====================================================================
-- 004_indices_claves_foraneas.sql
-- PostgreSQL no indexa automáticamente las claves foráneas.
-- Se indexan las que participan en las reuniones frecuentes.
-- No hace falta índice para:
--   ejemplares(id_libro)    -> es el prefijo de pk_ejemplares
--   multas(id_prestamo)     -> es el prefijo de uq_multas_prestamo_motivo
--   libro_coautores(id_libro) -> es el prefijo de pk_libro_coautores
--   estudiantes/docentes    -> su PK ya es id_socio
-- =====================================================================

CREATE INDEX idx_libros_autor_principal ON libros          (id_autor_principal);
CREATE INDEX idx_libro_coautores_autor  ON libro_coautores (id_autor);
CREATE INDEX idx_prestamos_ejemplar     ON prestamos       (id_libro, num_ejemplar);
CREATE INDEX idx_prestamos_socio        ON prestamos       (id_socio);
CREATE INDEX idx_prestamos_bibliotecario ON prestamos      (id_bibliotecario);
CREATE INDEX idx_reservas_libro         ON reservas        (id_libro);
CREATE INDEX idx_reservas_socio         ON reservas        (id_socio);
