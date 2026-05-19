-- ==========================================================================================
-- PASO 2: PIPELINE DE INGESTA DE DATOS
-- DESCRIPCIÓN: INGESTA MASIVA DEL DATASET DE LIBROS PREPROCESADOS EN FORMATO .csv.
-- ==========================================================================================

-- El archivo origen ha pasado por una fase previa de auditoría y limpieza en 
-- Google Sheets para garantizar que los delimitadores y encodigs no rompan la ingesta.

COPY db_books (
    bookID, 
    title, 
    authors, 
    avg_rating, 
    isbn, 
    isbn13, 
    language_code, 
    num_pages, 
    rating_counts, 
    text_review_counts, 
    publication_date, 
    publisher
)
FROM 'G:/My Drive/Data Analysis/Portfolio/Proyecto 1 - Books/Dataset/books_clean.csv'
WITH (
    FORMAT CSV, 
    HEADER true, 
    DELIMITER ',', 
    ENCODING 'UTF8'
);
