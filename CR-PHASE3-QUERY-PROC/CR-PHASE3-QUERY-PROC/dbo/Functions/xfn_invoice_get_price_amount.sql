create FUNCTION dbo.xfn_invoice_get_price_amount
(
	@p_id	int
)returns decimal(18, 2)
as
begin
	
	declare @return_amount			decimal(18,2)
			,@price_amount			decimal(18, 2)


		select @price_amount = purchase_amount * quantity
		from dbo.ap_invoice_registration_detail
		where id = @p_id

	set @return_amount = isnull(@price_amount,0)

	return @return_amount
end
