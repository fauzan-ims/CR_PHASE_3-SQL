CREATE PROCEDURE dbo.xsp_additional_invoice_detail_getrow
(
	@p_id			bigint
) as
begin

	select	aid.id
			,aid.agreement_no
			,am.client_name
			,aid.asset_no
			,ast.asset_name
			,aid.tax_scheme_code
			,aid.tax_scheme_name
			,aid.billing_no
			,aid.description
			,aid.quantity
			,aid.billing_amount
			,aid.discount_amount
			,aid.ppn_pct
			,aid.ppn_amount
			,aid.pph_pct
			,aid.pph_amount
			,aid.total_amount
			,adi.invoice_status
			,am.agreement_external_no
	from	additional_invoice_detail aid
			inner join dbo.additional_invoice adi	on (adi.code = aid.additional_invoice_code)
			inner join dbo.agreement_main am		on (aid.agreement_no = am.agreement_no)
			inner join dbo.agreement_asset ast		on (ast.asset_no = aid.asset_no)
	where	aid.id	= @p_id
end
