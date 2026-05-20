-- ====================================================================================
-- FASE 5: NORMALIZACIÓN Y CREACIÓN DE NUEVAS TABLAS
-- Descripción: Se normaliza la base de datos para reducir la redundancia y mejorar la 
-- integridad. 
-- En lugar de una sola tabla db_books, se necesita separar la información en tablas
-- independientes:
-- Libros (Books), Autores (authors), Editoriales (publishers), Idiomas (languages)
-- ====================================================================================

-- DISEÑO DEL NUEVO ESQUEMA SQL

-- 1. Tabla de Idiomas

CREATE TABLE languages (
	language_id SERIAL PRIMARY KEY,
	language_code VARCHAR(10) UNIQUE NOT NULL
);

-- 2. Tabla de Editoriales

CREATE TABLE publishers (
	publisher_id SERIAL PRIMARY KEY,
	publisher_name VARCHAR(255) UNIQUE NOT NULL
);

-- 3. Tabla de Autores

CREATE TABLE authors (
	author_id SERIAL PRIMARY KEY,
	author_name VARCHAR(255) UNIQUE NOT NULL
);

-- 4. Tabla de Libros (sin la columna 'authors' ni el nombre de la editorial)
CREATE TABLE books (
    bookID INT PRIMARY KEY,
    title TEXT NOT NULL,
    avg_rating DECIMAL(3,2),
    isbn VARCHAR(20),
    isbn13 VARCHAR(20),
    num_pages INT,
    rating_counts BIGINT,
    text_review_counts INT,
    publication_date DATE,
    publisher_id INT REFERENCES publishers(publisher_id),
    language_id INT REFERENCES languages(language_id)
);

-- 5. Tabla Intermedia: Relaciona Libros con Autores

CREATE TABLE book_authors (
	book_id INT REFERENCES books(bookID),
	author_id INT REFERENCES authors(author_id),
	PRIMARY KEY (book_id, author_id)
);


-- PROCESO ETL (Extract, Transform, Load): Repartición de datos de bd_books
-- a las nuevas tablas normalizadas.

-- Insertar idiomas únicos

INSERT INTO languages (language_code)
SELECT DISTINCT language_code
FROM db_books;

-- Control y verificación
SELECT *
FROM languages;

-- Insertar editoriales únicas

INSERT INTO publishers (publisher_name)
SELECT DISTINCT publisher
FROM db_books;

-- Control y verificación
SELECT * 
FROM publishers;

-- CONSULTA DE LOS AUTORES POR LIBRO
SELECT DISTINCT authors
FROM db_books;
-- AL HABER REGISTROS CON GRAN CANTIDAD DE AUTORES, SE DECIDE SÓLO TOMAR EL PRIMERO
-- DE CADA REGISTRO.

-- SE INSERTA EN LA TABLA 'books' una columna para el autor
ALTER TABLE books
ADD COLUMN author_id INT REFERENCES authors(author_id);

-- EXTRAIGO SOLO EL TEXTO QUE ESTA ANTES DE LA PRIMER '/' DE LA TABLA 'authors' 
-- INSERTO LOS DATOS EN LA TABLA

INSERT INTO authors (author_name)
SELECT DISTINCT TRIM(SPLIT_PART(authors,'/',1))
FROM db_books;

-- Control y verificación
SELECT *
FROM authors;


-- INSERTO LOS DATOS A LA TABLA 'books' (Tabla Normalizada para realizar consultas)
INSERT INTO books (
    bookID, title, avg_rating, isbn, isbn13, 
    num_pages, rating_counts, text_review_counts, 
    publication_date, publisher_id, language_id, author_id
)
SELECT 
    b.bookID, b.title, b.avg_rating, b.isbn, b.isbn13, 
    b.num_pages, b.rating_counts, b.text_review_counts, 
    b.publication_date, 
    p.publisher_id, 
    l.language_id,
    a.author_id
FROM db_books b
JOIN publishers p ON b.publisher = p.publisher_name
JOIN languages l ON b.language_code = l.language_code
JOIN authors a ON a.author_name = TRIM(SPLIT_PART(b.authors, '/', 1));