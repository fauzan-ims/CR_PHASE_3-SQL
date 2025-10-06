create procedure dbo.xsp_sys_todo_employeedetail_update_priority
	@p_id		 bigint
	,@p_priority nvarchar(10)
as
begin
	update	dbo.sys_todo_employee
	set		priority = @p_priority
	where	id = @p_id ;
end ;
