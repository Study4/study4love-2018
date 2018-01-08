create proc spExecPackage @GUID uniqueidentifier
as
	Declare @execution_id bigint
	EXEC [SSISDB].[catalog].[create_execution] @package_name=N'Package.dtsx', @execution_id=@execution_id OUTPUT, @folder_name=N'test', @project_name=N'testScaleOut', @use32bitruntime=False, @reference_id=Null, @useanyworker=False, @runinscaleout=True
	Select @execution_id
	DECLARE @var0 smallint = 1
	EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id,  @object_type=50, @parameter_name=N'LOGGING_LEVEL', @parameter_value=@var0
	EXEC [SSISDB].[catalog].[add_execution_worker] @execution_id,  @workeragent_id=@GUID --N'dfd650ae-637d-4259-9008-46244436baee'
	EXEC [SSISDB].[catalog].[start_execution] @execution_id,  @retry_count=0
go

select row_number() over(order by LastOnlineTime) RowNo,WorkerAgentId into #tmp from ssisdb.catalog.worker_agents
declare @AgentID uniqueidentifier,@i int=1,@j int=1,@Total int=10,@count int=0
select @count=count(*) from #tmp

while @i<=@Total
begin
	while @j<=@count and @i<=@Total
	begin
		select @AgentID=WorkerAgentId from #tmp where RowNo=@j
		exec spExecPackage @AgentID
		select @i [Á`¦¸¼Æ],@AgentID [AgentID]
		set @j+=1
		set @i+=1
	end
	set @j=1
end
	
