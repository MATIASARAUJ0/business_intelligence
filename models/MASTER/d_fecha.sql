{{ config(
    materialized = 'table',
    schema = 'MASTER',
    alias = 'd_fecha',
    post_hook = [
        "ALTER TABLE {{ this }} ADD CONSTRAINT pk_d_fecha_sk_fecha PRIMARY KEY NONCLUSTERED (sk_fecha)"
    ]
) }}

WITH numeros AS (
    SELECT TOP (DATEDIFF(DAY, '2018-01-01', '2018-05-10') + 1)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
    FROM sys.all_objects
),
fechas AS (
    SELECT DATEADD(DAY, n, CAST('2018-01-01' AS DATE)) AS fecha
    FROM numeros
)
SELECT
    ISNULL(CONVERT(INT, FORMAT(fecha, 'yyyyMMdd')), 0) AS sk_fecha,
    fecha,
    DAY(fecha) AS dia,
    MONTH(fecha) AS mes,
    YEAR(fecha) AS anio,
    ISNULL(CONVERT(INT, FORMAT(fecha, 'yyyyMM')), 0) AS sk_mes
FROM fechas;
