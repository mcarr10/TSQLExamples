/* Create TSQLExample database used by some other examples */
/* 2022-12-20 Added DateExample table */
/* 2023-01-23 Added AddressExample table */

USE master
GO
IF NOT EXISTS(SELECT * FROM sys.databases WHERE name = 'TSQLExample')
  BEGIN
    CREATE DATABASE [TSQLExample]
  END
GO
USE TSQLExample
GO
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TableA]') AND type in (N'U'))
CREATE TABLE [dbo].[TableA](
	[Category] [varchar](25) NULL,
	[Date] [date] NULL,
	[TableACount] [int] NULL
) ON [PRIMARY]
GO
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TableB]') AND type in (N'U'))
CREATE TABLE [dbo].[TableB](
	[Category] [varchar](25) NULL,
	[Date] [date] NULL,
	[TableBCount] [int] NULL
) ON [PRIMARY]
GO
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TableC]') AND type in (N'U'))
CREATE TABLE [dbo].[TableC](
	[Category] [varchar](25) NULL,
	[Date] [date] NULL,
	[TableCCount] [int] NULL
) ON [PRIMARY]
GO
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DateExample]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[DateExample](
	[DateExampleID] [int] IDENTITY(1,1) NOT NULL,
	[DateExample] [date] NULL,
	[DatetimeExample] [datetime] NULL,
	[Datetime2Example] [datetime2](7) NULL,
 CONSTRAINT [PK_DateExample] PRIMARY KEY CLUSTERED 
(
	[DateExampleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AddressExample]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[AddressExample](
	[AddressExampleID] [int] IDENTITY(1,1) NOT NULL,
	[Address] [varchar](200) NULL,
	[City] [varchar](75) NULL,
	[StateCode] [char](2) NULL,
	[ZipCode] [int] NULL,
	[Lat] [decimal](10, 8) NULL,
	[Lng] [decimal](10, 8) NULL,
	[Geocode] [geography] NULL,
 CONSTRAINT [PK_AddressExample] PRIMARY KEY CLUSTERED 
(
	[AddressExampleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

/*********************************************************************************************************************/
/* Populate table data                                                                                               */
/*********************************************************************************************************************/

IF NOT EXISTS (SELECT 1 FROM [dbo].[TableA])
BEGIN
	INSERT [dbo].[TableA] ([Category], [Date], [TableACount]) VALUES (N'RedWidgets', CAST(N'2022-01-15' AS Date), 10)
	INSERT [dbo].[TableA] ([Category], [Date], [TableACount]) VALUES (N'BlueWidgets', CAST(N'2022-02-15' AS Date), 10)
	INSERT [dbo].[TableA] ([Category], [Date], [TableACount]) VALUES (N'GreenWidgets', CAST(N'2022-03-15' AS Date), 10)
	INSERT [dbo].[TableB] ([Category], [Date], [TableBCount]) VALUES (N'RedWidgets', CAST(N'2022-01-14' AS Date), 5)
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[TableB])
BEGIN 
	INSERT [dbo].[TableB] ([Category], [Date], [TableBCount]) VALUES (N'BlueWidgets', CAST(N'2022-01-14' AS Date), 5)
	INSERT [dbo].[TableB] ([Category], [Date], [TableBCount]) VALUES (N'GreenWidgets', CAST(N'2022-01-14' AS Date), 5)
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[TableC])
BEGIN
	INSERT [dbo].[TableC] ([Category], [Date], [TableCCount]) VALUES (N'RedWidgets', CAST(N'2022-01-12' AS Date), 20)
	INSERT [dbo].[TableC] ([Category], [Date], [TableCCount]) VALUES (N'BlueWidgets', CAST(N'2022-01-12' AS Date), 20)	
	INSERT [dbo].[TableC] ([Category], [Date], [TableCCount]) VALUES (N'GreenWidgetS', CAST(N'2022-01-12' AS Date), 20)
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[DateExample])
BEGIN
SET IDENTITY_INSERT [dbo].[DateExample] ON 
INSERT [dbo].[DateExample] ([DateExampleID], [DateExample], [DatetimeExample], [Datetime2Example]) VALUES (1, CAST(N'2022-12-01' AS Date), CAST(N'2022-12-20T12:05:06.130' AS DateTime), CAST(N'2022-12-20T12:05:51.4733333' AS DateTime2))
SET IDENTITY_INSERT [dbo].[DateExample] OFF
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[AddressExample])
BEGIN
SET IDENTITY_INSERT [dbo].[AddressExample] ON 
INSERT [dbo].[AddressExample] ([AddressExampleID], [Address], [City], [StateCode], [ZipCode], [Lat], [Lng], [Geocode]) VALUES (1, N'115 Historic Nature Trail', N'Gatlinburg', N'TN', 37738, CAST(35.71073200 AS Decimal(10, 8)), CAST(-83.51828000 AS Decimal(10, 8)), NULL)
INSERT [dbo].[AddressExample] ([AddressExampleID], [Address], [City], [StateCode], [ZipCode], [Lat], [Lng], [Geocode]) VALUES (2, N'1110 N Ocean Blvd', N'Myrtle Beach', N'SC', 29577, CAST(33.68785100 AS Decimal(10, 8)), CAST(-78.88385000 AS Decimal(10, 8)), NULL)
INSERT [dbo].[AddressExample] ([AddressExampleID], [Address], [City], [StateCode], [ZipCode], [Lat], [Lng], [Geocode]) VALUES (3, N'600 E Grand Ave', N'Chicago', N'IL', 60611, CAST(41.89170740 AS Decimal(10, 8)), CAST(-87.60896300 AS Decimal(10, 8)), NULL)
SET IDENTITY_INSERT [dbo].[AddressExample] OFF
END
