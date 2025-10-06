CREATE PROCEDURE dbo.xsp_sale_history_getrow
(
	@p_code nvarchar(50)
)
as
begin
	
	declare @table_name					nvarchar(250)
			,@sp_name					nvarchar(250) 
			,@rpt_code					nvarchar(50)
			,@report_name				nvarchar(250)
			,@total_sell_amount			decimal(18,2)
			,@total_net_book_value		decimal(18,2);

	select	@table_name		= table_name
			,@sp_name		= sp_name
			,@rpt_code		= code
			,@report_name	= name
	from	dbo.sys_report
	where	table_name = 'RPT_CETAKAN_BAST' ;

	select	@total_sell_amount = isnull(sum(sale_value),0)
			,@total_net_book_value = isnull(sum(net_book_value),0)
	from	dbo.sale_detail_history
	where	sale_code = @p_code

	select	sl.code
			,sl.company_code
			,sale_date
			,sl.description
			,sl.branch_code
			,sl.branch_name
			,location_code
			,buyer
			,buyer_phone_no
			,sale_amount 'sale_amount_header'
			,remark
			,status
			,@table_name	'table_name'
			,@sp_name		'sp_name'
			,@rpt_code		'rpt_code'
			,@report_name	'report_name'
			,@total_sell_amount 'total_sell_amount'
			,@total_net_book_value 'total_sell_net_book_value'
			,(@total_sell_amount - @total_net_book_value) 'total_gain_loss'
	from	dbo.sale_history sl
	where	sl.code = @p_code ;
end ;
