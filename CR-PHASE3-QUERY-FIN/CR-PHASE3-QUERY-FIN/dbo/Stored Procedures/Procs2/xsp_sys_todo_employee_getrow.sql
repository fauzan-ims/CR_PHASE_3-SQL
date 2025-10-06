CREATE PROCEDURE dbo.xsp_sys_todo_employee_getrow
(
	@p_employee_code nvarchar(50)
)
as
begin
	select top 1
			ste.id
			,ste.employee_code
			,ste.employee_name
			,ste.todo_code
			,st.todo_name

	from	dbo.sys_todo_employee ste
			inner join dbo.sys_todo st on (st.code = ste.todo_code)
	where	employee_code = @p_employee_code ;
end ;
