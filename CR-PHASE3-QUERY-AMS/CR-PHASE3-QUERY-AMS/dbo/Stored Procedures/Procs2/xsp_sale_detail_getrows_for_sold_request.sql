CREATE PROCEDURE [dbo].[xsp_sale_detail_getrows_for_sold_request]
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_sale_code  nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;
;


	select	@rows_count = count(1)
	from	sale_detail					 sd
			inner join dbo.asset		 ass on (ass.code	  = sd.asset_code)
			inner join dbo.asset_vehicle av on (av.asset_code = ass.code)
	where	sale_code = @p_sale_code
			and
			(
				sd.asset_code						like '%' + @p_keywords + '%'
				or	ass.item_name					like '%' + @p_keywords + '%'
				or	av.engine_no					like '%' + @p_keywords + '%'
				or	av.chassis_no					like '%' + @p_keywords + '%'
				or	av.plat_no						like '%' + @p_keywords + '%'
				or	sd.description					like '%' + @p_keywords + '%'
				or	sd.sell_request_amount			like '%' + @p_keywords + '%'
				or	ass.barcode						like '%' + @p_keywords + '%'
				or	sd.net_book_value				like '%' + @p_keywords + '%'
				or	gain_loss						like '%' + @p_keywords + '%'
				or	sd.gain_loss_profit				like '%' + @p_keywords + '%'
				or	sd.sale_detail_status			like '%' + @p_keywords + '%'
				or	sd.sale_detail_status			like '%' + @p_keywords + '%'
				or	sd.total_expense				like '%' + @p_keywords + '%'
				or	sd.total_income					like '%' + @p_keywords + '%'
				or	agreement_external_no			like '%' + @p_keywords + '%'
				or	ass.client_name					like '%' + @p_keywords + '%'
				or	ass.status						like '%' + @p_keywords + '%'
			) ;

	select		sd.id
				,sale_code
				,sd.asset_code
				,av.engine_no
				,av.chassis_no
				,av.plat_no
				,ass.item_name
				,sd.description
				,ass.purchase_price
				,ass.residual_value
				,sd.sell_request_amount			'sell_request_amount_detail'
				,ass.barcode
				,sd.net_book_value
				,sd.gain_loss
				,isnull(sd.gain_loss_profit, 0) 'gain_loss_profit'
				,sd.sale_detail_status
				,sd.total_expense				'expense_amount'
				,sd.total_income				'income_amount'
				,ass.agreement_external_no
				,ass.client_name
				,ass.status						'status_asset'
				,av.built_year
				,case 
					when ass.type_code = 'VHCL' then 'Vehicle'
					else ''
				end 'type_code'
				,sd.condition
				,sd.auction_location
				,ISNULL(sd.auction_base_price, 0.00) AS auction_base_price
				,isnull(sd.asset_selling_price,sd.sell_request_amount)'asset_selling_price'
				,sd.claim_amount
				,@rows_count					'rowcount'
	from		sale_detail					 sd
				inner join dbo.asset		 ass on (ass.code	  = sd.asset_code)
				inner join dbo.asset_vehicle av on (av.asset_code = ass.code)
	where		sale_code = @p_sale_code
				and
				(
					sd.asset_code						like '%' + @p_keywords + '%'
					or	ass.item_name					like '%' + @p_keywords + '%'
					or	av.engine_no					like '%' + @p_keywords + '%'
					or	av.chassis_no					like '%' + @p_keywords + '%'
					or	av.plat_no						like '%' + @p_keywords + '%'
					or	sd.description					like '%' + @p_keywords + '%'
					or	sd.sell_request_amount			like '%' + @p_keywords + '%'
					or	ass.barcode						like '%' + @p_keywords + '%'
					or	sd.net_book_value				like '%' + @p_keywords + '%'
					or	gain_loss						like '%' + @p_keywords + '%'
					or	sd.gain_loss_profit				like '%' + @p_keywords + '%'
					or	sd.sale_detail_status			like '%' + @p_keywords + '%'
					or	sd.sale_detail_status			like '%' + @p_keywords + '%'
					or	sd.total_expense				like '%' + @p_keywords + '%'
					or	sd.total_income					like '%' + @p_keywords + '%'
					or	agreement_external_no			like '%' + @p_keywords + '%'
					or	ass.client_name					like '%' + @p_keywords + '%'
					or	ass.status						like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then sd.asset_code
													 when 2 then ass.status
													 when 3 then av.engine_no
													 when 4 then sd.description
													 when 5 then cast(ass.purchase_price as sql_variant)
													 when 6 then cast(sd.total_income as sql_variant)
													 when 7 then cast(sd.sell_request_amount as sql_variant)
													 when 8 then cast(sd.gain_loss as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then sd.asset_code
													   when 2 then ass.status
													   when 3 then av.engine_no
													   when 4 then sd.description
													   when 5 then cast(ass.purchase_price as sql_variant)
													   when 6 then cast(sd.total_income as sql_variant)
													   when 7 then cast(sd.sell_request_amount as sql_variant)
													   when 8 then cast(sd.gain_loss as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
