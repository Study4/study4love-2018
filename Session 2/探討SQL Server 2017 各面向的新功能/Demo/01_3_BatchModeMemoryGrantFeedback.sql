use WideWorldImportersDW
go
create proc FactOrderByLineageKey @LineageKey int
as
	select fo.[Order Key],fo.Description
	from fact.[Order] as fo
	inner hash join Dimension.[Stock Item] as si
	on fo.[Stock Item Key]=si.[Stock Item Key]
	where fo.[Lineage Key]=@LineageKey
	and si.[Lead Time Days]>0
	order by fo.[Stock Item Key], fo.[Order Date Key] desc
go
--可以兩個彼此交換執行，第一次會估算錯誤，第二次就會正確
--透過執行後執行計畫，看警告訊息，會有使用 tempdb 溢出(spill)資料，看整句 Select 語法，可以看到給予記憶體的量
exec FactOrderByLineageKey 8  --符合的紀錄數 0 筆

exec FactOrderByLineageKey 9  --符合的紀錄數 23 萬
