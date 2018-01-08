--新的動態管理檢視：
--公開摘要層級屬性和交易記錄檔的相關資訊，適用於監視交易記錄健全狀況。
create database db
use db

select * from sys.dm_db_log_stats(db_id('db'))

--會公開 VLF 資訊，以便監視、警示及防止潛在交易記錄問題
/*
Indicates whether VLF is in use or not. 
0 - vlf is not in use.
1 - VLF is active.
vlf_status	int	Status of the VLF. Possible values include 
0 - VLF is inactive 
1 - vlf is initialized but unused 
2 - VLF is active.
*/
select * from sys.dm_db_log_info(db_id('db')) 

drop table if exists t
go
create table t(c1 int identity primary key,
insertTime datetime2(7) default(sysdatetime()),
rnd int  default(rand()*1000)
,index idx(rnd) )  --inline index 沒看到統計，詭異
go 
set nocount on
insert t default values
go 10000

select * from t where rnd=0


create index idx2 on t(rnd)

create statistics rndStats on t(rnd)

select * from sys.sysindexes where id=object_id('t')

--查看統計資料的新動態管理檢視
declare @id int
select @id=stats_id from sys.stats where object_id=object_id('t') and name='idx'
select * from sys.dm_db_stats_histogram(object_id('t'),@id)

dbcc show_statistics(t,idx)

go

declare @id int
select @id=stats_id from sys.stats where object_id=object_id('t') and name='idx2'
select * from sys.dm_db_stats_histogram(object_id('t'),@id)
go
dbcc show_statistics(t,idx2)

SELECT object_name(ss.object_id) objectName,ss.name, ss.stats_id, shr.steps, shr.rows, shr.rows_sampled, 
    shr.modification_counter, shr.last_updated, sh.range_rows, sh.equal_rows
FROM sys.stats ss
INNER JOIN sys.stats_columns sc 
    ON ss.stats_id = sc.stats_id AND ss.object_id = sc.object_id
INNER JOIN sys.all_columns ac 
    ON ac.column_id = sc.column_id AND ac.object_id = sc.object_id
outer APPLY sys.dm_db_stats_properties(ss.object_id, ss.stats_id) shr
outer APPLY sys.dm_db_stats_histogram(ss.object_id, ss.stats_id) sh
WHERE ss.[object_id] = OBJECT_ID('t') 




--會追蹤每個資料庫的版本存放區使用量，適用於主動根據每個資料庫的版本存放區使用量來規劃 tempdb 大小
select * from sys.dm_tran_version_store_space_usage 
--提供 Windows 和 Linux 作業系統資訊。 
select * from sys.dm_os_host_info 