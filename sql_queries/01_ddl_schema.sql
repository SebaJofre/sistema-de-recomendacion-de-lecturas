-- ==========================================================================================
-- PASO 1: DEFINICIÓN DEL ESQUEMA DE LA BASE DE DATOS
-- DESCRIPTION: CREACION DEL ESQUEMA DE LA BASES DE DATOS Y MODIFICACIONES ESTRUCTURALES.
-- ==========================================================================================

-- 1. Create the DATABASE.
-- CREATE DATABASE books;

-- 2. CREAR LA TABLA CON RESTRICCIONES ESTRICTAS Y DEFINICIÓN DE LA PRIMARY KEY.

CREATE TABLE db_books (
    bookID INT PRIMARY KEY,
    title TEXT NOT NULL,
    authors VARCHAR(255), -- Restricción inicial
    avg_rating DECIMAL(3,2),
    isbn VARCHAR(20),
    isbn13 VARCHAR(20),
    language_code VARCHAR(10),
    num_pages INT,
    rating_counts BIGINT,
    text_review_counts INT,
    publication_date DATE,
    publisher VARCHAR(30)  -- Restricción inicial
);

-- 3. REFACTORIZACIÓN Y OPTIMIZACIÓN DE ESQUEMAS.
-- Al cargar los datos desde el formato .csv, se detecta que los campos 'authors' y 'publisher' excedían los limites de longitud.
-- Se modifica a tipo 'TEXT' para evitar la saturación de la memoria y poder cargar los datos.

ALTER TABLE db_books
ALTER COLUMN authors TYPE TEXT;

ALTER TABLE db_books
ALTER COLUMN publisher TYPE TEXT;

