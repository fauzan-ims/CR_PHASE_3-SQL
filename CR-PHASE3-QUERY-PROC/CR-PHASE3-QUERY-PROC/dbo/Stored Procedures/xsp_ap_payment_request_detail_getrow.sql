CREATE PROCEDURE dbo.xsp_ap_payment_request_detail_getrow
(
	@p_id bigint
)
as
begin
	select	prd.id
			,prd.payment_request_code
			,prd.invoice_register_code
			--,prd.payment_amount
			,prd.is_paid
			,prd.ppn
			,prd.pph
			,prd.fee
			,apr.invoice_amount 'payment_amount'
	from	ap_payment_request_detail prd
	inner join dbo.ap_payment_request apr on (prd.payment_request_code = apr.code)
	where	id = @p_id ;
end ;
