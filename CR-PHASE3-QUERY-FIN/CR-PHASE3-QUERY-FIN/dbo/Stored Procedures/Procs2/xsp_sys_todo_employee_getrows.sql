
CREATE PROCEDURE dbo.xsp_sys_todo_employee_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	declare @temptable table
	(
		employee_code  nvarchar(50)
		,employee_name nvarchar(250)
	) ;

	insert into @temptable
	(
		employee_code
		,employee_name
	)
	select distinct
			employee_code
			,employee_name
	from	dbo.sys_todo_employee ;

	select	@rows_count = count(1)
	from	@temptable
	where	(
				employee_code									like '%' + @p_keywords + '%'
				or	employee_name								like '%' + @p_keywords + '%'
			) ;

	select		employee_code
				,employee_name
				,@rows_count 'rowcount'
	from		@temptable
	where		(
				employee_code									like '%' + @p_keywords + '%'
				or	employee_name								like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then employee_code
													 when 2 then employee_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then employee_code
													   when 2 then employee_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
