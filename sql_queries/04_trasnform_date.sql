-- ==========================================================================================
-- PASO 4: TRANSFORMACIÓN DE DATOS E IMPLEMENTACIÓN DE ESTRATEGIA.
-- DESCRIPCIÓN: IMPLEMENTACIÓN DE ESTRATEGIA DE REDUNDANCIA PARA LA GESTIÓN DE ANOMALÍAS 
-- (LIBROS CON 0 PÁGINAS). SE APLICAN DOS SOLUCIONES EN PARALELO.
-- ==========================================================================================

-- ESTRATEGIA 1: MUTACIÓN DE LA TABLA (Para análisis de datos en SQL)
-- Cambiar '0' por 'NULL' asegura que funciones como AVG() ó MEDIAN() no se vean sesgadas en 
-- la tabla base, manteniendo el registro para análisis de otras variables.

BEGIN TRANSACTION;

UPDATE db_books
SET num_pages = NULL
WHERE num_pages = 0;

--Verificaciónes

SELECT COUNT(*) AS registros_con_cero
FROM db_books
WHERE num_pages = 0;

SELECT COUNT(*) AS registros_con_null
FROM db_books
WHERE num_pages IS NULL;

COMMIT;

-- ESTRATEGIA 2: CAPA DE ABSTRACCIÓN MEDIANTE LA CREACIÓN DE UNA VISTA
-- Esta vista aisla por completo los registros sin datos de páginas para poder realizar
-- un reporte limpio en Power BI.

CREATE VIEW vista_db_books AS 
SELECT
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
FROM db_books
WHERE num_pages IS NOT NULL; -- Toma la transformación realizada en la Estrategia 1
