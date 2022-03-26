/*This query returns the size in MB and GB of each schema */

SELECT  SCHEMA_NAME(so.schema_id) AS SchemaName
        ,CAST(SUM(ps.reserved_page_count) * 8 / 1024 AS BIGINT) AS  SizeMB
		,CAST(SUM(ps.reserved_page_count) * 8 / 1048576 AS BIGINT) AS SizeGB
FROM    sys.dm_db_partition_stats ps
INNER JOIN  sys.indexes si  ON si.object_id = ps.object_id  AND si.index_id = ps.index_id
INNER JOIN	sys.objects	so ON	si.object_id = so.object_id
WHERE so.type = 'U'
GROUP BY so.schema_id
ORDER BY SizeMB DESC   