/* This is an efficient query for approximate row counts on large tables.  The results can vary from the actual numer of rows in a given table. */

SELECT SCHEMA_NAME(so.schema_id) As SchemaName
,so.[name] AS TableName
,ps.RowCount
FROM sys.indexes AS si
INNER JOIN sys.objects AS so ON si.object_id = so.object_id
INNER JOIN sys.dm_db_partition_stats AS ps ON si.object_id = ps.object_id AND si.index_id = ps.index_id
WHERE si.index_id < 2
AND so.is_ms_shipped = 0
