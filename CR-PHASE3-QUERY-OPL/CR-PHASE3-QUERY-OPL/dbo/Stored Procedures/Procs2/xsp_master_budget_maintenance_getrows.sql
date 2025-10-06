--created by, Rian at 12/05/2023	

CREATE PROCEDURE dbo.xsp_master_budget_maintenance_getrows
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
	from	dbo.master_budget_maintenance  mbm
	where	(
				mbm.code											like '%' + @p_keywords + '%'
				or	mbm.unit_description							like '%' + @p_keywords + '%'
				or	mbm.year										like '%' + @p_keywords + '%'
				or	mbm.inflation									like '%' + @p_keywords + '%'
				or	case mbm.location when 'CITY' then 'CITY USE'
						else 'SITE'
					end												like '%' + @p_keywords + '%'
				or	convert(varchar(30), mbm.eff_date, 103)			like '%' + @p_keywords + '%'
				or	convert(varchar(30), mbm.exp_date, 103)			like '%' + @p_keywords + '%'
				or	case	mbm.is_active when '1' then 'Yes'
						else 'No'
					end												like '%' + @p_keywords + '%'
			) ;

	select		mbm.code
				,mbm.unit_code
				,mbm.unit_description
				,mbm.year
				,mbm.inflation
				,case mbm.location when 'CITY' then 'CITY USE'
					else 'SITE'
				end 'location'
				,convert(varchar(30), mbm.eff_date, 103) 'eff_date'
				,convert(varchar(30), mbm.exp_date, 103) 'exp_date'
				,case	mbm.is_active when '1' then 'Yes'
					else 'No'
				end 'is_active'
				,@rows_count 'rowcount'
	from		dbo.master_budget_maintenance mbm
	where		(
					mbm.code											like '%' + @p_keywords + '%'
					or	mbm.unit_description							like '%' + @p_keywords + '%'
					or	mbm.year										like '%' + @p_keywords + '%'
					or	mbm.inflation									like '%' + @p_keywords + '%'
					or	case mbm.location when 'CITY' then 'CITY USE'
							else 'SITE'
						end												like '%' + @p_keywords + '%'
					or	convert(varchar(30), mbm.eff_date, 103)			like '%' + @p_keywords + '%'
					or	convert(varchar(30), mbm.exp_date, 103)			like '%' + @p_keywords + '%'
					or	case	mbm.is_active when '1' then 'Yes'
							else 'No'
						end												like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then mbm.code
													 when 2 then cast(mbm.eff_date as sql_variant)
													 when 3 then cast(mbm.exp_date as sql_variant)
													 when 4 then mbm.unit_description
													 when 5 then cast(mbm.year as sql_variant)
													 when 6 then cast(mbm.inflation as sql_variant)
													 when 7 then mbm.location
													 when 8 then mbm.is_active
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then mbm.code
														when 2 then cast(mbm.eff_date as sql_variant)
														when 3 then cast(mbm.exp_date as sql_variant)
														when 4 then mbm.unit_description
														when 5 then cast(mbm.year as sql_variant)
														when 6 then cast(mbm.inflation as sql_variant)
														when 7 then mbm.location
														when 8 then mbm.is_active
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
