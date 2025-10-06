CREATE procedure dbo.xsp_invoice_getrow_for_settlement_pph_invoice
(
	@p_invoice_no				nvarchar(50)
)
as
begin

	select	inv.invoice_no
			,inv.client_name
			,inv.faktur_no
			,inv.invoice_date
			,inv.invoice_name
			,inv.invoice_status
			,inv.currency_code
			,inv.total_amount
			,invp.settlement_type
			,invp.settlement_status
			,invp.file_name
			,invp.file_path
			,invp.payment_reff_no
			,invp.payment_reff_date
	from	invoice inv
			inner join dbo.invoice_pph invp on (invp.invoice_no = inv.invoice_no)
	where	inv.invoice_no = @p_invoice_no

end ;
