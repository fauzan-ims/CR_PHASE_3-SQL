CREATE procedure [dbo].[xsp_insurnace_policy_main_getrows_for_asset]
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_asset_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.insurance_policy_asset					ipa
			inner join dbo.insurance_policy_main		ipm on ipm.code			 = ipa.policy_code
			inner join dbo.insurance_policy_main_period ipmd on ipmd.policy_code = ipm.code
			inner join dbo.master_coverage				mc on mc.code			 = ipmd.coverage_code
	where	ipa.fa_code = @p_asset_code
			and
			(
				ipm.policy_no											like '%' + @p_keywords + '%'
				or	ipa.sum_insured_amount								like '%' + @p_keywords + '%'
				or	mc.coverage_name									like '%' + @p_keywords + '%'
				or	ipmd.year_periode									like '%' + @p_keywords + '%'
				or	convert(varchar(30), ipm.policy_eff_date, 103)		like '%' + @p_keywords + '%'
				or	convert(varchar(30), ipm.policy_exp_date, 103)		like '%' + @p_keywords + '%'
			) ;

	select		ipm.policy_no
				,ipa.sum_insured_amount
				,ipm.insured_name
				,mc.coverage_name
				,ipmd.year_periode
				,convert(varchar(30), ipm.policy_eff_date, 103) 'policy_eff_date'
				,convert(varchar(30), ipm.policy_exp_date, 103) 'policy_exp_date'
				,@rows_count									'rowcount'
	from		dbo.insurance_policy_asset					ipa
				inner join dbo.insurance_policy_main		ipm on ipm.code			 = ipa.policy_code
				inner join dbo.insurance_policy_main_period ipmd on ipmd.policy_code = ipm.code
				inner join dbo.master_coverage				mc on mc.code			 = ipmd.coverage_code
	where		ipa.fa_code = @p_asset_code
				and
				(
					ipm.policy_no											like '%' + @p_keywords + '%'
					or	ipa.sum_insured_amount								like '%' + @p_keywords + '%'
					or	mc.coverage_name									like '%' + @p_keywords + '%'
					or	ipmd.year_periode									like '%' + @p_keywords + '%'
					or	convert(varchar(30), ipm.policy_eff_date, 103)		like '%' + @p_keywords + '%'
					or	convert(varchar(30), ipm.policy_exp_date, 103)		like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ipm.policy_no
													 when 2 then cast(ipm.policy_eff_date as sql_variant)
													 when 3 then ipm.insured_name
													 when 4 then mc.coverage_name
													 when 5 then cast(ipmd.year_periode as sql_variant)
													 when 6 then cast(ipa.sum_insured_amount as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then ipm.policy_no
													   when 2 then cast(ipm.policy_eff_date as sql_variant)
													   when 3 then ipm.insured_name
													   when 4 then mc.coverage_name
													   when 5 then cast(ipmd.year_periode as sql_variant)
													   when 6 then cast(ipa.sum_insured_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
