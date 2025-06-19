CREATE DATABASE COSTCO_DB;

USE COSTCO_DB;

CREATE SCHEMA DWH AUTHORIZATION dbo;

CREATE PROCEDURE SP_drop_dim_tables
AS
BEGIN
	ALTER TABLE DWH.f_resumen_mensual_cliente DROP CONSTRAINT fk_f_resumen_mensual_cliente_sk_mes;
	ALTER TABLE DWH.d_cliente DROP CONSTRAINT fk_d_cliente_sk_ciudad;
	ALTER TABLE DWH.f_resumen_mensual_cliente DROP CONSTRAINT fk_f_resumen_mensual_cliente_sk_cliente;
	ALTER TABLE DWH.d_producto DROP CONSTRAINT fk_d_producto_sk_categoria_producto;
	ALTER TABLE DWH.f_resumen_mensual_cliente DROP CONSTRAINT fk_f_resumen_mensual_cliente_sk_categoria_producto_mas_comprado;
	ALTER TABLE DWH.f_resumen_mensual_cliente DROP CONSTRAINT fk_f_resumen_mensual_cliente_sk_producto_mas_comprado;
	ALTER TABLE DWH.d_fecha DROP CONSTRAINT fk_d_fecha_sk_mes

	DROP TABLE DWH.d_mes;
	DROP TABLE DWH.d_fecha;
	DROP TABLE DWH.d_ciudad;
	DROP TABLE DWH.d_cliente;
	DROP TABLE DWH.d_categoria_producto;
	DROP TABLE DWH.d_producto;
	DROP TABLE DWH.f_resumen_mensual_cliente;
END;

EXEC SP_drop_dim_tables;

CREATE PROCEDURE SP_create_dim_tables
AS
BEGIN
	CREATE TABLE DWH.d_fecha (
		sk_fecha INT NOT NULL,
		fecha DATE NOT NULL,
		dia TINYINT NOT NULL,
		mes TINYINT NOT NULL,
		anio SMALLINT NOT NULL,
		sk_mes INT NOT NULL,
		CONSTRAINT [pk_d_fecha_sk_fecha] PRIMARY KEY NONCLUSTERED (sk_fecha)
	);

	CREATE TABLE DWH.d_mes (
		sk_mes INT NOT NULL,
		nbr_mes VARCHAR(30) NOT NULL,
		nro_mes TINYINT NOT NULL,
		cant_dias TINYINT NOT NULL,
		anio SMALLINT NOT NULL,
		CONSTRAINT [pk_d_mes_sk_mes] PRIMARY KEY NONCLUSTERED (sk_mes)
	);

	CREATE TABLE DWH.d_ciudad (
		sk_ciudad INT IDENTITY(1,1),
		id_ciudad INT NOT NULL,
		nbr_ciudad VARCHAR(30) NOT NULL,
		codigo_zip VARCHAR(30) NOT NULL,
		CONSTRAINT [pk_d_ciudad_sk_ciudad] PRIMARY KEY CLUSTERED (sk_ciudad)
	);

	CREATE TABLE DWH.d_cliente (
		sk_cliente INT IDENTITY(1,1),
		id_cliente INT NOT NULL,
		primer_nbr VARCHAR(30) NOT NULL,
		inicial_segundo_nbr VARCHAR(1),
		ape_paterno VARCHAR(30) NOT NULL,
		sk_ciudad INT NOT NULL,
		direccion VARCHAR(120) NOT NULL,
		CONSTRAINT [pk_d_cliente_sk_cliente] PRIMARY KEY CLUSTERED (sk_cliente),
		CONSTRAINT [fk_d_cliente_sk_ciudad] FOREIGN KEY (sk_ciudad) REFERENCES DWH.d_ciudad(sk_ciudad)
	);

	CREATE TABLE DWH.d_categoria_producto (
		sk_categoria_producto INT IDENTITY(1,1),
		id_categoria_producto INT NOT NULL,
		nbr_categoria_producto VARCHAR(50) NOT NULL,
		CONSTRAINT [pk_d_categoria_producto_sk_categoria_producto] PRIMARY KEY CLUSTERED (sk_categoria_producto)
	);

	CREATE TABLE DWH.d_producto (
		sk_producto INT IDENTITY(1,1),
		id_producto INT NOT NULL,
		nbr_producto VARCHAR(120) NOT NULL,
		precio DECIMAL(10,2) NOT NULL,
		sk_categoria_producto INT NOT NULL,
		clase VARCHAR(30) NOT NULL,
		resistencia VARCHAR(30) NOT NULL,
		alergico VARCHAR(30) NOT NULL,
		dias_vigencia SMALLINT NOT NULL,
		CONSTRAINT [pk_d_producto_sk_producto] PRIMARY KEY CLUSTERED (sk_producto),
		CONSTRAINT [fk_d_producto_sk_categoria_producto] FOREIGN KEY (sk_categoria_producto) REFERENCES DWH.d_categoria_producto(sk_categoria_producto)
	);

	CREATE TABLE DWH.f_resumen_mensual_cliente (
		sk_cliente INT NOT NULL,
		sk_mes INT NOT NULL,
		dias_activos INT NOT NULL,
		total_compras INT NOT NULL,
		total_gastado DECIMAL(20,2) NOT NULL,
		total_gastado_sin_dscto DECIMAL(20,2) NOT NULL,
		cantidad_productos_diferentes_comprados INT NOT NULL,
		cantidad_categorias_diferentes_comprados INT NOT NULL,
		sk_producto_mas_comprado INT NOT NULL,
		cantidad_producto_mas_comprado INT NOT NULL,
		sk_categoria_producto_mas_comprado INT NOT NULL,
		cantidad_categoria_producto_mas_comprado INT NOT NULL,
		gasto_promedio_compra DECIMAL(20,2) NOT NULL
		CONSTRAINT [pk_f_resumen_mensual_cliente] PRIMARY KEY CLUSTERED (sk_cliente, sk_mes),
		CONSTRAINT [fk_f_resumen_mensual_cliente_sk_cliente] FOREIGN KEY (sk_cliente) REFERENCES DWH.d_cliente(sk_cliente),
		CONSTRAINT [fk_f_resumen_mensual_cliente_sk_mes] FOREIGN KEY (sk_mes) REFERENCES DWH.d_mes(sk_mes),
		CONSTRAINT [fk_f_resumen_mensual_cliente_sk_producto_mas_comprado] FOREIGN KEY (sk_producto_mas_comprado) 
			REFERENCES DWH.d_producto(sk_producto),
		CONSTRAINT [fk_f_resumen_mensual_cliente_sk_categoria_producto_mas_comprado] FOREIGN KEY (sk_categoria_producto_mas_comprado) 
			REFERENCES DWH.d_categoria_producto(sk_categoria_producto)
	);
END;

EXEC SP_create_dim_tables;

CREATE PROCEDURE SP_populate_dim_tables
AS
BEGIN
	DECLARE @FechaInicio DATE = '2018-01-01';
	DECLARE @FechaFin    DATE = '2018-05-10';
	WITH RangoFechas AS (
		SELECT @FechaInicio AS FECHA
		UNION ALL
		SELECT DATEADD(DAY, 1, FECHA)
		FROM RangoFechas
		WHERE FECHA < @FechaFin
	)
	INSERT INTO DWH.d_fecha (sk_fecha, fecha, dia, mes, anio, sk_mes)
	SELECT 
		CONVERT(INT, FORMAT(FECHA, 'yyyyMMdd')) AS sk_fecha,
		fecha,
		DAY(FECHA) AS dia,
		MONTH(FECHA) AS mes,
		YEAR(FECHA) AS anio,
		CONVERT(INT, FORMAT(FECHA, 'yyyyMM')) AS sk_mes
	FROM RangoFechas
	OPTION (MAXRECURSION 0);

	SET LANGUAGE Spanish;

	INSERT INTO DWH.d_mes (sk_mes, nbr_mes, nro_mes, cant_dias, anio)
	SELECT
		sk_mes,
		DATENAME(MONTH, MIN(fecha)) as nbr_mes,
		mes as nro_mes,
		count(*) as cant_dias,
		anio
	FROM DWH.d_fecha
	GROUP BY sk_mes, mes, anio;

	ALTER TABLE DWH.d_fecha
	ADD CONSTRAINT fk_d_fecha_sk_mes
	FOREIGN KEY (sk_mes) REFERENCES DWH.d_mes(sk_mes);

	INSERT INTO DWH.d_ciudad (id_ciudad, nbr_ciudad, codigo_zip)
	SELECT
		CityID as id_ciudad,
		CityName as nbr_ciudad,
		Zipcode as codigo_zip
	FROM bi_202501.dbo.cities
	ORDER BY Zipcode ASC;

	INSERT INTO DWH.d_cliente (id_cliente, primer_nbr, inicial_segundo_nbr, ape_paterno, sk_ciudad, direccion)
	SELECT
		f.CustomerID as id_cliente,
		f.FirstName as primer_nbr,
		CASE
			WHEN f.MiddleInitial = 'NULL' THEN NULL
			ELSE f.MiddleInitial
		END AS inicial_segundo_nbr,
		f.LastName as ape_paterno,
		c.sk_ciudad,
		f.Address as direccion
	FROM bi_202501.dbo.customers as f
	INNER JOIN COSTCO_DB.DWH.d_ciudad as c
		ON f.CityID = c.id_ciudad
	ORDER BY f.LastName ASC;

	INSERT INTO DWH.d_categoria_producto (id_categoria_producto, nbr_categoria_producto)
	SELECT 
		CategoryID as id_categoria_producto,
		CategoryName as nbr_categoria_producto
	FROM bi_202501.dbo.categories
	ORDER BY CategoryName;

	INSERT INTO DWH.d_producto (id_producto, nbr_producto, precio, sk_categoria_producto, clase, resistencia, alergico, dias_vigencia)
	SELECT
		f.ProductID as id_producto,
		f.ProductName as nbr_producto,
		f.Price as precio,
		c.sk_categoria_producto,
		f.Class as clase,
		f.Resistant as resistencia,
		f.IsAllergic as alergico,
		cast(f.VitalityDays as FLOAT) as dias_vigencia
	FROM bi_202501.dbo.products as f
	INNER JOIN DWH.d_categoria_producto as c
		ON f.CategoryID = c.id_categoria_producto;

	WITH
	ventas AS (
		SELECT
			c.sk_cliente,
			CAST(s.SalesDate as DATE) as fecha_venta,
			f.sk_mes,
			p.sk_producto,
			p.sk_categoria_producto,
			CAST(s.Quantity as INT) as cantidad,
			p.precio as precio,
			CAST(s.Discount as FLOAT) as pctj_descuento
		FROM bi_202501.dbo.sales as s
		INNER JOIN DWH.d_cliente as c
			on s.CustomerID = c.id_cliente
		INNER JOIN DWH.d_producto as p
			on s.ProductID = p.id_producto
		INNER JOIN DWH.d_fecha as f
			on CAST(s.SalesDate as DATE) = f.fecha
	),
	ventas_mes AS (
		SELECT 
			sk_cliente, 
			sk_mes,
			COUNT(DISTINCT fecha_venta) as dias_activos,
			COUNT(*) as total_compras,
			SUM(precio * (1.00 - pctj_descuento) * cantidad) as total_gastado,
			SUM(precio * cantidad) as total_gastado_sin_dscto,
			COUNT(DISTINCT sk_producto) as cantidad_productos_diferentes_comprados,
			COUNT(DISTINCT sk_categoria_producto) as cantidad_categorias_diferentes_comprados
		FROM ventas
		GROUP BY sk_cliente, sk_mes
	),
	ventas_prod AS (
		SELECT
			sk_cliente,
			sk_mes,
			sk_producto,
			SUM(cantidad) as cantidad_producto_mas_comprado,
			ROW_NUMBER() OVER (PARTITION BY sk_cliente, sk_mes ORDER BY SUM(cantidad) DESC) as rn_prod
		FROM ventas	
		GROUP BY sk_cliente, sk_mes, sk_producto
	),
	ventas_cat AS (
		SELECT
			sk_cliente,
			sk_mes,
			sk_categoria_producto,
			SUM(cantidad) as cantidad_categoria_producto_mas_comprado,
			ROW_NUMBER() OVER (PARTITION BY sk_cliente, sk_mes ORDER BY SUM(cantidad) DESC) as rn_cat
		FROM ventas
		GROUP BY sk_cliente, sk_mes, sk_categoria_producto
	)
	INSERT INTO DWH.f_resumen_mensual_cliente (
		sk_cliente,
		sk_mes,dias_activos,
		total_compras,
		total_gastado,
		total_gastado_sin_dscto,
		cantidad_productos_diferentes_comprados,
		cantidad_categorias_diferentes_comprados,
		sk_producto_mas_comprado,
		cantidad_producto_mas_comprado,
		sk_categoria_producto_mas_comprado,
		cantidad_categoria_producto_mas_comprado,
		gasto_promedio_compra
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
		p.sk_producto as sk_producto_mas_comprado,
		p.cantidad_producto_mas_comprado,
		c.sk_categoria_producto as sk_categoria_producto_mas_comprado,
		c.cantidad_categoria_producto_mas_comprado,
		(m.total_gastado/m.dias_activos) as gasto_promedio_compra
	FROM ventas_mes as m
	INNER JOIN ventas_prod as p
		ON m.sk_cliente = p.sk_cliente 
		AND m.sk_mes = p.sk_mes
		AND rn_prod = 1
	INNER JOIN ventas_cat as c
		ON m.sk_cliente = c.sk_cliente 
		AND m.sk_mes = c.sk_mes
		AND rn_cat = 1
END;

EXEC SP_populate_dim_tables;
