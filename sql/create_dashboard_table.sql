USE Ventas2;

 CREATE TABLE TableroVentas (
        Año INT,
        [01] MONEY, [02] MONEY, [03] MONEY, [04] MONEY,
        [05] MONEY, [06] MONEY, [07] MONEY, [08] MONEY,
        [09] MONEY, [10] MONEY, [11] MONEY, [12] MONEY
    );


    WITH VentasTotales AS (
        SELECT 
            YEAR(fecha) AS Año,
            RIGHT('0' + CAST(MONTH(fecha) AS VARCHAR), 2) AS Mes,
            total AS Importe
        FROM vencab
        WHERE anulada = 0 AND tipofac = 'M'
        
        UNION ALL

        SELECT 
            YEAR(fecha) AS Año,
            RIGHT('0' + CAST(MONTH(fecha) AS VARCHAR), 2) AS Mes,
            total AS Importe
        FROM mayorcab
        WHERE anulada = 0
    ),
    
    VentasAgrupadas AS (
        SELECT 
            Año, 
            Mes, 
            SUM(Importe) AS TotalVentas
        FROM VentasTotales
        GROUP BY Año, Mes
    )


    INSERT INTO TableroVentas
    SELECT
        Año,
        ISNULL([01], 0), ISNULL([02], 0), ISNULL([03], 0), ISNULL([04], 0),
        ISNULL([05], 0), ISNULL([06], 0), ISNULL([07], 0), ISNULL([08], 0),
        ISNULL([09], 0), ISNULL([10], 0), ISNULL([11], 0), ISNULL([12], 0)
    FROM (
        SELECT Año, Mes, TotalVentas FROM VentasAgrupadas
    ) AS Fuente
    PIVOT (
        SUM(TotalVentas)
        FOR Mes IN (
            [01], [02], [03], [04], [05], [06], 
            [07], [08], [09], [10], [11], [12]
        )
    ) AS TablaPivot;



SELECT * FROM TableroVentas;
