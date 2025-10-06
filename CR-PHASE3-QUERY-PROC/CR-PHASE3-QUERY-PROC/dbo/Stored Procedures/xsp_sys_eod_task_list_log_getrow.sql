CREATE procedure xsp_sys_eod_task_list_log_getrow
(
	@p_id int
)
as
begin
	select	id
			,eod_code
			,eod_date
			,start_time
			,end_time
			,status
			,reason
	from	sys_eod_task_list_log
	where	id = @p_id ;
end ;
