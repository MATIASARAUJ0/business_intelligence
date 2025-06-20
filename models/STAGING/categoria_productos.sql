{{ config(
    materialized = 'table',
    schema = 'STAGING',
    alias = 'categoria_productos'
) }}

select
	cast(CategoryID as int) as id_categoria,
	CategoryName as nombre_categoria
from COSTCO_DB.RAW.categories