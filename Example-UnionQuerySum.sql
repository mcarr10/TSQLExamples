/* This is an example of grouping the results for a union query.  */
/* Assume there are 3 tables each wtih a category, date and tablecount column */
/* In this example the data is unique to each table so union all is the more efficient way to go */

SELECT [Category]
,SUM(TableACount) AS TableACount
,SUM(TableBCOunt) AS TableBCount
,SUM(TableCCount) AS TableCCount
FROM (
	SELECT [Category]
	,[Date]
	,TableACount
	,NULL As TableBCount
	,NULL As TableCCount
	FROM TableA
	UNION ALL
	SELECT [Category]
	,[Date]
	,NULL
	,TableBCount As TableBCount
	,NULL As TableCCount
	FROM TableB
	UNION ALL
	SELECT [Category]
	,[Date]
	,NULL As TableACount
	,NULL As TableBCount
	,TableCCount
	FROM TableC
	) AS X
GROUP BY [Category]
ORDER BY [Category] DESC
