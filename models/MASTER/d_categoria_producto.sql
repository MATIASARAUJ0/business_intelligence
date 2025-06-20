{{ config(
    materialized = 'table',
    schema = 'MASTER',
    alias = 'd_categoria_producto',
    post_hook = [
        "ALTER TABLE {{ this }} ADD CONSTRAINT pk_d_categoria_producto_sk_categoria_producto PRIMARY KEY NONCLUSTERED (sk_categoria_producto)"
    ]
) }}

WITH base AS (
    SELECT
        id_categoria AS id_categoria_producto,
        nombre_categoria AS nbr_categoria_producto
    FROM COSTCO_DB.STAGING.categoria_productos
),
enumeradas AS (
    SELECT
        ISNULL(ROW_NUMBER() OVER (ORDER BY nbr_categoria_producto), 0) AS sk_categoria_producto,
        *
    FROM base
)
SELECT * FROM enumeradas;
