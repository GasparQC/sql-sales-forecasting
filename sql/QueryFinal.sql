CREATE OR ALTER PROCEDURE sp_TableroVentas
AS
BEGIN
    -- Evita mostrar mensajes como "N filas afectadas"
    SET NOCOUNT ON;

    BEGIN TRY
        -- Inicia una transacción para asegurar la integridad de los datos
        BEGIN TRANSACTION;

        -- Verifica si la tabla TableroVentas ya existe
        IF OBJECT_ID('dbo.TableroVentas', 'U') IS NULL
        BEGIN
            -- Si la tabla NO existe, la crea con los totales de ventas por mes y año
            SELECT
                YEAR(fecha) AS Año,
                -- Suma el total de ventas por cada mes
                SUM(CASE WHEN MONTH(fecha) = 1 THEN total ELSE 0 END) AS [1],
                SUM(CASE WHEN MONTH(fecha) = 2 THEN total ELSE 0 END) AS [2],
                SUM(CASE WHEN MONTH(fecha) = 3 THEN total ELSE 0 END) AS [3],
                SUM(CASE WHEN MONTH(fecha) = 4 THEN total ELSE 0 END) AS [4],
                SUM(CASE WHEN MONTH(fecha) = 5 THEN total ELSE 0 END) AS [5],
                SUM(CASE WHEN MONTH(fecha) = 6 THEN total ELSE 0 END) AS [6],
                SUM(CASE WHEN MONTH(fecha) = 7 THEN total ELSE 0 END) AS [7],
                SUM(CASE WHEN MONTH(fecha) = 8 THEN total ELSE 0 END) AS [8],
                SUM(CASE WHEN MONTH(fecha) = 9 THEN total ELSE 0 END) AS [9],
                SUM(CASE WHEN MONTH(fecha) = 10 THEN total ELSE 0 END) AS [10],
                SUM(CASE WHEN MONTH(fecha) = 11 THEN total ELSE 0 END) AS [11],
                SUM(CASE WHEN MONTH(fecha) = 12 THEN total ELSE 0 END) AS [12]
            -- Crea la tabla TableroVentas a partir de este SELECT
            INTO dbo.TableroVentas
            FROM (
                -- Subconsulta: Obtiene ventas minoristas válidas
                SELECT vc.fecha, --ISNULL(vd.cantidad, 0) * ISNULL(vd.precioventa, 0) AS total
				vc.total as total
                FROM vencab vc
                --JOIN vendet vd ON vc.letra = vd.letra AND vc.factura = vd.factura 
                WHERE ISNULL(vc.anulada, 0) = 0

                UNION ALL

                -- Subconsulta: Obtiene ventas mayoristas válidas
                SELECT mc.fecha, --ISNULL(md.cantidad, 0) * ISNULL(md.precioventa, 0) AS total
				mc.total as total
                FROM mayorcab mc
                --JOIN mayordet md ON mc.letra = md.letra AND mc.factura = md.factura
                WHERE ISNULL(mc.anulada, 0) = 0
            ) AS datos
            -- Agrupa por año
            GROUP BY YEAR(fecha);
        END
        ELSE
        BEGIN
            -- Si la tabla ya existe, la vacía
            TRUNCATE TABLE dbo.TableroVentas;

            -- Luego inserta los nuevos datos actualizados
            INSERT INTO dbo.TableroVentas (
                Año, [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12]
            )
            SELECT
                YEAR(fecha),
                SUM(CASE WHEN MONTH(fecha) = 1 THEN total ELSE 0 END),
                SUM(CASE WHEN MONTH(fecha) = 2 THEN total ELSE 0 END),
                SUM(CASE WHEN MONTH(fecha) = 3 THEN total ELSE 0 END),
                SUM(CASE WHEN MONTH(fecha) = 4 THEN total ELSE 0 END),
                SUM(CASE WHEN MONTH(fecha) = 5 THEN total ELSE 0 END),
                SUM(CASE WHEN MONTH(fecha) = 6 THEN total ELSE 0 END),
                SUM(CASE WHEN MONTH(fecha) = 7 THEN total ELSE 0 END),
                SUM(CASE WHEN MONTH(fecha) = 8 THEN total ELSE 0 END),
                SUM(CASE WHEN MONTH(fecha) = 9 THEN total ELSE 0 END),
                SUM(CASE WHEN MONTH(fecha) = 10 THEN total ELSE 0 END),
                SUM(CASE WHEN MONTH(fecha) = 11 THEN total ELSE 0 END),
                SUM(CASE WHEN MONTH(fecha) = 12 THEN total ELSE 0 END)
            FROM (
                -- Subconsulta: ventas minoristas válidas
                SELECT vc.fecha, --ISNULL(vd.cantidad, 0) * ISNULL(vd.precioventa, 0) AS total
				vc.total as total
                FROM vencab vc
                --JOIN vendet vd ON vc.letra = vd.letra AND vc.factura = vd.factura
                WHERE ISNULL(vc.anulada, 0) = 0

                UNION ALL

                -- Subconsulta: ventas mayoristas válidas
                SELECT mc.fecha, --ISNULL(md.cantidad, 0) * ISNULL(md.precioventa, 0) AS total
				mc.total as total
                FROM mayorcab mc
                --JOIN mayordet md ON mc.letra = md.letra AND mc.factura = md.factura
                WHERE ISNULL(mc.anulada, 0) = 0
            ) AS datos
            GROUP BY YEAR(fecha);
        END

        -- Cierra la transacción correctamente
        COMMIT TRANSACTION;

        -- Mensaje informativo en consola
        PRINT 'TableroVentas actualizado correctamente.';
    END TRY
    BEGIN CATCH
        -- Si ocurre un error, revierte la transacción
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Muestra el mensaje de error
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;

-- Ejecuta el procedimiento para generar o actualizar la tabla
EXEC sp_TableroVentas;

-- Muestra el contenido de la tabla resultante
SELECT * FROM TableroVentas order by Año asc;
DROP TABLE IF EXISTS dbo.TableroVentas;


