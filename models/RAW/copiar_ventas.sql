{{ config(
    materialized='table',
    schema='RAW',
    database='COSTCO_DB',
    alias='sales'
) }}

SELECT *
FROM bi_202501.dbo.sales