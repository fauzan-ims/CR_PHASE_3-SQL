CREATE PROCEDURE dbo.xsp_insurance_register_existing_asset_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_register_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	insurance_register_existing_asset irea
	left join dbo.asset ass on (ass.code = irea.fa_code)
	left join dbo.asset_vehicle av on (av.asset_code = ass.code)
	left join dbo.master_coverage mc on (mc.code = irea.coverage_code)
	where	register_code = @p_register_code
	and		(
				fa_code						like '%' + @p_keywords + '%'
				or	ass.item_name			like '%' + @p_keywords + '%'
				or	av.plat_no				like '%' + @p_keywords + '%'
				or	av.engine_no			like '%' + @p_keywords + '%'
				or	av.chassis_no			like '%' + @p_keywords + '%'
				or	sum_insured_amount		like '%' + @p_keywords + '%'
				or	coverage_code			like '%' + @p_keywords + '%'
				or	premi_sell_amount		like '%' + @p_keywords + '%'
				or	mc.coverage_name		like '%' + @p_keywords + '%'
			) ;

	select		id
				,register_code
				,fa_code
				,ass.item_name
				,av.plat_no
				,av.engine_no
				,av.chassis_no
				,sum_insured_amount
				,coverage_code
				,premi_sell_amount
				,mc.coverage_name
				,@rows_count 'rowcount'
	from		insurance_register_existing_asset irea
	left join dbo.asset ass on (ass.code = irea.fa_code)
	left join dbo.asset_vehicle av on (av.asset_code = ass.code)
	left join dbo.master_coverage mc on (mc.code = irea.coverage_code)
	where		register_code = @p_register_code
	and			(
					fa_code						like '%' + @p_keywords + '%'
					or	ass.item_name			like '%' + @p_keywords + '%'
					or	av.plat_no				like '%' + @p_keywords + '%'
					or	av.engine_no			like '%' + @p_keywords + '%'
					or	av.chassis_no			like '%' + @p_keywords + '%'
					or	sum_insured_amount		like '%' + @p_keywords + '%'
					or	coverage_code			like '%' + @p_keywords + '%'
					or	premi_sell_amount		like '%' + @p_keywords + '%'
					or	mc.coverage_name		like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then irea.fa_code + ass.item_name
													 when 2 then av.plat_no + av.engine_no + av.chassis_no
													 when 3 then mc.coverage_name
													 when 4 then cast(irea.sum_insured_amount as sql_variant)
													 when 5 then cast(irea.premi_sell_amount as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													    when 1 then irea.fa_code + ass.item_name
														when 2 then av.plat_no + av.engine_no + av.chassis_no
														when 3 then mc.coverage_name
														when 4 then cast(irea.sum_insured_amount as sql_variant)
														when 5 then cast(irea.premi_sell_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
