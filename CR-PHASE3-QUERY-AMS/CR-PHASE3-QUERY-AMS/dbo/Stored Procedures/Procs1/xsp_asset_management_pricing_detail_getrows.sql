CREATE PROCEDURE dbo.xsp_asset_management_pricing_detail_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_pricing_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	asset_management_pricing_detail aspd
	left join dbo.asset ass on (ass.code = aspd.asset_code)
	where	pricing_code = @p_pricing_code
	and		(
				aspd.asset_code					like '%' + @p_keywords + '%'
				or	aspd.pricing_amount			like '%' + @p_keywords + '%'
				or	aspd.request_amount			like '%' + @p_keywords + '%'
				or	aspd.approve_amount			like '%' + @p_keywords + '%'
				or	ass.item_name				like '%' + @p_keywords + '%'
			) ;

	select		id
				,aspd.pricing_code
				,aspd.asset_code
				,aspd.pricelist_amount
				,aspd.pricing_amount
				,aspd.request_amount
				,aspd.approve_amount
				,aspd.estimate_gain_loss_pct
				,aspd.estimate_gain_loss_amount
				,aspd.net_book_value_fiscal
				,aspd.net_book_value_comm
				,aspd.collateral_location
				,aspd.collateral_description
				,ass.item_name
				,@rows_count 'rowcount'
	from		asset_management_pricing_detail aspd
	left join dbo.asset ass on (ass.code = aspd.asset_code)
	where		pricing_code = @p_pricing_code
	and			(
					aspd.asset_code					like '%' + @p_keywords + '%'
					or	aspd.pricing_amount			like '%' + @p_keywords + '%'
					or	aspd.request_amount			like '%' + @p_keywords + '%'
					or	aspd.approve_amount			like '%' + @p_keywords + '%'
					or	ass.item_name				like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then aspd.asset_code
													 when 2 then ass.item_name
													 when 3 then cast(aspd.pricing_amount as sql_variant)
													 when 4 then cast(aspd.request_amount as sql_variant)
													 when 5 then cast(aspd.approve_amount as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													    when 1 then aspd.asset_code
														when 2 then ass.item_name
														when 3 then cast(aspd.pricing_amount as sql_variant)
														when 4 then cast(aspd.request_amount as sql_variant)
														when 5 then cast(aspd.approve_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
