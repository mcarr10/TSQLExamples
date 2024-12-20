/* This script adds a new record to AdventureWorksLT2022 */
USE [AdventureWorksLT2022]
GO
--BEGIN TRANSACTION;
-- Insert new customer record.
INSERT INTO [SalesLT].[Customer]
           ([NameStyle]
           ,[Title]
           ,[FirstName]
           ,[MiddleName]
           ,[LastName]
           ,[Suffix]
           ,[CompanyName]
           ,[SalesPerson]
           ,[EmailAddress]
           ,[Phone]
		   ,[PasswordHash]
		   ,[Passwordsalt]
		   )
     VALUES
           (0
           ,'Mr.'
           ,'Homer'
           ,'J.'
           ,'Simpson'
           ,NULL
           ,'Simpson Industries'
           ,'adventure-works\jillian0'
           ,'homer@adventure-works.com'
           ,'213-555-9812'
		   ,'C9FdyTzpsZ47mEsqgDG5s8S4CZJtl+yiy7sT5rEJ9VY='
		   ,'M9ctr9I+'
		  )

-- Insert address record

INSERT INTO [SalesLT].[Address]
           ([AddressLine1]
           ,[AddressLine2]
           ,[City]
           ,[StateProvince]
           ,[CountryRegion]
           ,[PostalCode]
           )
     VALUES
           ('742 Evergreen Terrace'
           ,NULL
           ,'Springfield'
           ,'IL'
           ,'United States'
           ,'682702'
		   )
-- Get CustomerID for new record
DECLARE @NewCustID INT
SELECT @NewCustID = CustomerID FROM [SalesLT].[Customer] WHERE LastName = 'Simpson' AND FirstName = 'Homer'

-- Get AddressID for new record
DECLARE @NewAddID INT
SELECT @NewAddID = AddressID FROM [SalesLT].[Address] WHERE AddressLine1 = '742 Evergreen Terrace' AND City = 'Springfield'

-- Insert CustomerAddress record'

INSERT INTO [SalesLT].[CustomerAddress]
           ([CustomerID]
           ,[AddressID]
           ,[AddressType]
           )
     VALUES
           (@NewCustID
           ,@NewAddID
           ,'Shipping'
			)

-- Insert OrderHeader record
INSERT INTO [SalesLT].[SalesOrderHeader]
           ([RevisionNumber]
           ,[OrderDate]
           ,[DueDate]
           ,[ShipDate]
           ,[Status]
           ,[OnlineOrderFlag]
           ,[PurchaseOrderNumber]
           ,[AccountNumber]
           ,[CustomerID]
           ,[ShipToAddressID]
           ,[BillToAddressID]
           ,[ShipMethod]
           ,[CreditCardApprovalCode]
           ,[SubTotal]
           ,[TaxAmt]
           ,[Freight]
           ,[Comment]
           )
     VALUES
           (2
           ,GETDATE()
           ,DATEADD(DD,15,GETDATE())
           ,DATEADD(DD,7,GETDATE())
           ,5
           ,1
           ,'PO123456789'
           ,'10-4020-000999'
           ,@NewCustID
           ,@NewAddID
           ,@NewAddID
           ,'CARGO TRANSPORT 5'
           ,NULL
           ,63.50
           ,4.91
           ,5.00
		   ,NULL
		)

--Get sales order ID for new record
DECLARE @SalesOrdID INT
SELECT @SalesOrdID = SalesOrderID FROM [SalesLT].[SalesOrderHeader] WHERE PurchaseOrderNumber = 'PO123456789' AND AccountNumber = '10-4020-000999' AND CustomerID = @NewCustID

-- Insert OderDetail record
INSERT INTO [SalesLT].[SalesOrderDetail]
           ([SalesOrderID]
           ,[OrderQty]
           ,[ProductID]
           ,[UnitPrice]
           ,[UnitPriceDiscount]
			)
     VALUES
           (@SalesOrdID
           ,1
           ,866
           ,63.50
           ,5.00
		  )

--ROLLBACK TRANSACTION;