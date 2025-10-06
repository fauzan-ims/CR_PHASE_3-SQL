CREATE FUNCTION dbo.xfn_et_get_total_billing_amount
(
	@p_reff_no		 nvarchar(50)
	,@p_agreement_no nvarchar(50)
	,@p_date		 datetime
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
		where	aap.agreement_invoice_code = aa.code 
	) aap
	where	aa.agreement_no = @p_agreement_no
			and aa.asset_no in
				(
					select	asset_no
					from	dbo.et_detail with (nolock)
					where	et_code			 = @p_reff_no
							and is_terminate = '1'
				) ;

	return isnull(@total_billing_amount, 0) ;
end ;
