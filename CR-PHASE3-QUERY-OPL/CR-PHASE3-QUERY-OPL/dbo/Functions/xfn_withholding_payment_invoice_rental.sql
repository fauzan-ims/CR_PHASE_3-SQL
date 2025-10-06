create FUNCTION 	dbo.xfn_withholding_payment_invoice_rental
(
	@p_code nvarchar(50)
)returns decimal(18, 2)
as
begin
	
	declare @return_amount			decimal(18,2)
			,@pph_amount			decimal(18, 2)

		select	@pph_amount	= total_pph_amount
		from	dbo.invoice_pph_payment
		where	code = @p_code 

	set @return_amount = isnull(@pph_amount,0)

	return @return_amount
end
