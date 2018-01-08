--觀察 modified_extent_page_count
backup database northwind to disk='nul'

select * from sys.dm_db_file_space_usage
go

--select into 到特定 FG
ALTER DATABASE Northwind ADD FILEGROUP FG2;
ALTER DATABASE Northwind
ADD FILE
(
NAME='FG2_Data',
FILENAME = 'C:\temp\nwind_Data1.ndf'
)
TO FILEGROUP FG2;
GO
SELECT * INTO t ON FG2 from customers
go

use tempdb
create table t(c1 int primary key,c2 nvarchar(10))
go
--MAXERRORS 預設是 10
BULK INSERT t FROM 'C:\temp\test.csv'
/*
Msg 4861, Level 16, State 1, Line 24
無法大量載入，因為檔案 "C:\temp\bulkinsertError.log" 無法開啟。作業系統錯誤碼 80(檔案存在。)。
Msg 4861, Level 16, State 1, Line 24
無法大量載入，因為檔案 "C:\temp\bulkinsertError.log.Error.Txt" 無法開啟。作業系統錯誤碼 80(檔案存在。)。
*/
WITH (FORMAT = 'CSV',ERRORFILE='C:\temp\bulkinsertError.log'  --若設定了 errorfile 則無法寫入會導致放棄
--,MAXERRORS=0
); 
go
select * from t
truncate table t
