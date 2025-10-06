CREATE function dbo.xfn_vat_out_payment
(
	@p_code nvarchar(50)
)
returns int
as
begin
	declare @return_amount	   int
			,@total_ppn_amount int ;

	select	@total_ppn_amount = sum(ppn_amount)
	from	dbo.invoice_vat_payment_detail
	where	tax_payment_code = @p_code ;

	set @return_amount = isnull(@total_ppn_amount, 0) ;

	return @return_amount ;
end ;
