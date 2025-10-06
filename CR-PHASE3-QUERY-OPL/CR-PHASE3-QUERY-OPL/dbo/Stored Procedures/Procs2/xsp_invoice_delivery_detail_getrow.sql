CREATE PROCEDURE dbo.xsp_invoice_delivery_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,inv.invoice_external_no
			,delivery_code
			,idd.invoice_no
			,delivery_status
			,delivery_date
			,delivery_remark
			,receiver_name
			,file_name
			,file_path
			,inv.invoice_type
			,inv.invoice_status
			,inv.invoice_date
			,inv.invoice_due_date
			,inv.invoice_name
			,inv.client_name
			,inv.client_area_phone_no
			,inv.client_phone_no
			,inv.client_npwp
			,inv.client_address	
			,inv.currency_code
			,inv.total_billing_amount
			,inv.total_discount_amount
			,inv.total_ppn_amount
			,inv.total_pph_amount
			,inv.total_amount
	from	invoice_delivery_detail idd
	inner join dbo.invoice inv with(nolock) on (inv.invoice_no = idd.invoice_no)
	where	id = @p_id ;
end ;
