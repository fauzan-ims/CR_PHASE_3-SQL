CREATE PROCEDURE [dbo].[xsp_spaf_claim_detail_getrows]
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_spaf_claim_code		nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	spaf_claim_detail scd
	left join dbo.spaf_asset sa on (sa.code = scd.spaf_asset_code)
	left join dbo.asset ass on (sa.fa_code = ass.code)
	left join dbo.asset_vehicle av on (av.asset_code = ass.code)
	where	spaf_claim_code = @p_spaf_claim_code
	and		(
				sa.fa_code					like '%' + @p_keywords + '%'
				or	ass.item_name			like '%' + @p_keywords + '%'
				or	av.plat_no				like '%' + @p_keywords + '%'
				or	av.engine_no			like '%' + @p_keywords + '%'
				or	av.chassis_no			like '%' + @p_keywords + '%'
				or	ass.purchase_price		like '%' + @p_keywords + '%'
				or	scd.spaf_pct			like '%' + @p_keywords + '%'
				or	scd.claim_amount		like '%' + @p_keywords + '%'
				or	sa.code					like '%' + @p_keywords + '%'
				or	scd.ppn_amount_detail	like '%' + @p_keywords + '%'
				or	scd.pph_amount_detail	like '%' + @p_keywords + '%'
			) ;

	select		id
				,spaf_claim_code
				,sa.fa_code
				,ass.item_name
				,av.plat_no
				,av.engine_no
				,av.chassis_no
				,ass.purchase_price
				,scd.spaf_pct
				,scd.claim_amount
				,sa.code
				,scd.ppn_amount_detail
				,scd.pph_amount_detail
				,@rows_count 'rowcount'
	from		spaf_claim_detail scd
	left join dbo.spaf_asset sa on (sa.code = scd.spaf_asset_code)
	left join dbo.asset ass on (sa.fa_code = ass.code)
	left join dbo.asset_vehicle av on (av.asset_code = ass.code)
	where		spaf_claim_code = @p_spaf_claim_code
	and			(
					sa.fa_code					like '%' + @p_keywords + '%'
					or	ass.item_name			like '%' + @p_keywords + '%'
					or	av.plat_no				like '%' + @p_keywords + '%'
					or	av.engine_no			like '%' + @p_keywords + '%'
					or	av.chassis_no			like '%' + @p_keywords + '%'
					or	ass.purchase_price		like '%' + @p_keywords + '%'
					or	scd.spaf_pct			like '%' + @p_keywords + '%'
					or	scd.claim_amount		like '%' + @p_keywords + '%'
					or	sa.code					like '%' + @p_keywords + '%'
					or	scd.ppn_amount_detail	like '%' + @p_keywords + '%'
					or	scd.pph_amount_detail	like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then sa.code
													 when 2 then sa.fa_code + ass.item_name
													 when 3 then av.plat_no + av.engine_no + av.chassis_no
													 when 4 then cast(ass.purchase_price as sql_variant)
													 when 5 then cast(scd.claim_amount as sql_variant)
													 when 6 then cast(scd.ppn_amount_detail as sql_variant)
													 when 7 then cast(scd.pph_amount_detail as sql_variant)
 												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then sa.code
													 when 2 then sa.fa_code + ass.item_name
													 when 3 then av.plat_no + av.engine_no + av.chassis_no
													 when 4 then cast(ass.purchase_price as sql_variant)
													 when 5 then cast(scd.claim_amount as sql_variant)
													 when 6 then cast(scd.ppn_amount_detail as sql_variant)
													 when 7 then cast(scd.pph_amount_detail as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
