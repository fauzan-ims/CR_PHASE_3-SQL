CREATE PROCEDURE dbo.xsp_invoice_detail_getrow
(
	@p_id			bigint
) as
begin

	select	inv.id
			,inv.invoice_no
			,inv.agreement_no
			,inv.asset_no
			,inv.billing_no
			,inv.description
			,inv.quantity
			,inv.billing_amount
			,inv.discount_amount
			,inv.ppn_amount
			,inv.pph_amount
			,inv.total_amount
			,am.agreement_external_no
	from	invoice_detail inv
	inner join dbo.agreement_main am on (am.agreement_no = inv.agreement_no)
	where	id	= @p_id
end
