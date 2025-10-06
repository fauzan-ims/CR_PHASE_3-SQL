
CREATE PROCEDURE dbo.xsp_sys_todo_employeedetail_getrow
(
	@p_id bigint
)
as
begin
	select	ste.id
			,ste.employee_code
			,ste.employee_name
			,ste.todo_code
			,st.todo_name 'description'
	from	dbo.sys_todo_employee ste
			inner join dbo.sys_todo st on (st.code = ste.todo_code)
	where	ste.id = @p_id ;
end ;
