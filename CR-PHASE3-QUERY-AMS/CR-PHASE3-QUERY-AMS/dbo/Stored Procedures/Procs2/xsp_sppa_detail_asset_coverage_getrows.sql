CREATE PROCEDURE dbo.xsp_sppa_detail_asset_coverage_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_sppa_detail_id	bigint
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	sppa_detail_asset_coverage sc
	left join dbo.master_coverage mc on (mc.code = sc.coverage_code)
	where	 sc.sppa_detail_id = @p_sppa_detail_id
	and		(
				rate_depreciation					like '%' + @p_keywords + '%'
				or	coverage_code					like '%' + @p_keywords + '%'
				or	mc.coverage_name				like '%' + @p_keywords + '%'
				or	year_periode					like '%' + @p_keywords + '%'
				or	initial_discount_amount			like '%' + @p_keywords + '%'
				or	initial_admin_fee_amount		like '%' + @p_keywords + '%'
				or	initial_stamp_fee_amount		like '%' + @p_keywords + '%'
				or	buy_amount						like '%' + @p_keywords + '%'
			) ;

	select		id
				,sppa_detail_id
				,rate_depreciation
				,case is_loading
					 when '1' then 'YES'
					 else 'NO'
				 end 'is_loading'
				,coverage_code
				,mc.coverage_name
				,year_periode
				,initial_buy_rate
				,initial_buy_amount
				,initial_discount_pct
				,initial_discount_amount
				,initial_admin_fee_amount
				,initial_stamp_fee_amount
				,buy_amount
				,@rows_count 'rowcount'
	from		sppa_detail_asset_coverage sc
	left join dbo.master_coverage mc on (mc.code = sc.coverage_code)
	where		sc.sppa_detail_id = @p_sppa_detail_id
	and			(
					rate_depreciation					like '%' + @p_keywords + '%'
					or	coverage_code					like '%' + @p_keywords + '%'
					or	mc.coverage_name				like '%' + @p_keywords + '%'
					or	year_periode					like '%' + @p_keywords + '%'
					or	initial_discount_amount			like '%' + @p_keywords + '%'
					or	initial_admin_fee_amount		like '%' + @p_keywords + '%'
					or	initial_stamp_fee_amount		like '%' + @p_keywords + '%'
					or	buy_amount						like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then cast(sc.year_periode as sql_variant)
													 when 2 then mc.coverage_name
													 when 3 then cast(sc.rate_depreciation as sql_variant)
													 when 4 then cast(sc.initial_discount_amount as sql_variant)
													 when 5 then cast(sc.initial_admin_fee_amount as sql_variant)
													 when 6 then cast(sc.initial_stamp_fee_amount as sql_variant)
													 when 7 then cast(sc.buy_amount as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then cast(sc.year_periode as sql_variant)
													   when 2 then mc.coverage_name
													   when 3 then cast(sc.rate_depreciation as sql_variant)
													   when 4 then cast(sc.initial_discount_amount as sql_variant)
													   when 5 then cast(sc.initial_admin_fee_amount as sql_variant)
													   when 6 then cast(sc.initial_stamp_fee_amount as sql_variant)
													   when 7 then cast(sc.buy_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
