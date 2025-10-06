CREATE PROCEDURE dbo.xsp_claim_detail_asset_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_claim_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	claim_detail_asset cda
	left join dbo.insurance_policy_asset ipa on (ipa.code = cda.policy_asset_code)
	outer apply (select sum(buy_amount) 'buy_amount' from dbo.insurance_policy_asset_coverage ipac where ipac.register_asset_code = ipa.code) asset
	left join dbo.asset ass on (ass.code = ipa.fa_code)
	left join dbo.asset_vehicle av on (av.asset_code = ass.code)
	where	claim_code = @p_claim_code
	and		(
				ipa.fa_code					like '%' + @p_keywords + '%'
				or	ass.item_name			like '%' + @p_keywords + '%'
				or	av.plat_no				like '%' + @p_keywords + '%'
				or	av.engine_no			like '%' + @p_keywords + '%'
				or	av.chassis_no			like '%' + @p_keywords + '%'
				or	ipa.sum_insured_amount	like '%' + @p_keywords + '%'
				or	asset.buy_amount		like '%' + @p_keywords + '%'
			) ;

	select		cda.id
				,claim_code
				,policy_asset_code
				,ipa.fa_code
				,ass.item_name
				,av.engine_no
				,av.plat_no
				,av.chassis_no
				,ipa.sum_insured_amount
				,asset.buy_amount
				,@rows_count 'rowcount'
	from		claim_detail_asset cda
	left join dbo.insurance_policy_asset ipa on (ipa.code = cda.policy_asset_code)
	outer apply (select sum(buy_amount) 'buy_amount' from dbo.insurance_policy_asset_coverage ipac where ipac.register_asset_code = ipa.code) asset
	left join dbo.asset ass on (ass.code = ipa.fa_code)
	left join dbo.asset_vehicle av on (av.asset_code = ass.code)
	where		claim_code = @p_claim_code
	and			(
					ipa.fa_code					like '%' + @p_keywords + '%'
					or	ass.item_name			like '%' + @p_keywords + '%'
					or	av.plat_no				like '%' + @p_keywords + '%'
					or	av.engine_no			like '%' + @p_keywords + '%'
					or	av.chassis_no			like '%' + @p_keywords + '%'
					or	ipa.sum_insured_amount	like '%' + @p_keywords + '%'
					or	asset.buy_amount		like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ipa.fa_code
													 when 2 then av.plat_no
													 when 3 then cast(ipa.sum_insured_amount as sql_variant)
													 when 4 then cast(asset.buy_amount as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													    when 1 then ipa.fa_code
														when 2 then av.plat_no
														when 3 then cast(ipa.sum_insured_amount as sql_variant)
														when 4 then cast(asset.buy_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
