{{ config(
    materialized = 'table',
    schema = 'STAGING',
    alias = 'ventas'
) }}

SELECT
    CAST(SalesID AS INT) AS id_venta,
    CAST(SalesPersonID AS INT) AS id_vendedor,
    CAST(CustomerID AS INT) AS id_cliente,
    CAST(ProductID AS INT) AS id_producto,
    CAST(Quantity AS INT) AS cantidad,
    CAST(Discount AS DECIMAL(10, 2)) AS descuento,
    CAST(TotalPrice AS DECIMAL(10, 2)) AS precio_total,
    CAST(SalesDate AS DATETIME2) AS fecha_venta,
    TransactionNumber AS numero_transaccion
FROM COSTCO_DB.RAW.sales
WHERE SalesDate <> ''
    AND ISDATE(SalesDate) = 1;
