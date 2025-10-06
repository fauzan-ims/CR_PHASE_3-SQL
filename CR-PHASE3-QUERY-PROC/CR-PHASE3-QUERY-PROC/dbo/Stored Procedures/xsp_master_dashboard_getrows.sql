CREATE PROCEDURE dbo.xsp_master_dashboard_getrows
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

	select	@rows_count = count(1)
	from	master_dashboard
	where	(
				code				like '%' + @p_keywords + '%'
				or	dashboard_name	like '%' + @p_keywords + '%'
				or	dashboard_type	like '%' + @p_keywords + '%'
				or	dashboard_grid	like '%' + @p_keywords + '%'
				or	sp_name			like '%' + @p_keywords + '%'
				or	case is_active
						when '1' then 'ACTIVE'
						else 'INACTIVE'
					end				like '%' + @p_keywords + '%'
			) ;

	select		code
				,dashboard_name
				,dashboard_type
				,case dashboard_grid
					when 'col-md-12' then 'Full'
					when 'col-md-6' then 'Half'
					when 'col-md-4' then 'Third'
					when 'col-md-3' then 'Quarter'
				end 'dashboard_grid'
				,sp_name
				,case is_active
					 when '1' then 'ACTIVE'
					 else 'INACTIVE'
				 end 'is_active'
				,case is_editable
					 when '1' then 'YES'
					 else 'NO'
				 end 'is_editable'
				,@rows_count 'rowcount'
	from		master_dashboard
	where		(
					code				like '%' + @p_keywords + '%'
					or	dashboard_name	like '%' + @p_keywords + '%'
					or	dashboard_type	like '%' + @p_keywords + '%'
					or	dashboard_grid	like '%' + @p_keywords + '%'
					or	sp_name			like '%' + @p_keywords + '%'
					or	case is_active
							when '1' then 'ACTIVE'
							else 'INACTIVE'
						end				like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then code
													 when 2 then dashboard_name
													 when 3 then dashboard_type
													 when 4 then dashboard_grid
													 when 5 then sp_name
													 when 6 then is_active
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then code
													   when 2 then dashboard_name
													   when 3 then dashboard_type
													   when 4 then dashboard_grid
													   when 5 then sp_name
													   when 6 then is_active
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
