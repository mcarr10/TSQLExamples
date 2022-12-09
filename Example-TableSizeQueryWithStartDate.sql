/* This is an example query to return table sizes.  The where clause is to return only recently created tables.*/

DECLARE @StartDate AS DATE = DATEADD(YEAR,-1,GETDATE())
SELECT
t.create_date As CreateDate
,s.name As SchemaName
,t.name AS TableName
,p.rows AS RowCounts
,CAST(ROUND((SUM(a.used_pages)/128.00),2) AS NUMERIC(36,2)) As UsedMB
,CAST(ROUND((SUM(a.total_pages)/128.00),2) AS NUMERIC(36,2)) As TotalMB
FROM sys.tables t
INNER JOIN sys.indexes i on t.object_id = i.object_id
INNER JOIN sys.partitions p on i.object_id = p.object_id AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a on p.partition_id = a.container_id
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE t.create_date >= @StartDate
GROUP BY t.create_date, t.Name, s.Name, p.rows
ORDER BY TotalMB DESC
GO
