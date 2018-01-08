--string_agg
select * into #tmp from (values('a','a2'),('a','a1'),('b','b3'),('b','b1')) t(c1,c2)
select string_agg(c2,',') from #tmp
--依群組彙總字串
select c1,string_agg(c2,',') from #tmp group by c1
--彙總字串時需要排序
select c1,string_agg(c2,',') within group(order by c2) from #tmp group by c1

--trim
declare @s varchar(100)=' Hello trim '
select datalength(@s),trim(@s),datalength(trim(@s))

--TRANSLATE(inputString, characters, translations) ，characters 和 translations 的字元一對一對應取代
SELECT TRANSLATE('2*[3+4]/{7-2}', '[]{}', '()()');
--等同
SELECT REPLACE(REPLACE(REPLACE(REPLACE('2*[3+4]/{7-2}','[','('), ']', ')'), '{', '('), '}', ')');
--char,nchar,varchar,nvarchar 都可以
select translate('你說你好嗎','你好嗎','我很好')
go

;with tr
as
(
select address,
replace(
replace(
translate(
translate(
translate(
translate(address,'０１２３４５６７８９','0123456789')
--collate Chinese_Taiwan_Stroke_CS_AS_WS
,'零一二三四五六七八九','0123456789')
,'壹貳叁肆伍陸柒捌玖','123456789')
,'-fF','之樓樓'),
' ',''),
'　','') longWay
 from (values
(N'民權東路 三 段　３　７　號 2 樓之 壹'),
(N'民權東路 三 段　３　７　號 2 F- 壹'),
(N'３　７')) t(address)
)
select address,convert(varbinary(max),address),
longWay,convert(varbinary(max),longWay) from tr
go

;with tr
as
(
select address,
replace(
replace(
translate(address,'０１２３４５６７８９零一二三四五六七八九壹貳叁肆伍陸柒捌玖-fF','01234567890123456789123456789之樓樓'),
' ',''),
'　','') longWay
 from (values
(N'民權東路 三 段　３　７　號 2 樓之 壹'),
(N'民權東路 三 段　３　７　號 2 F- 壹'),
(N'３　７')) t(address)
)
select address,convert(varbinary(max),address),
longWay,convert(varbinary(max),longWay) from tr
go

--CONCAT_WS ( separator, argument1, argument1 [, argumentN]… ) 
--忽略SET CONCAT_NULL_YIELDS_NULL {ON|OFF}設定。如果所有引數為 null、 空字串型別的varchar(1)傳回
--比 concat 函數多了分隔符號

--全部 char/varchar 結果 varchar
select datalength(CONCAT_WS(',','a','b'))
--其中一個 nchar/nvarchar，結果 nvarchar
select datalength(CONCAT_WS(N',','a','b'))

select datalength(CONCAT_WS(',','a',N'b'))

SELECT 
CONCAT_WS( ',', database_id, recovery_model_desc, containment_desc) AS dbInfo
FROM sys.databases

--以逗號組合
select CONCAT_WS(',',1,2.30,NULL,'a',N'b',getdate())

--搭配 String_agg 產生符號分隔檔
declare @col varchar(10)='	'  --tab 鍵
declare @row varchar(10)='
' 
SELECT 
STRING_AGG(CONCAT_WS(@col, 
database_id, recovery_model_desc, 
containment_desc), @row) AS DatabaseInfo
FROM sys.databases