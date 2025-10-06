--created by, Rian at 11/05/2023	

CREATE PROCEDURE dbo.xsp_asset_insurance_detail_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	--
	,@p_asset_no   nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.asset_insurance_detail aid
	where	aid.asset_no = @p_asset_no
			and (
					aid.id									like '%' + @p_keywords + '%'
					or	aid.asset_no						like '%' + @p_keywords + '%'
					or	aid.main_coverage_description		like '%' + @p_keywords + '%'
					or	aid.region_description				like '%' + @p_keywords + '%'
					or	aid.tpl_coverage_description		like '%' + @p_keywords + '%'
					or	aid.pll_coverage_description		like '%' + @p_keywords + '%'
					or	aid.total_premium_amount			like '%' + @p_keywords + '%'
				) ;

	select		aid.id
				,aid.asset_no
				,aid.main_coverage_code
				,aid.main_coverage_description
				,aid.region_code
				,aid.region_description
				,aid.tpl_coverage_code
				,aid.tpl_coverage_description
				,aid.pll_coverage_code
				,aid.pll_coverage_description
				,aid.total_premium_amount
				,@rows_count 'rowcount'
	from		dbo.asset_insurance_detail aid
	where		aid.asset_no = @p_asset_no
				and (
						aid.id									like '%' + @p_keywords + '%'
						or	aid.asset_no						like '%' + @p_keywords + '%'
						or	aid.main_coverage_description		like '%' + @p_keywords + '%'
						or	aid.region_description				like '%' + @p_keywords + '%'
						or	aid.tpl_coverage_description		like '%' + @p_keywords + '%'
						or	aid.pll_coverage_description		like '%' + @p_keywords + '%'
						or	aid.total_premium_amount			like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then aid.asset_no
													 when 2 then aid.main_coverage_description
													 when 3 then aid.region_description
													 when 4 then aid.tpl_coverage_description
													 when 5 then aid.pll_coverage_description
													 when 6 then cast(aid.total_premium_amount as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then aid.asset_no
														when 2 then aid.main_coverage_description
														when 3 then aid.region_description
														when 4 then aid.tpl_coverage_description
														when 5 then aid.pll_coverage_description
														when 6 then cast(aid.total_premium_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
