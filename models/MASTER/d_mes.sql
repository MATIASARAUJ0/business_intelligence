{{ config(
    materialized = 'table',
    schema = 'MASTER',
    alias = 'd_mes',
    pre_hook = [
        "SET LANGUAGE Spanish;"
    ],
    post_hook = [
        "ALTER TABLE {{ this }} ADD CONSTRAINT pk_d_mes_sk_mes PRIMARY KEY NONCLUSTERED (sk_mes)",
        "IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'd_fecha') BEGIN
        	ALTER TABLE MASTER.d_fecha
        	ADD CONSTRAINT fk_d_fecha_sk_mes FOREIGN KEY (sk_mes) REFERENCES MASTER.d_mes(sk_mes)
        END"
    ]
) }}

SELECT
    sk_mes,
    DATENAME(MONTH, MIN(fecha)) AS nbr_mes,
    MONTH(MIN(fecha)) AS nro_mes,
    COUNT(*) AS cant_dias,
    anio
FROM COSTCO_DB.MASTER.d_fecha
GROUP BY sk_mes, anio
