CREATE FUNCTION dbo.xfn_agreement_get_total_billing_amount
(
	@p_agreement_no nvarchar(50)
	,@p_date		datetime
)
returns decimal(18, 2)
as
begin

	-- mendapatkan rental yang sudah jatuh tempo da belum dibayar
	declare @total_billing_amount decimal(18, 2) ;

	select	@total_billing_amount = sum(isnull(aa.ar_amount, 0) - isnull(aap.payment_amount, 0))
	from	dbo.agreement_invoice aa with (nolock)
			outer apply
			(
				select	sum(aap.payment_amount) as 'payment_amount'
				from	dbo.agreement_invoice_payment aap with (nolock)
				where	(
							aap.agreement_no = aa.agreement_no
							and aap.invoice_no = aa.invoice_no
						)
			) aap
	where	aa.agreement_no				  = @p_agreement_no

	return isnull(@total_billing_amount, 0) ;
end ;
