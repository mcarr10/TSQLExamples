/* Generate random dollar amounts inlcuding negative amounts */
DECLARE @BeginValue AS DECIMAL(10,2) = -100.00
DECLARE @EndValue AS DECIMAL(10,2) = 500.00
SELECT ROUND((RAND()*(@EndValue - @BeginValue)+@BeginValue),2)

