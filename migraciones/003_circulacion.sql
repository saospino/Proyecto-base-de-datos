-- =====================================================================
-- 003_circulacion.sql
-- Préstamos, reservas y multas.
-- prestamos y reservas son las tablas que resuelven las relaciones
-- muchos a muchos Socio–Ejemplar y Socio–Libro respectivamente.
-- =====================================================================

CREATE TABLE prestamos (
    id_prestamo                SERIAL,
    id_libro                   INTEGER  NOT NULL,
    num_ejemplar               SMALLINT NOT NULL,
    id_socio                   INTEGER  NOT NULL,
    id_bibliotecario           INTEGER  NOT NULL,
    fecha_prestamo             DATE     NOT NULL DEFAULT CURRENT_DATE,
    fecha_devolucion_esperada  DATE     NOT NULL,
    fecha_devolucion_real      DATE,
    CONSTRAINT pk_prestamos PRIMARY KEY (id_prestamo),
    -- RESTRICT en las tres: el préstamo es historial; no se puede borrar
    -- un ejemplar, socio o bibliotecario que tenga préstamos registrados.
    CONSTRAINT fk_prestamos_ejemplar FOREIGN KEY (id_libro, num_ejemplar)
        REFERENCES ejemplares (id_libro, num_ejemplar)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_prestamos_socio FOREIGN KEY (id_socio)
        REFERENCES socios (id_socio)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_prestamos_bibliotecario FOREIGN KEY (id_bibliotecario)
        REFERENCES bibliotecarios (id_bibliotecario)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_prestamos_fecha_esperada
        CHECK (fecha_devolucion_esperada > fecha_prestamo),
    CONSTRAINT ck_prestamos_fecha_real
        CHECK (fecha_devolucion_real IS NULL OR fecha_devolucion_real >= fecha_prestamo)
);

-- Regla: un ejemplar no puede estar prestado dos veces a la vez.
-- Índice único parcial: solo cuenta los préstamos activos (sin devolución).
CREATE UNIQUE INDEX uq_prestamos_ejemplar_activo
    ON prestamos (id_libro, num_ejemplar)
    WHERE fecha_devolucion_real IS NULL;

CREATE TABLE reservas (
    id_reserva     SERIAL,
    id_libro       INTEGER     NOT NULL,
    id_socio       INTEGER     NOT NULL,
    fecha_reserva  DATE        NOT NULL DEFAULT CURRENT_DATE,
    estado         VARCHAR(25) NOT NULL DEFAULT 'pendiente',
    CONSTRAINT pk_reservas PRIMARY KEY (id_reserva),
    -- RESTRICT: no se retira del catálogo un libro con reservas registradas.
    CONSTRAINT fk_reservas_libro FOREIGN KEY (id_libro)
        REFERENCES libros (id_libro)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    -- CASCADE: una reserva es una intención; si el socio se elimina, sus
    -- reservas pierden sentido (a diferencia de los préstamos).
    CONSTRAINT fk_reservas_socio FOREIGN KEY (id_socio)
        REFERENCES socios (id_socio)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_reservas_estado
        CHECK (estado IN ('pendiente', 'disponible_para_retiro', 'cancelada', 'completada'))
);

-- Regla: un socio no puede tener dos reservas vigentes del mismo libro.
CREATE UNIQUE INDEX uq_reservas_socio_libro_vigente
    ON reservas (id_socio, id_libro)
    WHERE estado IN ('pendiente', 'disponible_para_retiro');

CREATE TABLE multas (
    id_multa          SERIAL,
    id_prestamo       INTEGER       NOT NULL,
    monto             NUMERIC(10,2) NOT NULL,
    motivo            VARCHAR(20)   NOT NULL,
    estado            VARCHAR(20)   NOT NULL DEFAULT 'pendiente',
    fecha_generacion  DATE          NOT NULL DEFAULT CURRENT_DATE,
    fecha_pago        DATE,
    CONSTRAINT pk_multas PRIMARY KEY (id_multa),
    -- RESTRICT: la multa es evidencia; el préstamo que la originó no se borra.
    CONSTRAINT fk_multas_prestamo FOREIGN KEY (id_prestamo)
        REFERENCES prestamos (id_prestamo)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    -- Un préstamo genera a lo sumo una multa por cada motivo.
    CONSTRAINT uq_multas_prestamo_motivo UNIQUE (id_prestamo, motivo),
    CONSTRAINT ck_multas_monto_positivo CHECK (monto > 0),
    CONSTRAINT ck_multas_motivo CHECK (motivo IN ('atraso', 'dano')),
    CONSTRAINT ck_multas_estado CHECK (estado IN ('pendiente', 'pagada')),
    -- Pagada <=> tiene fecha de pago; y no se paga antes de generarse.
    CONSTRAINT ck_multas_pago_coherente CHECK (
        (estado = 'pagada'    AND fecha_pago IS NOT NULL AND fecha_pago >= fecha_generacion)
     OR (estado = 'pendiente' AND fecha_pago IS NULL)
    )
);
