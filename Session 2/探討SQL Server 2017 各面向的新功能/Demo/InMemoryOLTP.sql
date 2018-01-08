USE [master]
GO

CREATE DATABASE [dbHekaton]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'dbHekaton', FILENAME = N'C:\temp\dbHekaton.mdf' , SIZE = 10MB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'dbHekaton_log', FILENAME = N'C:\temp\dbHekaton_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [dbHekaton] ADD FILEGROUP [MemoryOptimized] CONTAINS MEMORY_OPTIMIZED_DATA 
GO
ALTER DATABASE [dbHekaton]
ADD FILE
  ( NAME = MemoryOptimizedFile,
    FILENAME = N'C:\temp\MemoryOptimizedFile')
TO FILEGROUP [MemoryOptimized]
go

use dbHekaton
go

CREATE TABLE MemoryOptimizedTable
(
	c1 int identity PRIMARY KEY NONCLUSTERED, 
	c2 float NOT NULL CHECK(c2>0),  --可以設定 check(2016)
	c3 decimal(10,2) NULL INDEX index_sample_memoryoptimizedtable_c3 NONCLUSTERED (c3),   --可 Null 欄位建索引(2016)
	c4 varchar(10) index idxC4 nonclustered(c4) default('Hello'),  --非 unicode 字元類型索引不限定序(2016)
	c5 varchar(max),  --支援 LOB(2016)
	c6 uniqueidentifier default(newsequentialid()) unique,  --使用 unique 條件約束(2016)
	c7 int index idxC7 nonclustered(c7),	--超過 8 個索引(2017)
	c8 int index idxC8 nonclustered(c8),
	c9 int index idxC9 nonclustered(c9),
	c10 int index idxC10 nonclustered(c10),
	c11 int index idxC11 nonclustered(c11),
	c12 int index idxC12 nonclustered(c12),
	c13 int index idxC13 nonclustered(c13),
	c14 int index idxC14 nonclustered(c14),
   INDEX hash_index_sample_memoryoptimizedtable_c2 HASH (c2) WITH (BUCKET_COUNT = 131072)
) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA)
GO
set nocount on
declare @i int=1
while @i<1000
begin
	insert MemoryOptimizedTable(c2) values(1)
	set @i+=1
end

--查詢記憶體空間使用
exec sp_spaceused 'MemoryOptimizedTable' --似乎沒有值...
--用 sys.dm_db_xtp_table_memory_stats 查詢記憶體空間使用
SELECT t.object_id, t.name, 
	ISNULL((SELECT CONVERT(decimal(18,2),(TMS.memory_used_by_table_kb)/1024.00)), 0.00) AS table_used_memory_in_mb,
	ISNULL((SELECT CONVERT(decimal(18,2),(TMS.memory_allocated_for_table_kb - TMS.memory_used_by_table_kb)/1024.00)), 0.00) AS table_unused_memory_in_mb,
	ISNULL((SELECT CONVERT(decimal(18,2),(TMS.memory_used_by_indexes_kb)/1024.00)), 0.00) AS index_used_memory_in_mb,
	ISNULL((SELECT CONVERT(decimal(18,2),(TMS.memory_allocated_for_indexes_kb - TMS.memory_used_by_indexes_kb)/1024.00)), 0.00) AS index_unused_memory_in_mb
FROM sys.tables t JOIN sys.dm_db_xtp_table_memory_stats TMS ON (t.object_id = TMS.object_id)
go
--可以使用 top(n) with ties
-- case when
create procedure spNative
with native_compilation, schemabinding, execute as owner
as
begin atomic
with (transaction isolation level=snapshot, language=N'us_english')
	select top(10) with ties c1,c2,c3, 
	case when c4='Hello' then 'Hi' else c4 end c4Case
	from dbo.MemoryOptimizedTable
	order by c1
end
go
exec spNative

--可以使用 sp_rename
exec sp_rename 'spNative', 'spNewNative'

exec spNewNative

--因為 schemabinding 會失敗
exec sp_rename 'MemoryOptimizedTable','newMemoryOptimizedTable'

drop proc spNewNative
exec sp_rename 'MemoryOptimizedTable','newMemoryOptimizedTable'

select top(10) * from newMemoryOptimizedTable
