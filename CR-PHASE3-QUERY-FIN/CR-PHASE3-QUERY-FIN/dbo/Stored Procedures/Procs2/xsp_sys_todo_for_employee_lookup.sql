
CREATE PROCEDURE dbo.xsp_sys_todo_for_employee_lookup

	@p_keywords		  nvarchar(50)
	,@p_pagenumber	  int
	,@p_rowspage	  int
	,@p_order_by	  int
	,@p_sort_by		  nvarchar(5)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.sys_todo
	where	is_active = '1'
			and  (
					code									like '%' + @p_keywords + '%'
					or	todo_name							like '%' + @p_keywords + '%'
				) ;

	select		code
				,todo_name
				,@rows_count 'rowcount'
				,case is_active
					 when '1' then 'Yes'
					 else 'No'
				 end 'is_active'
	from		dbo.sys_todo
	where		is_active = '1'
				and  (
					code									like '%' + @p_keywords + '%'
					or	todo_name							like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then code
													 when 2 then todo_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then code
													   when 2 then todo_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
