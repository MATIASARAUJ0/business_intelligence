{{ config(
    materialized = 'table',
    schema = 'MASTER',
    alias = 'd_ciudad',
    post_hook = [
        "ALTER TABLE {{ this }} ADD CONSTRAINT pk_d_ciudad_sk_ciudad PRIMARY KEY NONCLUSTERED (sk_ciudad)"
    ]
) }}

WITH base AS (
    SELECT
        ISNULL(id_ciudad, 0) AS id_ciudad,
        nombre_ciudad AS nbr_ciudad,
        codigo_zip
    FROM COSTCO_DB.STAGING.ciudades
),
enumeradas AS (
    SELECT
        ISNULL(ROW_NUMBER() OVER (ORDER BY codigo_zip ASC), 0) as sk_ciudad,
        *
    FROM base
)
SELECT * FROM enumeradas;
