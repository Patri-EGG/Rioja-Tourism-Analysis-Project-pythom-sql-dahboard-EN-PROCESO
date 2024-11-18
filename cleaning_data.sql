SELECT * FROM gast_residentes_espana;
SELECT * FROM gast_turistas_internacionales;
SELECT * FROM go_por_ubicacion;
SELECT * FROM mov_espanoles_por_municipio_destino;
SELECT * FROM mov_internacionales_por_pais_municipio_destino;
SELECT * FROM perfil_viajero_espanol;
SELECT * FROM top_restaurants_trip;

                           -- Limpiar Datos -- 


-- NORMALIZAR COLUMNAS A MINUSCULAS

DECLARE @sql NVARCHAR(MAX) = '';

SELECT 
    @sql = @sql + 
    'EXEC sp_rename ''' + TABLE_SCHEMA + '.' + TABLE_NAME + '.' + COLUMN_NAME + ''', ''' + LOWER(COLUMN_NAME) + ''', ''COLUMN'';' + CHAR(10)
FROM INFORMATION_SCHEMA.COLUMNS;

-- PRINT @sql; 
EXEC sp_executesql @sql; 

--REEMPLAZAR CARACTERES ESPECIALES PARA EVITAR ERRORES DE VISUALIZAVION DE SQUEMA -- 

DECLARE @tabla NVARCHAR(MAX);
DECLARE @columna NVARCHAR(MAX);
DECLARE @nuevoNombre NVARCHAR(MAX);
DECLARE @sql NVARCHAR(MAX) = '';

-- Cursor para recorrer todas las tablas
DECLARE tablas_cursor CURSOR FOR
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'; -- Solo tablas base (excluye vistas)

OPEN tablas_cursor;
FETCH NEXT FROM tablas_cursor INTO @tabla;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Cursor para recorrer todas las columnas de la tabla actual que contengan los caracteres especiales
    DECLARE columnas_cursor CURSOR FOR
    SELECT COLUMN_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = @tabla AND (COLUMN_NAME LIKE '%ñ%' OR COLUMN_NAME LIKE '%í%' OR COLUMN_NAME LIKE '%ó%');

    OPEN columnas_cursor;
    FETCH NEXT FROM columnas_cursor INTO @columna;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Generar el nuevo nombre de la columna reemplazando caracteres especiales
        SET @nuevoNombre = @columna;
        SET @nuevoNombre = REPLACE(@nuevoNombre, 'ñ', 'n');
        SET @nuevoNombre = REPLACE(@nuevoNombre, 'í', 'i');
        SET @nuevoNombre = REPLACE(@nuevoNombre, 'ó', 'o');

         -- Generar la consulta para renombrar la columna
        SET @sql = @sql + 'EXEC sp_rename ''' + @tabla + '.' + @columna + ''', ''' + @nuevoNombre + ''', ''COLUMN'';' + CHAR(13);

        FETCH NEXT FROM columnas_cursor INTO @columna;
    END;

    CLOSE columnas_cursor;
    DEALLOCATE columnas_cursor;

    FETCH NEXT FROM tablas_cursor INTO @tabla;
END;

CLOSE tablas_cursor;
DEALLOCATE tablas_cursor;

--PRINT @sql;
EXEC sp_executesql @sql;


--  REEMPLAZAR VALORES 0  A NULL EN COLUMNA RATING
ALTER TABLE top_restaurants_trip
ALTER COLUMN Rating FLOAT NULL;

UPDATE top_restaurants_trip
SET rating = NULL
WHERE rating = 0;

-- REEMPLAZAR VALORES ENTEROS A DECIMALES EN COLUMNA VALORACION

ALTER TABLE top_activities_trip
ALTER COLUMN valoracion FLOAT

UPDATE top_activities_trip
SET valoracion = CAST(valoracion AS FLOAT) / 10;






