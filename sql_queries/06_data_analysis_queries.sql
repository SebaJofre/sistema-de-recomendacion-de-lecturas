-- ==========================================================================================
-- FASE 6: CONSULTAS PARA EL ANÁLISIS DE DATOS
-- DESCRIPCIÓN: SE PRESENTAN LAS CONSULTAS QUE NOS PERMITEN REALIZAR UNA ANÁLISIS DE DATOS
-- RESPECTO A LA BASE DE DATOS.
-- ==========================================================================================

-- 1. ¿Cuáles son los 10 libros con mejor puntuación de toda la plataforma,
-- mostrando el nombre del autor, editorial, puntuación, cantidad de páginas y cantidad de puntuaciones?

SELECT b.title AS titulo,
		a.author_name AS autor,
		p.publisher_name AS editorial,
		b.avg_rating AS puntuacion,
		b.rating_counts AS cantidad_de_puntuaciones
FROM books b
INNER JOIN authors a -- Unimos a la tabla authors
ON b.author_id = a.author_id
INNER JOIN publishers p -- Unimos a la tabla publishers
ON b.publisher_id = p.publisher_id
ORDER BY avg_rating DESC, b.rating_counts DESC -- Se orden por puntuación y por cantidad de puntuaciones
LIMIT 10; -- Se toman los 5 primeros registros

-- El resultado devuelto es erróneo porque no se esta teniendo en cuenta la relación
-- entre los campos 'avg_rating' y 'rating_counts'
-- (No se puede tomar un libro con una puntuación de 5 si sólo recibió una puntuación o reseña)
-- Se debe adoptar un criterio de análisis para definir a partir de qué cantidad de puntuaciones realizadas
-- esta bien considerar la clasificación de un libro

-- =================================================================================
-- QUERIES PARA CÁLCULOS ESTADÍSTICOS (FUNCIONES DE AGREGACIÓN ORDENADA)
-- =================================================================================

-- QUERY 1: CÁLCULO DEL MIN, MAX Y AVG DE rating_counts 

SELECT 
	-- 1. Mínima puntuación
		MIN(avg_rating) AS min_puntuacion,
	-- 2. Máxima puntuación
		MAX(avg_rating) AS max_puntuacion,
FROM books;

-- Comprobamos que no hay valores menores a 0 y mayores a 5

-- QUERY 2: CÁLCULO DEL PROMEDIO, MEDIANA Y PERCENTIL 75.

SELECT 
    -- 1. El Promedio (Sensible a valores extremos)
    ROUND(AVG(rating_counts), 2) AS promedio_votos,
    
    -- 2. La Mediana (El valor real del centro: 50% de los libros tienen más que esto, 50% tienen menos)
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY rating_counts) AS mediana_votos,
    
    -- 3. Percentil 75 (El top 25% de los libros con más votos)
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY rating_counts) AS percentil_75_votos
FROM books
WHERE rating_counts > 0; -- Excluimos los que no tienen votos para no desvirtuar

-- Para poder analizar la puntuación de los libros de manera mas eficaz podemos trabajar con la MEDIANA (766) ó con
-- el PERCENTIL 75 (5061.5).
-- Se decide trabajar con el Percentil 75.


-- 1. ¿Cuáles son los 10 libros con mejor puntuación de toda la plataforma,
-- mostrando el nombre del autor, editorial, puntuación, cantidad de páginas y cantidad de puntuaciones?
SELECT b.title AS titulo,
		a.author_name AS autor,
		p.publisher_name AS editorial,
		b.avg_rating AS puntuacion,
		b.num_pages AS cant_de_paginas,
		b.rating_counts AS cant_de_puntuaciones
FROM books b
INNER JOIN authors a  -- Unimos a la tabla authors para traer el nombre del autor
ON b.author_id = a.author_id 
INNER JOIN publishers p -- Unimos a la tabla publisher para traer el nombre de la editorial
ON b.publisher_id = p.publisher_id
WHERE b.rating_counts >= 5061 --Tomamos el percentil 75 
ORDER BY b.avg_rating DESC
LIMIT 10;

-- 2.¿Quiénes son los 10 autores con mejor promedio de calificación (considerando solo su libro más exitoso)?

SELECT a.author_name AS autor,
		ROUND(AVG(b.avg_rating),2) AS promedio_puntuacion,
		COUNT(b.bookid) AS cantidad_de_libros_top
FROM books b
INNER JOIN authors a
ON b.author_id = a.author_id
WHERE rating_counts >= 5061 --Tomamos el percentil 75
GROUP BY a.author_name
HAVING COUNT(b.bookid) >=2 -- Filtramos autores que tengan al menos 2 libros en este nivel
ORDER BY promedio_puntuacion DESC, SUM(b.rating_counts) DESC
LIMIT 10;

-- 3.¿Qué libros tienen una puntuación excelente (mayor a 4.3) pero son poco conocidos (tienen entre 500 y 2,000 votos)?

SELECT a.author_name AS autor,
		ROUND(AVG(b.avg_rating),2) AS promedio_puntuacion,
		COUNT(b.bookid) AS cantidad_de_libros_top
FROM books b
INNER JOIN authors a
ON b.author_id = a.author_id
WHERE avg_rating >= 4.3 AND rating_counts BETWEEN 500 AND 2000 --Condición de filtrado 
GROUP BY a.author_name
HAVING COUNT(b.bookid) >=2 -- Filtramos autores que tengan al menos 2 libros en este nivel
ORDER BY promedio_puntuacion DESC, SUM(b.rating_counts) DESC
LIMIT 10;

-- 4. ¿Qué editoriales han publicado la mayor cantidad de libros con una calificación superior a 4.0?

SELECT p.publisher_name AS editorial,
		COUNT(bookid) AS total_libros_top, --Cuenta cuántas filas (libros) se agruparon por editorial
		ROUND(AVG(b.avg_rating),2) AS nota_promedio_editorial --Calcula el promedio de notas del grupo y lo redondea a 2 decimales
FROM books b
INNER JOIN publishers p
	ON b.publisher_id = p.publisher_id
WHERE b.avg_rating >= 4 --Solo entran al cálculo los libros que ya son buenos (+4 estrellas)
GROUP BY p.publisher_name
HAVING COUNT(bookid) >= 10 --Descarta las editoriales que tienen menos de 10 libros en el grupo
ORDER BY nota_promedio_editorial DESC
LIMIT 10;

-- CONSULTA PARA FILTRAR POR EDITORIAL Y POR PUNTUACIÓN
SELECT b.title AS titulo,
		b.avg_rating AS puntuacion,
		a.author_name AS autor,
		p.publisher_name AS editorial
FROM books b
INNER JOIN publishers p
		ON b.publisher_id = p.publisher_id
INNER JOIN authors a
		ON b.author_id = a.author_id
WHERE p.publisher_name = 'Andrews McMeel Publishing' AND avg_rating >= 4;