create procedure dbo.xsp_sys_calender_event_employee
	@p_employee_code nvarchar(50)
as
begin
	select	id
			,title
			,start
			,endday
			,classname
			,employee_code
	from	dbo.sys_calender_employee
	where   employee_code = @p_employee_code

end
