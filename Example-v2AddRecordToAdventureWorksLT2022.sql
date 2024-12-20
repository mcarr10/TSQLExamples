/* This script adds two new records to AdventureWorksLT2022 */
USE [AdventureWorksLT2022_DEV]


-- Insert a new record into SalesOrderHeader
INSERT INTO SalesLT.SalesOrderHeader
(
    OrderDate,
    DueDate,
    ShipDate,
    Status,
    OnlineOrderFlag,
    PurchaseOrderNumber,
    AccountNumber,
    CustomerID,  
    ShipToAddressID,
    BillToAddressID,
    ShipMethod,
    CreditCardApprovalCode,
    SubTotal,
    TaxAmt,
    Freight,
    Comment
)
VALUES
(
    GETDATE(),  
    GETDATE() + 10,  
    NULL,  -- ShipDate 
    1,  -- Status
    1,  -- OnlineOrderFlag
    'PO12345',  -- PurchaseOrderNumber
    '10-4020-000000',  -- AccountNumber
    (SELECT TOP 1 CustomerID FROM SalesLT.Customer),  --Use existing customer
    1001,  -- ShipToAddressID
    1001,  -- BillToAddressID
    'UPS',  -- ShipMethod
    '0457-0189-1234',  
    1000.00,  -- SubTotal
    80.00,  -- TaxAmt
    30.00,  -- Freight
    NULL  
);

-- Get the generated SalesOrderID for use in SalesOrderDetail
DECLARE @SalesOrderID INT = SCOPE_IDENTITY();

-- Insert a new record into SalesOrderDetail
INSERT INTO SalesLT.SalesOrderDetail
(
    SalesOrderID,
    OrderQty,
    ProductID,
    UnitPrice,
    UnitPriceDiscount
)
VALUES
(
    @SalesOrderID,  
    10,  
    712,  
    100.00,  
    0.00  
);

INSERT INTO SalesLT.SalesOrderHeader
(
    OrderDate,
    DueDate,
    ShipDate,
    Status,
    OnlineOrderFlag,
    PurchaseOrderNumber,
    AccountNumber,
    CustomerID,  
    ShipToAddressID,
    BillToAddressID,
    ShipMethod,
    CreditCardApprovalCode,
    SubTotal,
    TaxAmt,
    Freight,
    Comment
)
VALUES
(
    GETDATE(),  
    GETDATE() + 7,  
    GETDATE() + 7,  -- ShipDate 
    1,  -- Status
    1,  -- OnlineOrderFlag
    'PO-A7856',  -- PurchaseOrderNumber
    '10-4010-000234',  -- AccountNumber
    (SELECT TOP 1 CustomerID FROM SalesLT.Customer),  --Use existing customer
    1002,  -- ShipToAddressID
    1002,  -- BillToAddressID
    'UPS',  -- ShipMethod
    '0345-01795-5678',  
    95.00,  -- SubTotal
    9.50,  -- TaxAmt
    12.00,  -- Freight
    NULL  
);

-- Get the generated SalesOrderID for use in SalesOrderDetail
DECLARE @SalesOrderID2 INT = SCOPE_IDENTITY();

-- Insert a new record into SalesOrderDetail
INSERT INTO SalesLT.SalesOrderDetail
(
    SalesOrderID,
    OrderQty,
    ProductID,
    UnitPrice,
    UnitPriceDiscount
)
VALUES
(
    @SalesOrderID2,  
    10,  
    709,  
    9.50,  
    0.00  
);