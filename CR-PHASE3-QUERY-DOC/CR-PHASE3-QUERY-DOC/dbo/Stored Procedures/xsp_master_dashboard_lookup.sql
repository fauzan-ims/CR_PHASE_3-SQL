CREATE PROCEDURE dbo.xsp_master_dashboard_lookup
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_employee_code nvarchar(50)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_dashboard	
	where	is_active = '1'
			and code not in
				(
					select	isnull(dashboard_code, '')
					from	dbo.master_dashboard_user
					where employee_code = @p_employee_code
				)
			and (
					code				like '%' + @p_keywords + '%'
					or	dashboard_name	like '%' + @p_keywords + '%'
				) ;

	select		code
				,dashboard_name
				,@rows_count 'rowcount'
	from		master_dashboard
	where		is_active = '1'
				and code not in
					(
						select	isnull(dashboard_code, '')
						from	dbo.master_dashboard_user
						where employee_code = @p_employee_code
					)
				and (
						code				like '%' + @p_keywords + '%'
						or	dashboard_name	like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then code
													 when 2 then dashboard_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then code
													   when 2 then dashboard_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
