{{ config(
    materialized = 'table',
    schema = 'MASTER',
    alias = 'd_producto',
    post_hook = [
        "ALTER TABLE {{ this }} ADD CONSTRAINT pk_d_producto_sk_producto PRIMARY KEY NONCLUSTERED (sk_producto)",
        "ALTER TABLE {{ this }} ADD CONSTRAINT fk_d_producto_sk_categoria_producto FOREIGN KEY (sk_categoria_producto) REFERENCES MASTER.d_categoria_producto(sk_categoria_producto)"
    ]
) }}

WITH base AS (
    SELECT
        f.id_producto,
        f.nombre_producto AS nbr_producto,
        f.precio,
        c.sk_categoria_producto,
        f.clase,
        f.resistente AS resistencia,
        f.alergico,
        CAST(f.dias_duracion AS FLOAT) AS dias_vigencia
    FROM COSTCO_DB.STAGING.productos AS f
    INNER JOIN COSTCO_DB.MASTER.d_categoria_producto AS c
        ON f.id_categoria = c.id_categoria_producto
),
enumeradas AS (
    SELECT
        ISNULL(ROW_NUMBER() OVER (ORDER BY nbr_producto), 0) AS sk_producto,
        *
    FROM base
)
SELECT * FROM enumeradas;