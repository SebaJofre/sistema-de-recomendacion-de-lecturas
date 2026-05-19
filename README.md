# 📚SISTEMA DE RECOMENDACIÓN DE LECTURA📚

## ÍNDICE DEL PROYECTO

- [OBJETIVO DEL PROYECTO](#objetivo-del-proyecto)
- [HERRAMIENTAS UTILIZADAS](#herramientas-utilizadas)
- [DESARROLLO](#desarrollo)

## OBJETIVO DEL PROYECTO
Optimizar el proceso de selección de lecturas mediante un modelo de priorización basado en datos históricos, calificaciones de usuarios, cantidad de páginas y editoral.

## HERRAMIENTAS UTILIZADAS
Para este proyecto se usó:
1. **Google Sheets** para la Limpieza y Extracción de Datos.
2. **PostgreSQL** para el armado de tablas y creación de consultas.
3. **Power BI** para la visualización y presentación de datos.

## DESARROLLO

### ORIGEN DE LOS DATOS
El dataset utilizado en este proyecto fue obtenido de `Kaggle`: https://www.kaggle.com/datasets/jealousleopard/goodreadsbooks?resource=download

### 1. Limpieza y Extracción de Datos (**Google Sheets**).

En esta parte se procesaron los datos crudos. Se pueden consultar los datos en la carpeta [data](./data)

Tras analizar la base de datos, se han identificado diversos errores que afectan la integridad de los datos. El problema principal radica en una desalineación de columnas en ciertos registros, además de fechas con días inexistentes.

1. Se corrigen 4 registros donde el contenido de las celdas se desplazó hacia la derecha (0.035% del total de la muestra).
2. Se corrigen 2 registros que que contienen errores en la columna "publication" ya que las mismas tienen datos de fechas que no existen en el calendario (0.017% del total de la muestra)
3. Una vez corregidos los registros anteriores se analizan los campos restantes en busca de datos nulos, repetidos o vacíos:
- **IDs y ISBNs**: Una vez descartadas las filas malformadas (que generaban falsos duplicados), no se encontraron bookID o isbn13 repetidos.
- **Valores Faltantes**: No se detectaron celdas vacías o con espacios en blanco en las columnas principales (A a L), a excepción de la columna extra creada por el error de alineación.
- **Ratings**: No se encontraron calificaciones mayores a 5 o menores a 0 en los datos correctamente alineados.
- **Páginas**: No se detectaron libros con número de páginas negativo.
4. Se procede a definir los tipo de datos de cada campo:
  - bookID: `TEXT`
  - title	authors: `TEXT`
  - average_rating: `NUMBER`
  - isbn: `TEXT`
  - isbn13: `TEXT`
  - language_code: `TEXT`
  - num_pages: `NUMBER`
  - ratings_count: `NUMBER`
  - text_reviews_count: `NUMBER`
  - publication_date: `DATE` (FORMATO: AAAA-MM-DD)
  - publisher; `TEXT`

  Se guarda el archivo en formato `.csv` para luego trabajarlo en PostgreSQL

  ### 2. ARQUITECTURA, INGESTA Y GOBERNANZA DE DATOS (**PostgreSQL**).

Se realiza el registro del backend de datos para el proyecto. Se detalla el diseño del esquema, los errores críticos de infraestructura detectados durante la ingesta, las auditorías de calidad de datos (QA) y las estrategias transaccionales aplicadas para garantizar la fidelidad de los reportes.

Las queries pueden ser consultadas en la carpeta [sql_queries](./sql_queries)

### ÍNDICE DEL PIPELINE
- [1. Fase 1: Definición del esquema DDL y Refactorización.](#1-fase-1-definición-del-esquema-ddl-y-refactorización)
- [2. Fase 2: Pipeline de ingesta masiva.](#2-fase-2-pipeline-de-ingesta-masiva)
- [3. Fase 3: Auditoría de Calidad y Detección de anomalías.](#3-fase-3-auditoría-de-calidad-y-detección-de-anomalías)
- [4. Fase 4: Transformación transaccional y capa de abstracción.](#4-fase-4-transformación-transaccional-y-capa-de-abstracción)

### 1. Fase 1: Definición del esquema DDL y Refactorización
Se comienza esta fase con la creación del database `books`. Luego, se procede a la creación de la tabla `db_books`, asignando las restricciones correspondientes a cada campo.
Al definir la estructura inicial, se establecieron restricciones estándar como `VARCHAR(255)` y `VARCHAR(30)` para los campos `authors` y `publisher` respectivamente, basados en una primera lectura preliminar

*Error:* Durante las importaciones del dataset, el pipeline colapsó debido al desbordamiento de longitud de caracteres. El dataset contenía listas extensas de coautores y nombres de editoriales complejas que superaban los límites previstos.

*Solución:* Se aplica una reingeniería de esquema mendiante la sentencia `ALTER TABLE`, modificando los campos a tipo `TEXT`. Esto elima el límite arbitrario de caracteres, optimiza la gestión de almacenamiento dinámico de PostgreSQL y blinda el pipeline contra futuras cargas de datos variables.

```sql
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
```


### 2. Fase 2: Pipeline de ingesta masiva

Luego del arreglo del error mencionado en la fase 1, se procede a la carga del dataset.

Para la carga del conjunto de datos preprocesado en Google Sheets, se optó por una estrategia de carga masiva integrada (`Bulk Load`) aprovechando la arquitectura local del servidor de base de datos. 

Al encontrarse el archivo `.csv` limpio y el motor PostgreSQL en el mismo entorno de desarrollo local, el uso del comando nativo `COPY` representa la solución óptima y de mayor velocidad de procesamiento, evitando la sobrecarga de transferencias por red o inserciones línea por línea (`INSERT INTO`)

```sql
-- ==========================================================================================
-- PASO 2: PIPELINE DE INGESTA DE DATOS
-- DESCRIPTION: INGESTA MASIVA DEL DATASET DE LIBROS PREPROCESADOS EN FORMATO .csv.
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

```
### 3. Fase 3: Auditoría de Calidad y Detección de anomalías

Se procede a realizar una auditoría de calidad de la base de datos para determinar si la misma presenta errores y para actuar en caso afirmativo. Esto permite garantizar la calidad de los datos importados.

```sql
-- ==========================================================================================
-- PASO 2: GARANTÍA DE CALIDAD DE LOS DATOS (QA) Y CONSULTAS DE AUDITORÍA
-- DESCRIPTION: COMPROBACIONES DE CALIDAD DE LOS DATOS PARA GARANTIZAR LA INTEGRIDAD DE LOS
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
```
Como detalla la consulta sql, se encontraron un total de 76 registros con el campo `num_pages` igual a 0. Al ser un volumen representativo (0.68% del total de la muestra de datos), eliminar estos registros distorsionaría el análisis de datos posterior, por lo que, se decide implementar otra solución. La misma se explica en la siguiente fase (Fase 4).

### 4. Fase 4: Transformación transaccional y capa de abstracción

Se decide implementar dos tipos de soluciones para gestionar la anomalía en el campo `num_pages` (libros con 0 páginas).

La primera de ellas consiste en realizar una transformación de datos

```sql
-- ==========================================================================================
-- PASO 4: TRANSFORMACIÓN DE DATOS E IMPLEMENTACIÓN DE ESTRATEGIA.
-- DESCRIPTION: IMPLEMENTACIÓN DE ESTRATEGIA DE REDUNDANCIA PARA LA GESTIÓN DE ANOMALÍAS 
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
```
Se realiza una verificación final de la solución implementada para asegurarse que los datos coinciden. Ambas queries devuelven los resultados esperados:
![Primera comprobacion](G:\My Drive\Data Analysis\Portfolio\Proyecto 1 -  Books\SQL\query_1.jpg)

La segunda solución consiste en la creación de una `vista` que aisla por completo los registros sin datos (`null`). Esto permite tomar esta base de datos para poder realizar reportes limpios.

```sql
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
```
Nota: Ambas soluciones permiten realizar análisis de datos mas confiables.


