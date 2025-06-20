{{ config(
    materialized = 'table',
    schema = 'MASTER',
    alias = 'f_resumen_mensual_cliente',
    post_hook = [
        "ALTER TABLE {{ this }} ADD CONSTRAINT pk_f_resumen_mensual_cliente PRIMARY KEY NONCLUSTERED (sk_cliente, sk_mes)",
        "ALTER TABLE {{ this }} ADD CONSTRAINT fk_f_resumen_mensual_cliente_sk_cliente FOREIGN KEY (sk_cliente) REFERENCES MASTER.d_cliente(sk_cliente)",
        "ALTER TABLE {{ this }} ADD CONSTRAINT fk_f_resumen_mensual_cliente_sk_mes FOREIGN KEY (sk_mes) REFERENCES MASTER.d_mes(sk_mes)",
        "ALTER TABLE {{ this }} ADD CONSTRAINT fk_f_resumen_mensual_cliente_sk_producto_mas_comprado FOREIGN KEY (sk_producto_mas_comprado) REFERENCES MASTER.d_producto(sk_producto)",
        "ALTER TABLE {{ this }} ADD CONSTRAINT fk_f_resumen_mensual_cliente_sk_categoria_producto_mas_comprado FOREIGN KEY (sk_categoria_producto_mas_comprado) REFERENCES MASTER.d_categoria_producto(sk_categoria_producto)"
    ]
) }}

WITH ventas AS (
    SELECT
        c.sk_cliente,
        CAST(s.fecha_venta AS DATE) AS fecha_venta,
        f.sk_mes,
        p.sk_producto,
        p.sk_categoria_producto,
        s.cantidad,
        p.precio,
        s.descuento AS pctj_descuento
    FROM COSTCO_DB.STAGING.ventas AS s
    INNER JOIN COSTCO_DB.MASTER.d_cliente AS c
        ON s.id_cliente = c.id_cliente
    INNER JOIN COSTCO_DB.MASTER.d_producto AS p
        ON s.id_producto = p.id_producto
    INNER JOIN COSTCO_DB.MASTER.d_fecha AS f
        ON CAST(s.fecha_venta AS DATE) = f.fecha
),
ventas_mes AS (
    SELECT
        sk_cliente,
        sk_mes,
        COUNT(DISTINCT fecha_venta) AS dias_activos,
        COUNT(*) AS total_compras,
        SUM(precio * (1.0 - pctj_descuento) * cantidad) AS total_gastado,
        SUM(precio * cantidad) AS total_gastado_sin_dscto,
        COUNT(DISTINCT sk_producto) AS cantidad_productos_diferentes_comprados,
        COUNT(DISTINCT sk_categoria_producto) AS cantidad_categorias_diferentes_comprados
    FROM ventas
    GROUP BY sk_cliente, sk_mes
),
ventas_prod AS (
    SELECT
        sk_cliente,
        sk_mes,
        sk_producto,
        SUM(cantidad) AS cantidad_producto_mas_comprado,
        ROW_NUMBER() OVER (PARTITION BY sk_cliente, sk_mes ORDER BY SUM(cantidad) DESC) AS rn_prod
    FROM ventas
    GROUP BY sk_cliente, sk_mes, sk_producto
),
ventas_cat AS (
    SELECT
        sk_cliente,
        sk_mes,
        sk_categoria_producto,
        SUM(cantidad) AS cantidad_categoria_producto_mas_comprado,
        ROW_NUMBER() OVER (PARTITION BY sk_cliente, sk_mes ORDER BY SUM(cantidad) DESC) AS rn_cat
    FROM ventas
    GROUP BY sk_cliente, sk_mes, sk_categoria_producto
)
SELECT
    m.sk_cliente,
    m.sk_mes,
    m.dias_activos,
    m.total_compras,
    m.total_gastado,
    m.total_gastado_sin_dscto,
    m.cantidad_productos_diferentes_comprados,
    m.cantidad_categorias_diferentes_comprados,
    ISNULL(p.sk_producto, 0) AS sk_producto_mas_comprado,
    p.cantidad_producto_mas_comprado,
    ISNULL(c.sk_categoria_producto, 0) AS sk_categoria_producto_mas_comprado,
    c.cantidad_categoria_producto_mas_comprado,
    CAST(m.total_gastado AS FLOAT) / NULLIF(m.dias_activos, 0) AS gasto_promedio_compra
FROM ventas_mes AS m
INNER JOIN ventas_prod AS p
    ON m.sk_cliente = p.sk_cliente
    AND m.sk_mes = p.sk_mes
    AND rn_prod = 1
INNER JOIN ventas_cat AS c
    ON m.sk_cliente = c.sk_cliente
    AND m.sk_mes = c.sk_mes
    AND rn_cat = 1;
