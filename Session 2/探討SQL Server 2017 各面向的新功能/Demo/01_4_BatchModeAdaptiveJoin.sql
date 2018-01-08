--ALTER DATABASE [WideWorldImportersDW] SET COMPATIBILITY_LEVEL = 130
--ALTER DATABASE [WideWorldImportersDW] SET COMPATIBILITY_LEVEL = 140
--透過包含即時查詢統計資料呈現執行執行計畫，可以比對 SQL Server 2016 和 2017 兩個版本。2017 才有自適性聯結
use [WideWorldImportersDW]
go
SELECT  [fo].[Order Key], [si].[Lead Time Days],
[fo].[Quantity]
FROM    [Fact].[Order] AS [fo]
INNER JOIN [Dimension].[Stock Item] AS [si]
       ON [fo].[Stock Item Key] = [si].[Stock Item Key]
WHERE   [fo].[Quantity] = 360;
go

SELECT  [fo].[Order Key], [si].[Lead Time Days],
[fo].[Quantity]
FROM    [Fact].[Order] AS [fo]
INNER JOIN [Dimension].[Stock Item] AS [si]
       ON [fo].[Stock Item Key] = [si].[Stock Item Key]
WHERE   [fo].[Quantity] = 361;

/*
select quantity,count(*) from  [Fact].[Order]
group by quantity
order by 2
update Fact.[Order] set quantity=361 where [Order key]=702
*/
