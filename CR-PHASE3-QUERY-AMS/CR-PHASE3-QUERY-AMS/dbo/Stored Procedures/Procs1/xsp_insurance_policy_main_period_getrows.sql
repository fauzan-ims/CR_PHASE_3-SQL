CREATE PROCEDURE dbo.xsp_insurance_policy_main_period_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_policy_code  nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;



	select	@rows_count = count(1)
	from	insurance_policy_main_period ipmp
			inner join dbo.master_coverage mc on (mc.code = ipmp.coverage_code)
			outer apply
			(
				select	distinct
						sum(ipac.buy_amount) 'sum_coverage_premi_amount'
				from	dbo.insurance_policy_asset					  ipa
						left join dbo.insurance_policy_asset_coverage ipac on (ipac.register_asset_code = ipa.code)
				where	ipa.policy_code = ipmp.policy_code and ipac.year_periode=ipmp.year_periode
				group by	ipac.coverage_code, ipac.year_periode
			) asset
	where	policy_code = @p_policy_code
			and (
					ipmp.year_periode						like '%' + @p_keywords + '%'
					or	mc.coverage_name					like '%' + @p_keywords + '%'
					or	case ipmp.is_main_coverage	
							when '1' then 'Yes'
							else 'No'
						end									like '%' + @p_keywords + '%'
					or	asset.sum_coverage_premi_amount		like '%' + @p_keywords + '%'
				) ;

	
		select		ipmp.code
					,ipmp.year_periode
					,mc.coverage_name
					,case ipmp.is_main_coverage
						 when '1' then 'Yes'
						 else 'No'
					 end 'is_main_coverage'	
					,ipmp.buy_amount
					,ipmp.discount_pct
					,ipmp.discount_amount
					,ipmp.admin_fee_amount
					,ipmp.stamp_fee_amount
					,ipmp.adjustment_amount
					,ipmp.total_buy_amount
					,asset.sum_coverage_premi_amount
					,@rows_count 'rowcount'
		from		insurance_policy_main_period ipmp
					inner join dbo.master_coverage mc on (mc.code = ipmp.coverage_code)
					outer apply
					(
						select	distinct
								sum(ipac.buy_amount) 'sum_coverage_premi_amount'
						from	dbo.insurance_policy_asset					  ipa
								left join dbo.insurance_policy_asset_coverage ipac on (ipac.register_asset_code = ipa.code)
						where	ipa.policy_code = ipmp.policy_code and ipac.year_periode=ipmp.year_periode
						group by	ipac.coverage_code, ipac.year_periode
					) asset
		where		policy_code = @p_policy_code
					and (
							ipmp.year_periode						like '%' + @p_keywords + '%'
							or	mc.coverage_name					like '%' + @p_keywords + '%'
							or	case ipmp.is_main_coverage	
									when '1' then 'Yes'
									else 'No'
								end									like '%' + @p_keywords + '%'
							or	asset.sum_coverage_premi_amount		like '%' + @p_keywords + '%'
						) 
		order by case when @p_sort_by = 'asc' then case @p_order_by
													when 1 then cast(ipmp.year_periode as sql_variant)
													when 2 then cast(asset.sum_coverage_premi_amount as sql_variant)
													when 3 then mc.coverage_name
													when 4 then ipmp.is_main_coverage
												   end
					end asc 
					,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then cast(ipmp.year_periode as sql_variant)
													when 2 then cast(asset.sum_coverage_premi_amount as sql_variant)
													when 3 then mc.coverage_name
													when 4 then ipmp.is_main_coverage
												   end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;

