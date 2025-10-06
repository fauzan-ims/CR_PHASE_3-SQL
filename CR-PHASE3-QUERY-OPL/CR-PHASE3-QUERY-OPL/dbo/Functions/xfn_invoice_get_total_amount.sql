CREATE FUNCTION 	dbo.xfn_invoice_get_total_amount
(
	@p_invoice_no nvarchar(50)
)returns decimal(18, 2)
as
begin
	
	declare @return_amount			decimal(18,2)
			,@total_amount			decimal(18, 2)

		select	@total_amount	= abs(total_amount) 
		from	dbo.invoice
		where	invoice_no = @p_invoice_no

	set @return_amount = isnull(@total_amount,0)

	return @return_amount
end
