# 📚SISTEMA DE RECOMENDACIÓN DE LECTURA📚

## OBJETIVO DEL PROYECTO
Optimizar el proceso de selección de lecturas mediante un modelo de priorización basado en datos históricos, calificaciones de usuarios y segmentación por géneros.

## HERRAMIENTAS UTILIZADAS
Para este proyecto se usó:
1. Google Sheets para la Limpieza y Extracción de Datos.
2. PostgreSQL para el armado de tablas y creación de consultas.
3. Power BI para la visualización y presentación de datos.

## ORIGEN DE LOS DATOS
El dataset utilizado en este proyecto fue obtenido de Kaggle: https://www.kaggle.com/datasets/jealousleopard/goodreadsbooks?resource=download

### 1. Limpieza y Extracción de Datos (Google Sheets).

Tras analizar la base de datos, se han identificado diversos errores que afectan la integridad de los datos. El problema principal radica en una desalineación de columnas en ciertos registros, además de fechas con días inexistentes.

1. Se corrigen 4 registros donde el contenido de las celdas se desplazó hacia la derecha (0.035% del total de la muestra).
2. Se corrigen 2 registros que que contienen errores en la columna "publication" ya que las mismas tienen datos de fechas que no existen en el calendario (0.017% del total de la muestra)
3. Una vez corregidos los registros anteriores se analizan los campos restantes en busca de datos nulos, repetidos o vacíos:
- **IDs y ISBNs**: Una vez descartadas las filas malformadas (que generaban falsos duplicados), no se encontraron bookID o isbn13 repetidos.
- **Valores Faltantes**: No se detectaron celdas vacías o con espacios en blanco en las columnas principales (A a L), a excepción de la columna extra creada por el error de alineación.
- **Ratings**: No se encontraron calificaciones mayores a 5 o menores a 0 en los datos correctamente alineados.
- **Páginas**: No se detectaron libros con número de páginas negativo.
4. Se procede a definir los tipo de datos de cada campo:
  - bookID: TEXTO
  - title	authors: TEXTO
  - average_rating: NUMBER
  - isbn: TEXTO
  - isbn13: TEXTO
  - language_code: TEXTO
  - num_pages: NUMBER
  - ratings_count: NUMBER
  - text_reviews_count: NUMBER
  - publication_date: DATE (FORMATO: AAAA-MM-DD)
  - publisher; TEXT

  Se guarda el archivo en formato .csv para luego trabajarlo en PostgreSQL

  ### 2. ARQUITECTURA DE DATOS Y MODELOS RELACIONALES (PostgreSQL).

  
