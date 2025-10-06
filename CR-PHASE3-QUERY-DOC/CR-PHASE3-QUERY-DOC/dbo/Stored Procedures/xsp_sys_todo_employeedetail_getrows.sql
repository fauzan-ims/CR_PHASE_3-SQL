CREATE PROCEDURE dbo.xsp_sys_todo_employeedetail_getrows
(
	@p_keywords		  nvarchar(50)
	,@p_pagenumber	  int
	,@p_rowspage	  int
	,@p_order_by	  int
	,@p_sort_by		  nvarchar(5)
	,@p_employee_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.sys_todo_employee ste
	inner join dbo.sys_todo st on (st.code = ste.todo_code)
	where	employee_code = @p_employee_code
			and (
					ste.id						like '%' + @p_keywords + '%'
					or ste.employee_code		like '%' + @p_keywords + '%'
					or	ste.employee_name		like '%' + @p_keywords + '%'
					or	st.todo_name			like '%' + @p_keywords + '%'
					or	ste.priority			like '%' + @p_keywords + '%'
				) ;

	select		ste.id
				,ste.employee_code
				,ste.employee_name
				,st.todo_name
				,ste.priority
				,@rows_count 'rowcount'
	from		dbo.sys_todo_employee ste
	inner join dbo.sys_todo st on (st.code = ste.todo_code)
	where		employee_code = @p_employee_code
				and (
					ste.id						like '%' + @p_keywords + '%'
					or ste.employee_code		like '%' + @p_keywords + '%'
					or	ste.employee_name		like '%' + @p_keywords + '%'
					or	st.todo_name			like '%' + @p_keywords + '%'
					or	ste.priority			like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ste.employee_code
													 when 2 then ste.employee_name
													 when 3 then st.todo_name
													 when 4 then ste.priority
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then ste.employee_code
													   when 2 then ste.employee_name
													   when 3 then st.todo_name
													   when 4 then ste.priority
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
