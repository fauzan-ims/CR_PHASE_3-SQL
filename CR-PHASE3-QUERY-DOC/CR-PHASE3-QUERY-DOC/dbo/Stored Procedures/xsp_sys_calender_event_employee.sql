create PROCEDURE dbo.xsp_sys_calender_event_employee
	@p_employee_code nvarchar(50)
	--,@p_year nvarchar(4)
	--,@p_month nvarchar(2)
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
			--and left(start,4) = @p_year
			--and right(left(start,7),2) = @p_month


end
