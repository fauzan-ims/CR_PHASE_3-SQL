CREATE procedure dbo.xsp_asset_management_pricing_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,ampd.pricing_code
			,ampd.asset_code
			,ampd.pricelist_amount
			,ampd.pricing_amount
			,ampd.request_amount
			,ampd.approve_amount
			,ampd.estimate_gain_loss_pct
			,ampd.estimate_gain_loss_amount
			,ampd.net_book_value_fiscal
			,ampd.net_book_value_comm
			,ampd.collateral_location
			,ampd.collateral_description
			,ass.item_name
	from	asset_management_pricing_detail ampd
	left join dbo.asset ass on (ass.code = ampd.asset_code)
	where	id = @p_id ;
end ;
