CREATE PROCEDURE dbo.xsp_repossession_pricing_detail_getrow
(
	@p_id bigint
)
as
begin

	select	rdp.id
			,rdp.pricing_code
			,rdp.asset_code
			,rdp.request_amount
			,rdp.pricelist_amount
			,rdp.approve_amount
			,rdp.estimate_gain_loss_pct
			,rdp.estimate_gain_loss_amount
			,rdp.collateral_location
			,rdp.collateral_description
			,rmn.pricing_amount
			,rmn.asset_code 'code_asset'	
			,rmn.item_name	
	from	repossession_pricing_detail rdp
			left join dbo.repossession_main rmn on (rmn.code			 = rdp.asset_code)
			--left join dbo.agreement_main amn on (amn.agreement_no		 = rmn.agreement_no)
			--left join dbo.agreement_collateral acl on (acl.collateral_no = rmn.collateral_no)
	where	rdp.id = @p_id ;
end ;
