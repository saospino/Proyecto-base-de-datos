-- =====================================================================
-- 002_socios_y_bibliotecarios.sql
-- Corrección de la Entrega 1: especialización de SOCIO.
--   Superclase : socios       (atributos comunes a todos)
--   Subclases  : estudiantes  (programa, semestre)
--                docentes     (departamento, tipo_vinculacion)
--   Tipo       : DISJUNTA (un socio es estudiante O docente, nunca ambos)
--                y TOTAL (todo socio pertenece a una de las dos).
-- Mapeo: una tabla para la superclase y una por subclase, con la misma
-- clave primaria. tipo_socio queda como atributo discriminante.
-- =====================================================================

CREATE TABLE socios (
    id_socio              SERIAL,
    nombre                VARCHAR(150) NOT NULL,
    tipo_socio            VARCHAR(20)  NOT NULL,
    codigo_institucional  VARCHAR(20)  NOT NULL,
    CONSTRAINT pk_socios PRIMARY KEY (id_socio),
    CONSTRAINT uq_socios_codigo_institucional UNIQUE (codigo_institucional),
    -- Clave candidata auxiliar: permite que cada subclase referencie
    -- (id_socio, tipo_socio) y así garantizar la disyunción.
    CONSTRAINT uq_socios_id_tipo UNIQUE (id_socio, tipo_socio),
    CONSTRAINT ck_socios_tipo CHECK (tipo_socio IN ('estudiante', 'docente')),
    CONSTRAINT ck_socios_nombre_no_vacio CHECK (btrim(nombre) <> '')
);

CREATE TABLE estudiantes (
    id_socio    INTEGER      NOT NULL,
    tipo_socio  VARCHAR(20)  NOT NULL DEFAULT 'estudiante',
    programa    VARCHAR(100) NOT NULL,
    semestre    SMALLINT     NOT NULL,
    CONSTRAINT pk_estudiantes PRIMARY KEY (id_socio),
    -- Disyunción: la fila solo puede apuntar a un socio cuyo tipo sea 'estudiante'.
    CONSTRAINT ck_estudiantes_tipo CHECK (tipo_socio = 'estudiante'),
    -- CASCADE: el registro de estudiante no tiene sentido sin el socio.
    CONSTRAINT fk_estudiantes_socio FOREIGN KEY (id_socio, tipo_socio)
        REFERENCES socios (id_socio, tipo_socio)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_estudiantes_semestre CHECK (semestre BETWEEN 1 AND 12)
);

CREATE TABLE docentes (
    id_socio          INTEGER      NOT NULL,
    tipo_socio        VARCHAR(20)  NOT NULL DEFAULT 'docente',
    departamento      VARCHAR(100) NOT NULL,
    tipo_vinculacion  VARCHAR(20)  NOT NULL,
    CONSTRAINT pk_docentes PRIMARY KEY (id_socio),
    CONSTRAINT ck_docentes_tipo CHECK (tipo_socio = 'docente'),
    CONSTRAINT fk_docentes_socio FOREIGN KEY (id_socio, tipo_socio)
        REFERENCES socios (id_socio, tipo_socio)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_docentes_vinculacion
        CHECK (tipo_vinculacion IN ('planta', 'catedra', 'ocasional'))
);

CREATE TABLE bibliotecarios (
    id_bibliotecario  SERIAL,
    nombre            VARCHAR(150) NOT NULL,
    CONSTRAINT pk_bibliotecarios PRIMARY KEY (id_bibliotecario),
    CONSTRAINT ck_bibliotecarios_nombre_no_vacio CHECK (btrim(nombre) <> '')
);
