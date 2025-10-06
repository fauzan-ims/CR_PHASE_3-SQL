CREATE FUNCTION dbo.xfn_et_get_os_installment
(
	@p_reff_no		 nvarchar(50)
	,@p_agreement_no nvarchar(50)
	,@p_date		 datetime
)
returns decimal(18, 2)
as
begin
	-- mengambil nilai pokok hutang yang belum dibayar
	declare @os_principal	 decimal(18, 2)
			,@residual_value decimal(18, 2) = 0 ;

	select	@os_principal = sum(isnull(aa.billing_amount, 0) - isnull(aap.payment_amount, 0))
	from	dbo.agreement_asset_amortization aa with (nolock)
			outer apply
	(
		select	sum(aap.payment_amount) as 'payment_amount'
		from	dbo.agreement_invoice_payment aap with (nolock)
		where	(
					aap.asset_no = aa.asset_no
					and aap.invoice_no = aa.invoice_no
					and aap.agreement_no = aa.agreement_no
				)
	) aap
	where	aa.agreement_no				  = @p_agreement_no
			and aa.asset_no in
				(
					select	asset_no
					from	dbo.et_detail with (nolock)
					where	et_code			 = @p_reff_no
							and is_terminate = '1'
				)
			and cast(aa.due_date as date) > cast(@p_date as date) ;

	set @os_principal = isnull(@os_principal, 0) ;

	return round(@os_principal, 0) ;
end ;
