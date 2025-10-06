CREATE PROCEDURE dbo.xsp_insurance_policy_asset_coverage_getrows
(
	@p_keywords					nvarchar(50)
	,@p_pagenumber				int
	,@p_rowspage				int
	,@p_order_by				int
	,@p_sort_by					nvarchar(5)
	,@p_register_asset_code		nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	insurance_policy_asset_coverage ipac
	inner join dbo.insurance_policy_asset ipa on (ipa.code = ipac.register_asset_code)
	left join dbo.master_coverage mc on (mc.code = ipac.coverage_code)
	where	register_asset_code = @p_register_asset_code
	and		(
				rate_depreciation				like '%' + @p_keywords + '%'
				or	coverage_code				like '%' + @p_keywords + '%'
				or	year_periode				like '%' + @p_keywords + '%'
				or	initial_buy_rate			like '%' + @p_keywords + '%'
				or	initial_buy_amount			like '%' + @p_keywords + '%'
				or	initial_discount_pct		like '%' + @p_keywords + '%'
				or	initial_discount_amount		like '%' + @p_keywords + '%'
				or	initial_admin_fee_amount	like '%' + @p_keywords + '%'
				or	initial_stamp_fee_amount	like '%' + @p_keywords + '%'
				or	ipac.initial_discount_pph	like '%' + @p_keywords + '%'
				or	ipac.initial_discount_ppn	like '%' + @p_keywords + '%'
				or	buy_amount					like '%' + @p_keywords + '%'
				or	mc.coverage_name			like '%' + @p_keywords + '%'
			) ;

	select		id
				,register_asset_code
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
				,ipa.status_asset
				,ipac.initial_discount_pph
				,ipac.initial_discount_ppn
				-- (+) Ari 2024-01-08 ket : add tax
				,ipac.master_tax_code
				,ipac.master_tax_description
				,ipac.master_tax_ppn_pct
				,@rows_count 'rowcount'
	from		insurance_policy_asset_coverage ipac
	inner join dbo.insurance_policy_asset ipa on (ipa.code = ipac.register_asset_code)
	left join dbo.master_coverage mc on (mc.code = ipac.coverage_code)
	where		register_asset_code = @p_register_asset_code
	and			(
					rate_depreciation				like '%' + @p_keywords + '%'
					or	coverage_code				like '%' + @p_keywords + '%'
					or	year_periode				like '%' + @p_keywords + '%'
					or	initial_buy_rate			like '%' + @p_keywords + '%'
					or	initial_buy_amount			like '%' + @p_keywords + '%'
					or	initial_discount_pct		like '%' + @p_keywords + '%'
					or	initial_discount_amount		like '%' + @p_keywords + '%'
					or	initial_admin_fee_amount	like '%' + @p_keywords + '%'
					or	initial_stamp_fee_amount	like '%' + @p_keywords + '%'
					or	buy_amount					like '%' + @p_keywords + '%'
					or	mc.coverage_name			like '%' + @p_keywords + '%'
					or	ipac.initial_discount_pph	like '%' + @p_keywords + '%'
					or	ipac.initial_discount_ppn	like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then cast(ipac.year_periode as sql_variant)
													 when 2 then mc.coverage_name
													 when 3 then cast(ipac.rate_depreciation as sql_variant)
													 when 4 then cast(ipac.initial_discount_amount as sql_variant)
													 when 5 then cast(ipac.initial_admin_fee_amount as sql_variant)
													 when 6 then cast(ipac.initial_stamp_fee_amount as sql_variant)
													 when 7 then cast(ipac.buy_amount as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then cast(ipac.year_periode as sql_variant)
														when 2 then mc.coverage_name
														when 3 then cast(ipac.rate_depreciation as sql_variant)
														when 4 then cast(ipac.initial_discount_amount as sql_variant)
														when 5 then cast(ipac.initial_admin_fee_amount as sql_variant)
														when 6 then cast(ipac.initial_stamp_fee_amount as sql_variant)
														when 7 then cast(ipac.buy_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
