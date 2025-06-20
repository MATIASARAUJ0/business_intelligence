{{ config(
    materialized = 'table',
    schema = 'STAGING',
    alias = 'empleados'
) }}

select
	cast(EmployeeID as int) as id_empleado,
	FirstName as primer_nombre,
	MiddleInitial as inicial_segundo_nombre,
	LastName as apellido,
	cast(BirthDate as datetime2) as fecha_nacimiento,
	Gender as genero,
	cast(CityID as int) as id_ciudad,
	cast(HireDate as datetime2) as fecha_contratacion
from COSTCO_DB.RAW.employees