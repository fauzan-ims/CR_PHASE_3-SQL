CREATE FUNCTION dbo.xfn_invoice_paid_get_invoice_amount
(
	@p_id	BIGINT
)RETURNS DECIMAL(18, 2)
AS
BEGIN
	
	DECLARE @return_amount			DECIMAL(18,2)
			,@price_amount			DECIMAL(18, 2)

	--select @price_amount = prd.payment_amount 
	--from dbo.ap_payment_request_detail prd
	----left join dbo.ap_payment_request apr on (prd.payment_request_code = apr.code)-- join tidak dipakai
	----inner join dbo.ap_invoice_registration ir on (ir.code = prd.invoice_register_code) 
	--where id = @p_id

	select	@price_amount = ird.total_amount / ird.quantity
	from	dbo.ap_payment_request_detail prd
	inner join dbo.ap_payment_request apr on (prd.payment_request_code = apr.code)
	inner join dbo.ap_invoice_registration ir on (ir.code = prd.invoice_register_code) 
	inner join dbo.ap_invoice_registration_detail ird on (ird.invoice_register_code = ir.code)
	where	ird.id = @p_id ;

	set @return_amount = isnull(@price_amount,0)

	return @return_amount
end
