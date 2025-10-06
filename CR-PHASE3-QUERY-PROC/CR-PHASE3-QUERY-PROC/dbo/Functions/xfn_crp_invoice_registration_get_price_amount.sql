CREATE FUNCTION dbo.xfn_crp_invoice_registration_get_price_amount
(
	@p_id	bigint
)returns decimal(18, 2)
as
begin
	
	declare @return_amount			decimal(18,2)
			,@price_amount			decimal(18, 2)

	select @price_amount = (purchase_amount - discount) --* quantity
	from dbo.ap_invoice_registration_detail
	where id = @p_id

	set @return_amount = isnull(@price_amount,0)

	return @return_amount
end
