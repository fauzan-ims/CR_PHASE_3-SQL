CREATE function dbo.xfn_agreement_get_all_os_principal
(
	@p_agreement_no nvarchar(50)
	,@p_date		datetime
	,@p_asset_no	nvarchar(50) = null
)
returns decimal(18, 2)
as
begin
	--mengambil schedule yang belum memiliki invoice
	declare @os_principal	 decimal(18, 2)
			,@residual_value decimal(18, 2) = 0 ;

	select	@os_principal = sum(isnull(aa.billing_amount, 0))
	from	dbo.agreement_asset_amortization aa with (nolock)
	where	aa.agreement_no				  = @p_agreement_no
			and isnull(aa.invoice_no, '') = ''
			and aa.asset_no				  = isnull(@p_asset_no, aa.asset_no) ;

	set @os_principal = isnull(@os_principal, 0) ;

	return @os_principal ;
end ;
