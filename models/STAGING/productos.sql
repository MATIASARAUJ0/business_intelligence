{{ config(
    materialized = 'table',
    schema = 'STAGING',
    alias = 'productos'
) }}

select
	CAST(ProductID as INt) as id_producto,
	ProductName as nombre_producto,
	CAST(Price as decimal(10,5)) as precio,
	CAST(CategoryID as INT) as id_categoria,
	Class as clase,
	CAST(ModifyDate as DATETIME2) as fecha_modificacion,
	Resistant as resistente,
	IsAllergic as alergico,
	CAST(VitalityDays as INT) as dias_duracion
from COSTCO_DB.RAW.products