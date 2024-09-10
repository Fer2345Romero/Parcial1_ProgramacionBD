USE AdventureWorks2022
GO

/*Ejercicio 1 Crear un procedimiento almacenado que retorne el listado de productos
cuya ultima orden de venta tiene 80 dias o más. La consulta debe retornar el id del producto, el nombre del producto y 
la cantidad de dias que han pasado desde su ultima orden, DEbe usar CTE y Try catch */

CREATE PROCEDURE GetProducts
AS
BEGIN
    BEGIN TRY
      WITH ProductLastOrderCTE AS
        (
            SELECT 
                P.ProductID, 
                P.Name AS ProductName, 
                DATEDIFF(DAY, MAX(OH.OrderDate), GETDATE()) AS DaysSinceLastOrder
            FROM 
                Production.Product P
            INNER JOIN 
                Sales.SalesOrderDetail SOD ON P.ProductID = SOD.ProductID
            INNER JOIN 
                Sales.SalesOrderHeader OH ON SOD.SalesOrderID = OH.SalesOrderID
            GROUP BY 
                P.ProductID, P.Name
        )
        SELECT 
            ProductID, 
            ProductName, 
            DaysSinceLastOrder
        FROM 
            ProductLastOrderCTE
        WHERE 
            DaysSinceLastOrder >= 80;
    END TRY
    BEGIN CATCH
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage;
    END CATCH
END;
GO

SELECT * FROM Production.Product

/*Ejercicio 2 Crear una vista que retorne los 25 clientes con mayores gastos(clientes que mas compras realizan). 
La consulta debe  retornar el id del cliente, el nombre combleto del cliente y el total gastado , la consulta 
debe estar ordenado por el total de gasto mas alto hacia abajo. Debe usar CTE*/

CREATE VIEW vw_top25ClientesMayorGastos AS
WITH TotalGastosPorCliente AS (
    SELECT
        c.CustomerID,
        CONCAT(c.FirstName, ' ', c.LastName) AS NombreCompleto,
        SUM(od.Quantity * od.UnitPrice) AS TotalGastado
    FROM
        Customers c
        JOIN Orders o ON c.CustomerID = o.CustomerID
        JOIN [Order Details] od ON o.OrderID = od.OrderID
    GROUP BY
        c.CustomerID, c.FirstName, c.LastName
)
SELECT
    CustomerID,
    NombreCompleto,
    TotalGastado
FROM
    TotalGastosPorCliente
ORDER BY
    TotalGastado DESC
OFFSET 0 ROWS FETCH NEXT 25 ROWS ONLY;
GO

SELECT * FROM Sales.Customer

/*Ejercicio 3 Crear un procedimiento almacenado que retorne el listado de productos que no han sido vendidos
desde el año anterior. La consulta debe retomar el Id  del producto y el nombre del producto. Debe usar subconsultas*/

CREATE OR ALTER PROCEDURE sp_ProductosNoVendidos
AS
BEGIN
    DECLARE @anioAnterior INT = YEAR(GETDATE()) - 1;

    SELECT 
        p.ProductID,
        p.Name AS NombreProducto
    FROM 
        Production.Product p
    WHERE 
        p.ProductID NOT IN (
            SELECT DISTINCT sod.ProductID
            FROM Sales.SalesOrderDetail sod
            JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
            WHERE YEAR(soh.OrderDate) = @anioAnterior
        );
END;
GO
