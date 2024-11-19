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




----------------------------------------CONSULTAS-------------------------------------

-- MESES CON MAYOR GRADO DE OCUPACION HOTELES

WITH MaxOcupacionPorAno AS (
    SELECT 
        YEAR(fecha) AS año,          -- Extrae el año de la columna 'fecha'
        MONTH(fecha) AS mes,         -- Extrae el mes de la columna 'fecha'
        MAX(gopph_total) AS max_gopph_total,
        MAX(gopph_finde_total) AS max_gopph_finde_total
    FROM 
        go_por_ubicacion
    GROUP BY 
        YEAR(fecha), MONTH(fecha)
),
MaxMesesPorAno AS (
    SELECT 
        año, 
        mes,
        max_gopph_total,
        max_gopph_finde_total,
        ROW_NUMBER() OVER (PARTITION BY año ORDER BY max_gopph_total DESC) AS ranking
    FROM 
        MaxOcupacionPorAno
)
SELECT 
    año, 
    mes, 
    max_gopph_total, 
    max_gopph_finde_total
FROM 
    MaxMesesPorAno
WHERE 
    ranking = 1;

-- MESES CON MAYOR GRADO DE OCUPACION APARTAMENTOS

WITH MaxOcupacionPorAno AS (
    SELECT 
        YEAR(fecha) AS año,          -- Extrae el año de la columna 'fecha'
        MONTH(fecha) AS mes,         -- Extrae el mes de la columna 'fecha'
        MAX(goppa_total) AS max_goppa_total,
        MAX(goppa_finde_total) AS max_goppa_finde_total
    FROM 
        go_por_ubicacion
    GROUP BY 
        YEAR(fecha), MONTH(fecha)
),
MaxMesesPorAno AS (
    SELECT 
        año, 
        mes,
        max_goppa_total,
        max_goppa_finde_total,
        ROW_NUMBER() OVER (PARTITION BY año ORDER BY max_goppa_total DESC) AS ranking
    FROM 
        MaxOcupacionPorAno
)
SELECT 
    año, 
    mes, 
    max_goppa_total, 
    max_goppa_finde_total
FROM 
    MaxMesesPorAno
WHERE 
    ranking = 1;


-- MESES CON MAYOR GRADO DE OCUPACION TURISMO RURAL

WITH MaxOcupacionPorAno AS (
    SELECT 
        YEAR(fecha) AS año,          -- Extrae el año de la columna 'fecha'
        MONTH(fecha) AS mes,         -- Extrae el mes de la columna 'fecha'
        MAX(gopptr_total) AS max_gopptr_total,
        MAX(gopptr_finde_total) AS max_gopptr_finde_total
    FROM 
        go_por_ubicacion
    GROUP BY 
        YEAR(fecha), MONTH(fecha)
),
MaxMesesPorAno AS (
    SELECT 
        año, 
        mes,
        max_gopptr_total,
        max_gopptr_finde_total,
        ROW_NUMBER() OVER (PARTITION BY año ORDER BY max_gopptr_total DESC) AS ranking
    FROM 
        MaxOcupacionPorAno
)
SELECT 
    año, 
    mes, 
    max_gopptr_total, 
    max_gopptr_finde_total
FROM 
    MaxMesesPorAno
WHERE 
    ranking = 1;

-- MESES CON MAYOR GRADO DE OCUPACION CAMPINGS

WITH MaxOcupacionPorAno AS (
    SELECT 
        YEAR(fecha) AS año,          -- Extrae el año de la columna 'fecha'
        MONTH(fecha) AS mes,         -- Extrae el mes de la columna 'fecha'
        MAX(goppc_total) AS max_goppc_total,
        MAX(goppc_finde_total) AS max_goppc_finde_total
    FROM 
        go_por_ubicacion
    GROUP BY 
        YEAR(fecha), MONTH(fecha)
),
MaxMesesPorAno AS (
    SELECT 
        año, 
        mes,
        max_goppc_total,
        max_goppc_finde_total,
        ROW_NUMBER() OVER (PARTITION BY año ORDER BY max_goppc_total DESC) AS ranking
    FROM 
        MaxOcupacionPorAno
)
SELECT 
    año, 
    mes, 
    max_goppc_total, 
    max_goppc_finde_total
FROM 
    MaxMesesPorAno
WHERE 
    ranking = 1;


--CUALES SON LAS ACTIVIDADES MAS POPULARES Y DONDE SE ENCUENTRAN

SELECT 
    categoria,
    actividad,
    ubicacion,
    SUM(num_resenas) AS total_resenas,
    AVG(valoracion) AS valoracion_promedio
FROM 
    top_activities_trip
GROUP BY 
    categoria, actividad, ubicacion
ORDER BY 
    total_resenas DESC, 
    valoracion_promedio DESC;
