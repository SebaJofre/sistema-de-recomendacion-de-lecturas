# 📚SISTEMA DE RECOMENDACIÓN DE LECTURA📚

## OBJETIVO DEL PROYECTO
Optimizar el proceso de selección de lecturas mediante un modelo de priorización basado en datos históricos, calificaciones de usuarios, cantidad de páginas y editoral.

## HERRAMIENTAS UTILIZADAS
Para este proyecto se usó:
1. **Google Sheets** para la Limpieza y Extracción de Datos.
2. **PostgreSQL** para el armado de tablas y creación de consultas.
3. **Power BI** para la visualización y presentación de datos.

## ORIGEN DE LOS DATOS
El dataset utilizado en este proyecto fue obtenido de `Kaggle`: https://www.kaggle.com/datasets/jealousleopard/goodreadsbooks?resource=download

### 1. Limpieza y Extracción de Datos (**Google Sheets**).

En esta parte se procesaron los datos crudos. Se pueden consultar los datos en la carpeta `data`.

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

Las queries pueden ser consultadas en la carpeta ``sql_queries``

### ÍNDICE DEL PIPELINE
- [1. Fase 1: Definición del esquema DDL y Refactorización.](#1-fase-1-definición-del-esquema-ddl-y-refactorización)
- [2. Fase 2: Pipeline de ingesta masiva.](#2-fase-2-pipeline-de-ingesta-masiva)
- [3. Fase 3: Auditoría de Calidad y Detección de anomalías.](#3-fase-3-auditoría-de-calidad-y-detección-de-anomalías)
- [4. Fase 4: Transformación transaccional y capa de abstracción.](#4-fase-4-transformación-transaccional-y-capa-de-abstracción)

### 1. Fase 1: Definición del esquema DDL y Refactorización
### 2. Fase 2: Pipeline de ingesta masiva
### 3. Fase 3: Auditoría de Calidad y Detección de anomalías
### 4. Fase 4: Transformación transaccional y capa de abstracción



