CREATE function dbo.xfn_vat_payment_invoice_rental
(
	@p_code nvarchar(50)
)
returns int
as
begin
	declare @return_amount	   int
			,@total_ppn_amount int ;

	select	@total_ppn_amount = total_ppn_amount
	from	dbo.invoice_vat_payment
	where	code = @p_code ;

	set @return_amount = isnull(@total_ppn_amount, 0) ;

	return @return_amount ;
end ;
