create function dbo.xfn_payment_renewal_premi_sell
(
	@p_payment_renewal_code nvarchar(50)
)
returns decimal(18, 2)
as
begin
	declare @return_amount		   decimal(18, 2)
			,@total_payment_amount decimal(18, 2) ;

	select	@total_payment_amount = total_payment_amount
	from	dbo.insurance_payment_schedule_renewal
	where	code = @p_payment_renewal_code ;

	set @return_amount = isnull(@total_payment_amount, 0) ;

	return @return_amount ;
end ;
