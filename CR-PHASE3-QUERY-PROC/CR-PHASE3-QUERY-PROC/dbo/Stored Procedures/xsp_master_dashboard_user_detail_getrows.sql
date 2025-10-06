create PROCEDURE dbo.xsp_master_dashboard_user_detail_getrows
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
	from	master_dashboard_user mdu
			inner join dbo.master_dashboard md on md.code = mdu.dashboard_code
	where	mdu.employee_code = @p_employee_code
			and (
					id										like '%' + @p_keywords + '%'
					or	md.dashboard_name					like '%' + @p_keywords + '%'
					or	case md.dashboard_grid
							when 'col-md-12' then 'Full'
							when 'col-md-6' then 'Half'
							when 'col-md-4' then 'Third'
							when 'col-md-3' then 'Quarter'
						end									like '%' + @p_keywords + '%'
					or	mdu.order_key						like '%' + @p_keywords + '%'
				) ;

	select		id
				,mdu.dashboard_code
				,md.dashboard_name
				,case md.dashboard_grid
					 when 'col-md-12' then 'Full'
					 when 'col-md-6' then 'Half'
					 when 'col-md-4' then 'Third'
					 when 'col-md-3' then 'Quarter'
				 end 'dashboard_grid'
				,order_key
				,@rows_count 'rowcount'
	from		master_dashboard_user mdu
				inner join dbo.master_dashboard md on md.code = mdu.dashboard_code
	where		mdu.employee_code = @p_employee_code
				and (
						id										like '%' + @p_keywords + '%'
						or	md.dashboard_name					like '%' + @p_keywords + '%'
						or	case md.dashboard_grid
								when 'col-md-12' then 'Full'
								when 'col-md-6' then 'Half'
								when 'col-md-4' then 'Third'
								when 'col-md-3' then 'Quarter'
							end									like '%' + @p_keywords + '%'
						or	mdu.order_key						like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then md.dashboard_name
													 when 2 then md.dashboard_grid
													 when 3 then cast(mdu.order_key as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then md.dashboard_name
													   when 2 then md.dashboard_grid
													   when 3 then cast(mdu.order_key as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
