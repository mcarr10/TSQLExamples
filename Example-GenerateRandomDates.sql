/* This script combines dateadd, datediff and rand to generate random dates in a range. */
DECLARE @BeginDate DATE = '2004-01-01'
DECLARE @EndDate DATE = '2024-12-31'
DECLARE @DateDiff INT = DATEDIFF(DD,@BeginDate,@EndDate)
SELECT DATEADD(DD,RAND()*@DateDiff,@BeginDate) As RandomDate
 