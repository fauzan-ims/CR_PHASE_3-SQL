CREATE FUNCTION dbo.xfn_get_payment_request_procurement_type
(
	@p_code		 nvarchar(50)
)
returns nvarchar(50)
as
begin
	declare @procurement_type		nvarchar(50)
			,@unit_from				nvarchar(50)

	select @unit_from = po.unit_from
	from dbo.ap_payment_request_detail aprd
	left join dbo.ap_invoice_registration_detail aird on (aprd.invoice_register_code = aird.invoice_register_code)
	left join dbo.good_receipt_note grn on (grn.code												 = aird.grn_code)
	left join dbo.good_receipt_note_detail grnd on (grnd.good_receipt_note_code = grn.code)
	left join dbo.purchase_order po on (po.code														 = grn.purchase_order_code)
	where aprd.payment_request_code = @p_code

	if(@unit_from = 'BUY')
	begin
		select @procurement_type = isnull(pr.procurement_type, pr2.procurement_type) 
		from dbo.ap_payment_request_detail aprd
		left join dbo.ap_invoice_registration_detail aird on (aprd.invoice_register_code = aird.invoice_register_code)
		left join dbo.good_receipt_note grn on (grn.code												 = aird.grn_code)
		left join dbo.good_receipt_note_detail grnd on (grnd.good_receipt_note_code = grn.code)
		left join dbo.purchase_order po on (po.code														 = grn.purchase_order_code)
		left join dbo.purchase_order_detail pod on (pod.po_code											 = po.code and pod.id = grnd.purchase_order_detail_id)
		left join dbo.supplier_selection_detail ssd on (ssd.id											 = pod.supplier_selection_detail_id)
		left join dbo.quotation_review_detail qrd on (qrd.id											 = ssd.quotation_detail_id)
		left join dbo.procurement prc on (prc.code collate Latin1_General_CI_AS							 = qrd.reff_no)
		left join dbo.procurement prc2 on (prc2.code													 = ssd.reff_no)
		left join dbo.procurement_request pr on (pr.code												 = prc.procurement_request_code)
		left join dbo.procurement_request pr2 on (pr2.code												 = prc2.procurement_request_code)
		where aprd.payment_request_code = @p_code
	end
	else
	begin
		set @procurement_type = 'MOBILISASI'
	end

	return @procurement_type

end ;
