CREATE PROCEDURE [dbo].[xsp_insurance_register_asset_getrows]
(
	@p_keywords		  nvarchar(50)
	,@p_pagenumber	  int
	,@p_rowspage	  int
	,@p_order_by	  int
	,@p_sort_by		  nvarchar(5)
	,@p_register_code nvarchar(50)
	,@p_insert_type	  nvarchar(20)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	insurance_register_asset	ira
			left join dbo.asset			ass on (ass.code = ira.fa_code)
			left join dbo.asset_vehicle av on (ass.code = av.asset_code)
			outer apply
	(
		select	max(ipm.policy_exp_date) 'policy_exp_date'
		from	dbo.insurance_policy_asset			 ipa
				inner join dbo.insurance_policy_main ipm on ipm.code = ipa.policy_code
		where	ipa.fa_code = av.asset_code
	)									policy
	where	ira.register_code	= @p_register_code
			and ira.insert_type = case @p_insert_type
									  when 'ALL' then ira.insert_type
									  else @p_insert_type
								  end
			and
			(
				ira.fa_code												like '%' + @p_keywords + '%'
				or	ass.item_name										like '%' + @p_keywords + '%'
				or	av.plat_no											like '%' + @p_keywords + '%'
				or	av.engine_no										like '%' + @p_keywords + '%'
				or	av.chassis_no										like '%' + @p_keywords + '%'
				or	ira.sum_insured_amount								like '%' + @p_keywords + '%'
				or	built_year											like '%' + @p_keywords + '%'
				or	ass.rental_status									like '%' + @p_keywords + '%'
				or	ass.client_name										like '%' + @p_keywords + '%'
				or	convert(varchar(50), policy.policy_exp_date, 103)	like '%' + @p_keywords + '%'
				or	ass.status											like '%' + @p_keywords + '%'
				or	ass.fisical_status									like '%' + @p_keywords + '%'
				or	ass.agreement_external_no							like '%' + @p_keywords + '%'
			) ;

	select		ira.code
				,ira.register_code
				,ira.fa_code
				,ass.item_name
				,av.plat_no
				,av.engine_no
				,av.chassis_no
				,ira.sum_insured_amount
				,ira.depreciation_code
				,ira.collateral_type
				,ira.collateral_category_code
				,ira.occupation_code
				,ira.region_code
				,ira.collateral_year
				,av.built_year
				,ira.insert_type
				,case ira.is_authorized_workshop
					 when '1' then 'YES'
					 else 'NO'
				 end											   'is_authorized_workshop'
				,case ira.is_commercial
					 when '1' then 'YES'
					 else 'NO'
				 end											   'is_commercial'
				,ass.rental_status
				,ass.client_name
				,convert(varchar(50), policy.policy_exp_date, 103) 'policy_exp_date'
				,ass.status
				,ass.fisical_status
				,ass.agreement_external_no
				,@rows_count									   'rowcount'
	from		insurance_register_asset	ira
				left join dbo.asset			ass on (ass.code = ira.fa_code)
				left join dbo.asset_vehicle av on (ass.code = av.asset_code)
				outer apply
	(
		select	max(ipm.policy_exp_date) 'policy_exp_date'
		from	dbo.insurance_policy_asset			 ipa
				inner join dbo.insurance_policy_main ipm on ipm.code = ipa.policy_code
		where	ipa.fa_code = av.asset_code
	)										policy
	where		ira.register_code	= @p_register_code
				and ira.insert_type = case @p_insert_type
										  when 'ALL' then ira.insert_type
										  else @p_insert_type
									  end
				and
				(
					ira.fa_code												like '%' + @p_keywords + '%'
					or	ass.item_name										like '%' + @p_keywords + '%'
					or	av.plat_no											like '%' + @p_keywords + '%'
					or	av.engine_no										like '%' + @p_keywords + '%'
					or	av.chassis_no										like '%' + @p_keywords + '%'
					or	ira.sum_insured_amount								like '%' + @p_keywords + '%'
					or	built_year											like '%' + @p_keywords + '%'
					or	ass.rental_status									like '%' + @p_keywords + '%'
					or	ass.client_name										like '%' + @p_keywords + '%'
					or	convert(varchar(50), policy.policy_exp_date, 103)	like '%' + @p_keywords + '%'
					or	ass.status											like '%' + @p_keywords + '%'
					or	ass.fisical_status									like '%' + @p_keywords + '%'
					or	ass.agreement_external_no							like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ira.fa_code + ass.item_name
													 when 2 then av.plat_no + av.engine_no + av.chassis_no
													 when 3 then ass.status
													 when 4 then av.built_year
													 when 5 then ass.agreement_external_no
													 when 6 then cast(ira.sum_insured_amount as sql_variant)
													 when 7 then ira.insert_type
													 when 8 then cast(policy.policy_exp_date as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then ira.fa_code + ass.item_name
													   when 2 then av.plat_no + av.engine_no + av.chassis_no
													   when 3 then ass.status
													   when 4 then av.built_year
													   when 5 then ass.agreement_external_no
													   when 6 then cast(ira.sum_insured_amount as sql_variant)
													   when 7 then ira.insert_type
													   when 8 then cast(policy.policy_exp_date as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
