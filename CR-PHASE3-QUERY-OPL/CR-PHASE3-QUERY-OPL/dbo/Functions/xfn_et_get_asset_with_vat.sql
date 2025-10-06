
CREATE FUNCTION dbo.xfn_et_get_asset_with_vat
(
	@p_reff_no		 nvarchar(50)
	,@p_agreement_no nvarchar(50)
	,@p_date		 datetime
)
returns decimal(18, 2)
as
begin
	-- mengambil nilai pokok hutang yang belum dibayar
	declare @os_installment	   decimal(18, 2)
			,@residual_value   decimal(18, 2) = 0
			,@asset_vat_amount decimal(18, 2) = 0
			,@vat_pct		   decimal(9, 6) ;

	select	@vat_pct = value
	from	dbo.sys_global_param
	where	code = ('RTAXPPN') ;

	select	@os_installment = dbo.xfn_et_get_os_installment(@p_reff_no, @p_agreement_no, @p_date) ;

	select	@residual_value = dbo.xfn_et_get_rv_amount(@p_reff_no, @p_agreement_no, @p_date) ;

	set @asset_vat_amount = (@os_installment + @residual_value) + ((@os_installment + @residual_value) * @vat_pct / 100) ;

	return round(@asset_vat_amount, 0) ;
end ;
