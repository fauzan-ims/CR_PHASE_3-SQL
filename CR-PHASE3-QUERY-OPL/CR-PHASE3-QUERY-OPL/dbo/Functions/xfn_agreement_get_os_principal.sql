CREATE FUNCTION dbo.xfn_agreement_get_os_principal
(
	@p_agreement_no nvarchar(50)
	,@p_date		datetime
	,@p_asset_no	nvarchar(50) = null
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
					aap.agreement_no = aa.agreement_no
					and aap.asset_no = aa.asset_no
					and aap.invoice_no = aa.invoice_no
				)
	) aap
	where	aa.agreement_no				  = @p_agreement_no
			and cast(aa.due_date as date) > cast(@p_date as date) 
			and	aa.asset_no = isnull(@p_asset_no, aa.asset_no)

	set @os_principal = isnull(@os_principal, 0) ;
	return @os_principal ;
end ;



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xfn_agreement_get_os_principal] TO [lina]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xfn_agreement_get_os_principal] TO [DSF\LINA TISNATA]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xfn_agreement_get_os_principal] TO [dsf_lina]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xfn_agreement_get_os_principal] TO [aryo.budi]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xfn_agreement_get_os_principal] TO [eddy.rakhman]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xfn_agreement_get_os_principal] TO [bsi-miki.maulana]
    AS [dbo];

