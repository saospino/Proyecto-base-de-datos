-- =====================================================================
-- 001_catalogo.sql
-- Catálogo: autores, libros, coautorías y ejemplares físicos.
-- Regla de negocio: todo libro tiene exactamente UN autor principal
-- (libros.id_autor_principal NOT NULL) y puede tener cero o más
-- coautores. La relación muchos a muchos Libro–Autor de los coautores
-- se resuelve con la tabla intermedia libro_coautores.
-- =====================================================================

CREATE TABLE autores (
    id_autor      SERIAL,
    nombre        VARCHAR(150) NOT NULL,
    nacionalidad  VARCHAR(60),
    CONSTRAINT pk_autores PRIMARY KEY (id_autor),
    CONSTRAINT ck_autores_nombre_no_vacio CHECK (btrim(nombre) <> '')
);

CREATE TABLE libros (
    id_libro          SERIAL,
    id_autor_principal  INTEGER      NOT NULL,
    titulo              VARCHAR(200) NOT NULL,
    genero              VARCHAR(60),
    editorial           VARCHAR(100),
    anio_publicacion    SMALLINT,
    CONSTRAINT pk_libros PRIMARY KEY (id_libro),
    -- RESTRICT: no se puede borrar un autor que todavía es autor principal
    -- de libros del catálogo; primero hay que reasignar o retirar esos libros.
    CONSTRAINT fk_libros_autor_principal FOREIGN KEY (id_autor_principal)
        REFERENCES autores (id_autor)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_libros_titulo_no_vacio CHECK (btrim(titulo) <> ''),
    -- 1450: imprenta de Gutenberg; 2100: tope para descartar errores de digitación.
    CONSTRAINT ck_libros_anio_valido CHECK (anio_publicacion BETWEEN 1450 AND 2100)
);

-- Coautores: tabla intermedia de la relación muchos a muchos Libro–Autor.
-- El autor principal NO se repite aquí: ya está en libros.
CREATE TABLE libro_coautores (
    id_libro  INTEGER  NOT NULL,
    id_autor  INTEGER  NOT NULL,
    orden     SMALLINT NOT NULL,
    CONSTRAINT pk_libro_coautores PRIMARY KEY (id_libro, id_autor),
    -- CASCADE: la coautoría no existe sin el libro.
    CONSTRAINT fk_libro_coautores_libro FOREIGN KEY (id_libro)
        REFERENCES libros (id_libro)
        ON DELETE CASCADE ON UPDATE CASCADE,
    -- RESTRICT: no se borra un autor que figura como coautor de un libro.
    CONSTRAINT fk_libro_coautores_autor FOREIGN KEY (id_autor)
        REFERENCES autores (id_autor)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    -- Orden de firma en la portada: 1 es siempre el autor principal,
    -- así que los coautores van del 2 en adelante y sin repetir posición.
    CONSTRAINT ck_libro_coautores_orden CHECK (orden >= 2),
    CONSTRAINT uq_libro_coautores_orden UNIQUE (id_libro, orden)
);

-- Entidad débil: un ejemplar se identifica por su libro + consecutivo.
CREATE TABLE ejemplares (
    id_libro      INTEGER     NOT NULL,
    num_ejemplar  SMALLINT    NOT NULL,
    estado        VARCHAR(20) NOT NULL DEFAULT 'disponible',
    CONSTRAINT pk_ejemplares PRIMARY KEY (id_libro, num_ejemplar),
    -- CASCADE: el ejemplar no existe sin su libro. Si el ejemplar ya tiene
    -- préstamos, la FK RESTRICT de prestamos impide el borrado de todos modos.
    CONSTRAINT fk_ejemplares_libro FOREIGN KEY (id_libro)
        REFERENCES libros (id_libro)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_ejemplares_num_positivo CHECK (num_ejemplar > 0),
    CONSTRAINT ck_ejemplares_estado
        CHECK (estado IN ('disponible', 'prestado', 'reparacion', 'baja'))
);
