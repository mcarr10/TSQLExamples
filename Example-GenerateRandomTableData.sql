/* This script generates random table data in a 4 column table  */

DECLARE @rowcount INT = 1000;  --Enter the number of rows to insert into the table
SET NOCOUNT ON;

-- Drop and create the table
DROP TABLE IF EXISTS dbo.TestTable;

CREATE TABLE TestTable 
(
	Column0 INT IDENTITY(1,1) PRIMARY KEY,
	Column1 VARCHAR(50),
	Column2 VARCHAR(50),
	Column3 FLOAT,
	Column4 DATE
);

-- Insert table data
DECLARE @i INT = 1;
WHILE @i <= 1000
BEGIN
INSERT TestTable (Column1, Column2, Column3, Column4) 
VALUES 
(
CONCAT(RIGHT(CONVERT(VARCHAR(255),NEWID()),20),@i),
CONCAT(RIGHT(CONVERT(VARCHAR(255),NEWID()),25),@i),
@i + RAND(),
GETDATE()
);

SET @i = @i + 1;
END;

-- SELECT TOP 100 * FROM dbo.TestTable

--Clean up by dropping table
--DROP TABLE IF EXISTS dbo.TestTable;