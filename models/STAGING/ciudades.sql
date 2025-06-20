{{ config(
    materialized = 'table',
    schema = 'STAGING',
    alias = 'ciudades'
) }}

select
	cast(CityID as int) as id_ciudad,
	CityName as nombre_ciudad,
	Zipcode as codigo_zip,
	cast(CountryID as int) as id_pais
from COSTCO_DB.RAW.cities