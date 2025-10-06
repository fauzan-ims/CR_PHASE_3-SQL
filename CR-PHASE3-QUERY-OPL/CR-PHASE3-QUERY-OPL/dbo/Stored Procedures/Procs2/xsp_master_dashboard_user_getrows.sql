CREATE PROCEDURE dbo.xsp_master_dashboard_user_getrows
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
	declare @employee table (employee_code nvarchar(50))

	insert into @employee
	(
		employee_code
	)
	select distinct employee_code 
	from dbo.master_dashboard_user

	select	@rows_count = count(1)
	from	@employee e
			outer apply (select top 1 u.id, u.employee_name from dbo.master_dashboard_user u where u.employee_code = e.employee_code) data
	where	(
				employee_code			like '%' + @p_keywords + '%'
				or	employee_name		like '%' + @p_keywords + '%'
			) ;

	select		id
				,employee_code
				,employee_name
				,@rows_count 'rowcount'
	from		@employee e
				outer apply (select top 1 u.id, u.employee_name from dbo.master_dashboard_user u where u.employee_code = e.employee_code) data
	where		(
					employee_code				like '%' + @p_keywords + '%'
					or	employee_name			like '%' + @p_keywords + '%'
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
