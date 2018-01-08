use master
go

--設定SQL Server可以啟動執行.NET 所撰寫的物件
--預設未啟動，你可以註冊物件，但無法執行
exec sp_configure 'show advanced options',1
reconfigure
exec sp_configure 'clr enabled',1
reconfigure
--預設是啟動的
exec sp_configure 'clr strict security'

--授權簽章過，有強式名稱的組件可以 external access、unsafe 的方式執行，務必在 context db=master
CREATE ASYMMETRIC KEY SQLCLRTestKey FROM EXECUTABLE FILE = 'C:\SQL2017\Demo\SQLCLRDemo\bin\Debug\SQLCLRDemo.dll'   
CREATE LOGIN SQLCLRTestLogin FROM ASYMMETRIC KEY SQLCLRTestKey   
GRANT UNSAFE ASSEMBLY TO SQLCLRTestLogin; -- EXTERNAL ACCESS
go

use Northwind

--將 Assembly 加入到 SQL Server
--還是需要設定 permission_set
CREATE ASSEMBLY SQLCLRDemo FROM 'C:\SQL2017\Demo\SQLCLRDemo\bin\Debug\SQLCLRDemo.dll' 
WITH PERMISSION_SET=unsafe
GO

--建立一個名為 RetrieveRSS 的預存程序
CREATE FUNCTION [dbo].[EventLog]
(@logname NVARCHAR (MAX) NULL)
RETURNS 
     TABLE (
        [timeWritten] DATETIME        NULL,
        [message]     NVARCHAR (MAX) NULL,
        [category]    NVARCHAR (256)  NULL,
        [instanceID]  BIGINT          NULL)
AS
 EXTERNAL NAME SQLCLRDemo.[UserDefinedFunctions].[InitMethod]
GO

select　top(10)  * from [dbo].EventLog(N'Application')
go
--讓該資料庫的 .NET 物件可以存取 SQL Server 之外的資源
--ALTER DATABASE db SET TRUSTWORTHY ON
drop function dbo.EventLog
drop assembly SQLCLRDemo
go
use master
go
drop login SQLCLRTestLogin
drop asymmetric key SQLCLRTestKey

