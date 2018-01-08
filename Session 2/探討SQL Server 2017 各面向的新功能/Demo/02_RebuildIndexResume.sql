--不管 Recovery Mode 是 Simple、Bulk Load、Full 都可以
use Northwind
/*
create table tbBig(PK bigint identity primary key,
c1 nvarchar(100) default('Hello Index'),
CreateDate datetime2(3) default(sysdatetime()),
)
go
insert tbBig default values
go

--產生一千六百萬筆紀錄
insert tbBig(c1) select c1 from tbBig
go 24

insert tbBig(c1) values('hi')

create index idx on tbBig(c1)
go
*/
--超過一分鐘的錯誤訊息
/*
訊息 3643，層級 16，狀態 1，行 21
作業的經過時間已超過指定給此作業的時間上限。該執行已停止。
陳述式已經結束。
訊息 596，層級 21，狀態 1，行 20
工作階段為清除狀態，無法繼續執行。
訊息 0，層級 20，狀態 0，行 20
在目前的命令上發生嚴重錯誤。如果有任何結果，都必須捨棄。
*/
ALTER INDEX idx ON tbBig 
REBUILD WITH (RESUMABLE = ON, ONLINE = ON, MAX_DURATION=1, maxdop=1);


-------------------------------------------------
--在另一條連接上執行，中斷索引建置，會砍掉當下
--正在執行的這條連接
/*
訊息 1219，層級 16，狀態 1，行 18
您的工作階段已經因為高優先權的 DDL 作業而中斷連線。
訊息 1219，層級 16，狀態 1，行 18
您的工作階段已經因為高優先權的 DDL 作業而中斷連線。
訊息 596，層級 21，狀態 1，行 17
工作階段為清除狀態，無法繼續執行。
訊息 0，層級 20，狀態 0，行 17
在目前的命令上發生嚴重錯誤。如果有任何結果，都必須捨棄。
*/
ALTER INDEX idx ON tbBig PAUSE;

select * from sys.dm_db_log_stats(db_id('northwind'))

--可以清掉交易紀錄
backup log northwind to disk='nul'

--索引建一半時，修改資料內容，看續建時，變更是否進入
insert tbBig(c1) select top 100000 c1 from tbBig
insert tbBig(c1) values('New Data123')


 SELECT total_execution_time, percent_complete, page_count, *
	FROM  sys.index_resumable_operations;

select * from sysindexes where id= OBJECT_ID('tbBig')

--原先的索引依然可以用，做一半的索引會佔據 data file 的空間
select * from tbBig where c1='hi'
--舊索引也持續更新

select * from tbBig where c1='New Data123'

select max(pk) from tbBig


--從log_truncation_holdup_reason始終是 Nothing，看起來似乎未影響交易紀錄。
--但從 active_log_size_mb 和 active_vlf_count 持續長大看起來，且 recovery mode 是 simple，有待完成的索引會造成無法釋放交易紀錄
select log_truncation_holdup_reason,* from sys.dm_db_log_stats(db_id('Northwind'))


--執行1分鐘後自動停掉
ALTER INDEX idx ON tbBig 
RESUME WITH (MAX_DURATION = 1 );

--索引建一半時，修改資料內容，看續建時，變更是否進入...當然要進來 :)
select * from tbBig where c1='New Data123'

--放棄建一半的索引
ALTER INDEX idx ON tbBig 
abort;

