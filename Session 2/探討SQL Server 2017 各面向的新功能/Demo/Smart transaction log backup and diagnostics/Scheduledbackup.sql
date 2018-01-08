SET NOCOUNT ON
WHILE(1=1)
BEGIN

BACKUP LOG [PowerConsumption] to disk = 'nul' WITH FORMAT,COMPRESSION
WAITFOR DELAY '00:01:00'
END

USE [PowerConsumption]
GO
DBCC SHRINKFILE (N'PowerConsumption_log' , 1)
GO
