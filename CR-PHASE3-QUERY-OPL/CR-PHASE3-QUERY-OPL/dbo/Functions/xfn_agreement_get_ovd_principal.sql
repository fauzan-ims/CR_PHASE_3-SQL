CREATE FUNCTION dbo.xfn_agreement_get_ovd_principal
(
	@p_agreement_no nvarchar(50)
	,@p_date		datetime
)
returns decimal(18, 2)
as
begin
	declare @ovd_principal decimal(18, 2) = 0 ;

	select	@ovd_principal = sum(isnull(aa.ar_amount, 0) - isnull(aap.payment_amount, 0))
	from	dbo.agreement_invoice aa with (nolock)
			outer apply
	(
		select	isnull(sum(aap.payment_amount), 0) as 'payment_amount'
		from	dbo.agreement_invoice_payment aap with (nolock)
		where	(aap.agreement_invoice_code = aa.code)
	) aap
	where	aa.agreement_no = @p_agreement_no
			and cast(aa.due_date as date) > cast(@p_date as date) ;

	return isnull(@ovd_principal, 0) ;
end ;
