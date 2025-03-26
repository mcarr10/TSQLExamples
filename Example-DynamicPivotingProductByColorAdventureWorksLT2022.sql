/* This script is an example of pivoting the AdventureWorksLT2022 Product table by product color showing list price.*/
DECLARE @columns NVARCHAR(MAX), 
		@sql NVARCHAR(MAX);

-- Get the set of product colors
SELECT @columns = STRING_AGG(QUOTENAME(Color), ',')
FROM (SELECT DISTINCT Color FROM SalesLT.Product WHERE Color IS NOT NULL) AS x;

-- Dynamic SQL.  Use CoPilot to update the SQL for a different table.
SET @sql = '
SELECT ProductID, Name, ' + @columns + '
FROM (
    SELECT ProductID, Name, Color, ListPrice
    FROM SalesLT.Product
    WHERE Color IS NOT NULL
) AS SourceTable
PIVOT (
    MAX(ListPrice)
    FOR Color IN (' + @columns + ')
) AS PivotTable
ORDER BY ProductID;';

EXEC sp_executesql @sql;


