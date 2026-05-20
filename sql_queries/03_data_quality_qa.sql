-- ==========================================================================================
-- PASO 3: GARANTÍA DE CALIDAD DE LOS DATOS (QA) Y CONSULTAS DE AUDITORÍA
-- DESCRIPCIÓN: COMPROBACIONES DE CALIDAD DE LOS DATOS PARA GARANTIZAR LA INTEGRIDAD DE LOS
-- LOS MISMOS 
-- ==========================================================================================

-- 1. Verificación del volumen de ingesta: asegura que el volumen total de filas coincida
-- con el archivo fuente.

SELECT COUNT(*) AS null_rating_counts
FROM db_books
WHERE rating_counts IS NULL;

-- 2. Detección de valores atípicos estructurales: identifica filas potencialmente dañadas
-- (por ejemplo: cantidad de páginas negativas).

SELECT 
	MIN(num_pages) AS min_page_count,
	MAX(num_pages) AS max_page_count,
	AVG(num_pages) AS avg_page_count
FROM db_books;

-- Se determina la cantidad de registros con num_pages = 0 (Un total de 76 registros)
SELECT COUNT(*)
FROM db_books
WHERE num_pages = 0;

-- Se analiza el avg_rating de los registros con 0 páginas para ver si son promedios altos
SELECT bookid,
		title,
		avg_rating,
		num_pages
FROM db_books
WHERE num_pages = 0
ORDER BY avg_rating DESC;

-- Se calcula el promedio de todos los registros con 0 páginas (AVG = 3.925)
SELECT AVG(avg_rating)
FROM db_books
WHERE num_pages = 0;

-- Se define no eliminar los registros ya que implicarían un distorsión del análisis de datos
-- en el paso 04 se implementan las soluciones elegidas.
