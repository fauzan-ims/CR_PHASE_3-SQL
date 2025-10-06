
create procedure xsp_eproc_interface_ap_payment_request_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,code
			,invoice_date
			,currency_code
			,supplier_code
			,invoice_amount
			,is_another_invoice
			,file_invoice_no
			,ppn
			,pph
			,fee
			,bill_type
			,discount
			,due_date
			,tax_invoice_date
			,purchase_order_code
			,branch_code
			,branch_name
			,to_bank_code
			,to_bank_account_name
			,to_bank_account_no
			,payment_by
			,status
			,remark
	from	eproc_interface_ap_payment_request
	where	id = @p_id ;
end ;
