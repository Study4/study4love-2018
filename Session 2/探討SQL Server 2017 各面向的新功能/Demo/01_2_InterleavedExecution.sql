USE [WideWorldImportersDW]
GO

alter function dbo.OrderByKey(@OrderKey int)
RETURNS @retOrderss TABLE 
(
	[Order Key] [bigint], 
	[Customer Key] [int],
	[WWI Backorder ID] [int] ,
	[Description] [nvarchar](100) ,
	[Package] [nvarchar](50) ,
	[Quantity] [int] ,
	[Unit Price] [decimal](18, 2),
	[Tax Rate] [decimal](18, 3) ,
	[Total Excluding Tax] [decimal](18, 2) ,
	[Tax Amount] [decimal](18, 2) ,
	[Total Including Tax] [decimal](18, 2) ,
	[Lineage Key] [int]
)
AS
BEGIN
   INSERT @retOrderss
   SELECT  [Order Key],[Customer Key],[WWI Backorder ID],
	[Description],[Package],[Quantity],
	[Unit Price],[Tax Rate],[Total Excluding Tax],
	[Tax Amount] [decimal],[Total Including Tax],
	[Lineage Key]
   from Fact.[Order] where [Order Key]>@OrderKey
   INSERT @retOrderss
   SELECT  [Order Key],[Customer Key],[WWI Backorder ID],
	[Description],[Package],[Quantity],
	[Unit Price],[Tax Rate],[Total Excluding Tax],
	[Tax Amount] [decimal],[Total Including Tax],
	[Lineage Key]
   from Fact.[Order] where [Order Key]>@OrderKey
   RETURN
END
GO

--透過即時查詢統計資料觀察，由於預估多行資料表值函數的回傳紀錄是 100
--因此判讀錯要預設賦予的記憶體，以及使用 nestloop join
ALTER DATABASE [WideWorldImportersDW] SET COMPATIBILITY_LEVEL = 130
go
select c.Customer,sum(o.Quantity) from dbo.OrderByKey(1) o join 
[Dimension].[Customer] c on o.[Customer Key]=c.[Customer Key]
group by c.Customer
go

--透過 Interleaved Execution，知道函數回傳的筆數後重新找尋執行計畫
--可以正確地使用 Merge Join 以及配置記憶體
ALTER DATABASE [WideWorldImportersDW] SET COMPATIBILITY_LEVEL = 140

select c.Customer,sum(o.Quantity) from dbo.OrderByKey(1) o join 
[Dimension].[Customer] c on o.[Customer Key]=c.[Customer Key]
group by c.Customer

