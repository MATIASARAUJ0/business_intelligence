{{ config(
    materialized = 'table',
    schema = 'STAGING',
    alias = 'clientes'
) }}


select
	cast(CustomerID as int) as id_cliente,
	FirstName as primer_nombre,
	MiddleInitial as inicial_segundo_nombre,
	LastName as apellido,
	cast(CityID as int) id_ciudad,
	Address as direccion
from COSTCO_DB.RAW.customers