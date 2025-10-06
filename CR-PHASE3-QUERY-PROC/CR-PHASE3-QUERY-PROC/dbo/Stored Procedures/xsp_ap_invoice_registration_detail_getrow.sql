CREATE PROCEDURE [dbo].[xsp_ap_invoice_registration_detail_getrow]
(
	@p_id bigint
)
as
begin
	select	ird.id
			,ird.invoice_register_code
			,ird.grn_code
			,ird.currency_code
			,ird.item_code
			,ird.item_name
			,ird.purchase_amount
			--	,(((ird.purchase_amount - ird.discount) + ird.ppn - ird.pph) * ird.quantity) 'total_amount_detail'
			--,(((ird.purchase_amount - ird.discount) * ird.quantity) + ird.ppn - ird.pph) 'total_amount'
			,ird.tax_code
			,ird.tax_name
			,ird.ppn
			,ird.pph
			,ird.shipping_fee
			,ird.branch_code
			,ird.branch_name
			,ird.division_code
			,ird.division_name
			,ird.department_code
			,ird.department_name
			,ird.purchase_order_id
			,ird.uom_code
			,ird.uom_name
			,ird.quantity
			,ird.discount						'discount_detail'
			,ird.total_amount
			,ir.status
			,ird.ppn_pct
			,ird.pph_pct
			,pod.po_code
			,ird.spesification
			,po.unit_from
			,ird.purchase_amount - ird.discount 'nett_amount'
			,payment.code_payment
			,ird.qty_invoice
			,ird.qty_grn
			,ird.qty_post
			,ird.qty_grn - ird.qty_post 'qty_outstanding'
	from	ap_invoice_registration_detail		   ird
			inner join dbo.ap_invoice_registration ir on ird.invoice_register_code = ir.code
			inner join dbo.purchase_order_detail   pod on pod.id = ird.purchase_order_id
			inner join dbo.purchase_order		   po on pod.po_code = po.code
			outer apply
	(
		select	apr.code 'code_payment'
		from	dbo.ap_payment_request_detail	 aprd
				left join dbo.ap_payment_request apr on aprd.payment_request_code = apr.code
		where	aprd.invoice_register_code = ird.invoice_register_code
	)											   payment
	where	ird.id = @p_id ;
end ;
