CREATE PROCEDURE dbo.xsp_termination_detail_asset_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_termination_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	termination_detail_asset tda
	left join dbo.insurance_policy_asset ipa on (ipa.code = tda.policy_asset_code)
	left join dbo.asset ass on (ass.code = ipa.fa_code)
	left join dbo.asset_vehicle av on (av.asset_code = ass.code)
	where	termination_code = @p_termination_code
	and		(
				ipa.fa_code						like '%' + @p_keywords + '%'
				or	ass.item_name				like '%' + @p_keywords + '%'
				or	av.plat_no					like '%' + @p_keywords + '%'
				or	av.engine_no				like '%' + @p_keywords + '%'
				or	av.chassis_no				like '%' + @p_keywords + '%'
				or	estimate_refund_amount		like '%' + @p_keywords + '%'
				or	refund_amount				like '%' + @p_keywords + '%'
			) ;

	select		id
				,termination_code
				,policy_asset_code
				,estimate_refund_amount
				,refund_amount
				,ipa.fa_code
				,ass.item_name
				,av.plat_no
				,av.engine_no
				,av.chassis_no
				,@rows_count 'rowcount'
	from		termination_detail_asset tda
	left join dbo.insurance_policy_asset ipa on (ipa.code = tda.policy_asset_code)
	left join dbo.asset ass on (ass.code = ipa.fa_code)
	left join dbo.asset_vehicle av on (av.asset_code = ass.code)
	where		termination_code = @p_termination_code
	and			(
					ipa.fa_code						like '%' + @p_keywords + '%'
					or	ass.item_name				like '%' + @p_keywords + '%'
					or	av.plat_no					like '%' + @p_keywords + '%'
					or	av.engine_no				like '%' + @p_keywords + '%'
					or	av.chassis_no				like '%' + @p_keywords + '%'
					or	estimate_refund_amount		like '%' + @p_keywords + '%'
					or	refund_amount				like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ipa.fa_code
													 when 2 then av.plat_no
													 when 3 then cast(tda.estimate_refund_amount as sql_variant)
													 when 4 then cast(tda.refund_amount as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then ipa.fa_code
														when 2 then av.plat_no
														when 3 then cast(tda.estimate_refund_amount as sql_variant)
														when 4 then cast(tda.refund_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
