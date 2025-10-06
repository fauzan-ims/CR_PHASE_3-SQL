CREATE PROCEDURE [dbo].[xsp_sale_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	
	declare @table_name					nvarchar(250)
			,@sp_name					nvarchar(250) 
			,@rpt_code					nvarchar(50)
			,@report_name				nvarchar(250) 
			,@total_net_book_value		decimal(18,2)
			,@total_sale_amount			decimal(18,2);

	select	@table_name		= table_name
			,@sp_name		= sp_name
			,@rpt_code		= code
			,@report_name	= name
	from	dbo.sys_report
	where	table_name = 'RPT_CETAKAN_BAST' ; 
	
	select	@total_net_book_value = isnull(sum(net_book_value),0)
			,@total_sale_amount	  = isnull(sum(sell_request_amount),0)
	from	dbo.sale_detail 
	where	sale_code = @p_code

	select	sl.code
			,sl.company_code
			,sl.sale_date
			,sl.description
			,sl.branch_code
			,sl.branch_name
			,sale_amount									'sale_amount_header'
			,remark
			,status
			,@table_name									'table_name'
			,@sp_name										'sp_name'
			,@rpt_code										'rpt_code'
			,@report_name									'report_name'
			,sale_amount									'total_sell_amount'
			,@total_net_book_value							'total_sell_net_book_value'
			,(@total_sale_amount - @total_net_book_value)	'total_gain_loss'
			,sl.sell_type
			,sl.auction_code
			,ma.auction_name
			,sl.buyer_name
			,sale_detail.sell_request_amount
			,sl.auction_period
			,sl.total_auction_recommended_price
			,sl.total_asset_selling_price
			,sl.total_book_value
			,sl.gain_loss_selling_asset
			,sl.total_profitability_asset
			,sl.related_code_sell_req
			,sl.auction_notes
			,sl.total_asset_purchase_price
			,sl.claim_amount
			,sl.customer_name
			,sale_detail.sell_request_amount
	from	sale sl
	left join dbo.master_auction ma on (ma.code = sl.auction_code)
	outer apply(select sum(sd.sell_request_amount) 'sell_request_amount' from dbo.sale_detail sd where sd.sale_code = sl.code) sale_detail
	where	sl.code = @p_code ; 
end ;
