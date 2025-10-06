CREATE procedure dbo.xsp_agreement_invoice_detail_getrow
(
	@p_id		bigint
)
as
begin

	select	aid.invoice_no
			,aid.agreement_no
			,am.client_name
			,aid.asset_no
			,ast.asset_name 'asset_name'
			,aid.billing_no
			,aid.description
			,aid.quantity
			,aid.billing_amount
			,aid.discount_amount
			,aid.ppn_amount
			,aid.pph_amount
			,aid.ppn_bm_amount
			,aid.total_amount
	from	dbo.agreement_invoice_detail aid
			inner join dbo.agreement_main am on (am.agreement_no = aid.agreement_no)
			left join dbo.agreement_asset ast on (ast.asset_no = aid.asset_no)
	where	aid.ID = @p_id

end ;
