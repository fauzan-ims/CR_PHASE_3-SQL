CREATE PROCEDURE [dbo].[xsp_sale_detail_getrow]
(
	@p_id bigint
)
as
begin
	declare @table_name	  nvarchar(250)
			,@sp_name	  nvarchar(250)
			,@rpt_code	  nvarchar(50)
			,@report_name nvarchar(250) ;

	select	@table_name	  = table_name
			,@sp_name	  = sp_name
			,@rpt_code	  = code
			,@report_name = name
	from	dbo.sys_report
	where	table_name = 'RPT_CETAKAN_PJB' ;

	select	id
			,sale_code
			,sd.asset_code
			,ass.item_name
			,sd.description
			,net_book_value
			,total_fee_amount
			,total_pph_amount
			,total_ppn_amount
			,gain_loss
			,isnull(is_sold, '0')			   'is_sold'
			,is_unit_out
			,sd.sale_date
			,sale_remark
			,sale_detail_status
			,ass.item_group_code
			,sd.sold_amount
			,sd.net_receive
			,sd.gain_loss_profit
			,total_income
			,total_expense
			,isnull(sd.buyer_type, 'PERSONAL') 'buyer_type'
			,sd.buyer_name
			,buyer_area_phone
			,buyer_area_phone_no
			,buyer_address
			,sd.ktp_no
			,file_name
			,sd.file_path
			,s.sell_type
			,ass.purchase_price
			--,sd.sell_request_amount
			,sd.claim_amount 'sell_request_amount'
			,sd.ppn_asset
			,sd.total_income
			,sd.total_expense
			,@table_name					   'table_name'
			,@sp_name						   'sp_name'
			,@rpt_code						   'rpt_code'
			,@report_name					   'report_name'
			,sd.buyer_npwp
			,sd.buyer_signer_name
			,avh.plat_no
			,avh.engine_no
			,avh.chassis_no
			,ass.agreement_external_no
			,ass.client_name
			,s.buyer_name
			,ma.auction_name
			,sd.faktur_no
			,sd.faktur_date
	from	dbo.sale_detail				 sd
			inner join dbo.asset		 ass on (ass.code		= sd.asset_code)
			inner join dbo.sale			 s on (s.code			= sd.sale_code)
			inner join dbo.asset_vehicle avh on (avh.asset_code = ass.code)
			left join dbo.master_auction ma on (ma.code			= s.auction_code)
	where	id = @p_id ;
end ;
