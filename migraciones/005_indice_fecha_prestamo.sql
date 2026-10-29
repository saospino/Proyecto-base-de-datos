-- =====================================================================
-- 005_indice_fecha_prestamo.sql
-- Índice justificado con EXPLAIN ANALYZE (ver indices/evidencia_indice.sql).
-- Los reportes de coordinación filtran préstamos por rango de fechas
-- (un mes); con el historial de varios años, sin índice se recorre
-- toda la tabla.
-- =====================================================================

CREATE INDEX idx_prestamos_fecha_prestamo
    ON prestamos (fecha_prestamo);
