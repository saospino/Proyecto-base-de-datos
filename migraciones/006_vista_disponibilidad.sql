-- =====================================================================
-- 006_vista_disponibilidad.sql
-- Vista que responde la pregunta más frecuente del mostrador:
-- "¿de este libro hay ejemplares para prestar?".
-- Los ejemplares dados de baja no cuentan en el total.
-- =====================================================================

CREATE VIEW vw_disponibilidad_libros AS
SELECT l.id_libro,
       l.titulo,
       a.nombre AS autor_principal,
       COUNT(e.num_ejemplar) FILTER (WHERE e.estado <> 'baja')       AS total_ejemplares,
       COUNT(e.num_ejemplar) FILTER (WHERE e.estado = 'disponible')  AS disponibles,
       COUNT(e.num_ejemplar) FILTER (WHERE e.estado = 'prestado')    AS prestados,
       COUNT(e.num_ejemplar) FILTER (WHERE e.estado = 'reparacion')  AS en_reparacion
FROM libros l
JOIN autores a         ON a.id_autor = l.id_autor_principal
LEFT JOIN ejemplares e ON e.id_libro = l.id_libro
GROUP BY l.id_libro, l.titulo, a.nombre;
