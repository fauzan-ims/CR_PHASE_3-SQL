
CREATE function dbo.xfn_agreement_get_ol_ar_asset
(
	@p_agreement_no nvarchar(50)
	,@p_asset_no	nvarchar(50)
)
returns decimal(18, 2)
as
begin

	-- mendapatkan rental yang sudah jatuh tempo da belum dibayar
	declare @os_installment decimal(18, 2) ;

	select	@os_installment = sum(isnull(aa.ar_amount, 0) - isnull(aap.payment_amount, 0))
	from	dbo.agreement_invoice aa with (nolock)
			outer apply
	(
		select	sum(aap.payment_amount) as 'payment_amount'
		from	dbo.agreement_invoice_payment aap with (nolock)
		where	(aap.agreement_invoice_code = aa.code)
	) aap
	where	aa.agreement_no = @p_agreement_no
			and aa.asset_no = @p_asset_no ;

	return isnull(@os_installment, 0) ;
end ;
