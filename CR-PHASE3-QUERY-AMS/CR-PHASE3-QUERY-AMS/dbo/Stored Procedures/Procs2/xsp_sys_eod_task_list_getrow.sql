create procedure xsp_sys_eod_task_list_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,name
			,sp_name
			,order_no
			,is_done
			,is_active
	from	sys_eod_task_list
	where	code = @p_code ;
end ;
