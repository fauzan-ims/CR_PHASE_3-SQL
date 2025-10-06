CREATE PROCEDURE [dbo].[xsp_insurance_policy_asset_getrows]
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_policy_code		nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	insurance_policy_asset ipa
	left join asset ass on (ass.code = ipa.fa_code)
	left join dbo.asset_vehicle av on (av.asset_code = ass.code)
	left join dbo.master_depreciation md on (md.code = ipa.depreciation_code)
	left join dbo.master_occupation mo on (mo.code = ipa.occupation_code)
	left join dbo.master_region mr on (mr.code = ipa.region_code)
	outer apply(select sum(ipac.buy_amount) 'total_coverage_premi_amount' from dbo.insurance_policy_asset_coverage ipac where ipac.register_asset_code = ipa.code) asset
	where	policy_code = @p_policy_code
	and		(
				fa_code								like '%' + @p_keywords + '%'
				or	ass.item_name					like '%' + @p_keywords + '%'
				or	av.plat_no						like '%' + @p_keywords + '%'
				or	av.colour						like '%' + @p_keywords + '%'
				or	sum_insured_amount				like '%' + @p_keywords + '%'
				or	md.depreciation_name			like '%' + @p_keywords + '%'
				or	mo.occupation_name				like '%' + @p_keywords + '%'
				or	mr.region_name					like '%' + @p_keywords + '%'
				or	ipa.status_asset				like '%' + @p_keywords + '%'
			) ;

	select		ipa.code
				,policy_code
				,fa_code
				,ass.item_name
				,av.plat_no
				,av.colour
				,sum_insured_amount
				,depreciation_code
				,md.depreciation_name
				,collateral_type
				,collateral_category_code
				,ipa.occupation_code
				,mo.occupation_name
				,region_code
				,mr.region_name
				,collateral_year
				,case is_authorized_workshop
					 when '1' then 'YES'
					 else 'NO'
				 end 'is_authorized_workshop'
				,case is_commercial
					 when '1' then 'YES'
					 else 'NO'
				 end 'is_commercial'
				 ,asset.total_coverage_premi_amount
				 ,ipa.status_asset
				,@rows_count 'rowcount'
	from		insurance_policy_asset ipa
	left join asset ass on (ass.code = ipa.fa_code)
	left join dbo.master_depreciation md on (md.code = ipa.depreciation_code)
	left join dbo.asset_vehicle av on (av.asset_code = ass.code)
	left join dbo.master_occupation mo on (mo.code = ipa.occupation_code)
	left join dbo.master_region mr on (mr.code = ipa.region_code)
	outer apply(select sum(ipac.buy_amount) 'total_coverage_premi_amount' from dbo.insurance_policy_asset_coverage ipac where ipac.register_asset_code = ipa.code) asset
	where		policy_code = @p_policy_code
	and			(
					fa_code								like '%' + @p_keywords + '%'
					or	ass.item_name					like '%' + @p_keywords + '%'
					or	av.plat_no						like '%' + @p_keywords + '%'
					or	av.colour						like '%' + @p_keywords + '%'
					or	sum_insured_amount				like '%' + @p_keywords + '%'
					or	md.depreciation_name			like '%' + @p_keywords + '%'
					or	mo.occupation_name				like '%' + @p_keywords + '%'
					or	mr.region_name					like '%' + @p_keywords + '%'
					or	ipa.status_asset				like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ipa.fa_code + ass.item_name + av.plat_no + av.colour
													 when 2 then depreciation_name
													 when 3 then mo.occupation_name
													 when 4 then mr.region_name
													 when 5 then cast(ipa.sum_insured_amount as sql_variant)
													 when 6 then cast(asset.total_coverage_premi_amount as sql_variant)
													 when 7 then ipa.status_asset
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													    when 1 then ipa.fa_code + ass.item_name + av.plat_no + av.colour
														when 2 then depreciation_name
														when 3 then mo.occupation_name
														when 4 then mr.region_name
														when 5 then cast(ipa.sum_insured_amount as sql_variant)
														when 6 then cast(asset.total_coverage_premi_amount as sql_variant)
														when 7 then ipa.status_asset
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
