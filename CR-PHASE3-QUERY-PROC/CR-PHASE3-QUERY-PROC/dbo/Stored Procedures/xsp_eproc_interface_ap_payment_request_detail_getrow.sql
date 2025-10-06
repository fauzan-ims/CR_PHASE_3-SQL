
create procedure xsp_eproc_interface_ap_payment_request_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,payment_request_code
			,invoice_register_code
			,payment_amount
			,is_paid
			,ppn
			,pph
			,fee
	from	eproc_interface_ap_payment_request_detail
	where	id = @p_id ;
end ;
