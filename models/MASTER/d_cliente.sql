{{ config(
    materialized = 'table',
    schema = 'MASTER',
    alias = 'd_cliente',
    post_hook = [
        "ALTER TABLE {{ this }} ADD CONSTRAINT pk_d_cliente_sk_cliente PRIMARY KEY NONCLUSTERED (sk_cliente)",
        "ALTER TABLE {{ this }} ADD CONSTRAINT fk_d_cliente_sk_ciudad FOREIGN KEY (sk_ciudad) REFERENCES MASTER.d_ciudad(sk_ciudad)"
    ]
) }}

WITH clientes_base AS (
    SELECT
        f.id_cliente,
        f.primer_nombre AS primer_nbr,
        CASE
            WHEN f.inicial_segundo_nombre = 'NULL' THEN NULL
            ELSE f.inicial_segundo_nombre
        END AS inicial_segundo_nbr,
        f.apellido AS ape_paterno,
        c.sk_ciudad,
        f.direccion
    FROM COSTCO_DB.STAGING.clientes AS f
    INNER JOIN COSTCO_DB.MASTER.d_ciudad AS c
        ON f.id_ciudad = c.id_ciudad
),
clientes_final AS (
    SELECT
        ISNULL(ROW_NUMBER() OVER (ORDER BY ape_paterno ASC), 0) as sk_cliente,
        *
    FROM clientes_base
)
SELECT * FROM clientes_final;
