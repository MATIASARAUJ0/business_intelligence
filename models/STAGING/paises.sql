{{ config(
    materialized = 'table',
    schema = 'STAGING',
    alias = 'paises'
) }}

select
	cast(CountryID as int) as id_pais,
	CountryName as nombre_pais,
	CountryCode as codigo_pais
from COSTCO_DB.RAW.countries