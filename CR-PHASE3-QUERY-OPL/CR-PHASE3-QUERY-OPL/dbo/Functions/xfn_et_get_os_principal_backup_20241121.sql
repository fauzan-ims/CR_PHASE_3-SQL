create FUNCTION dbo.xfn_et_get_os_principal_backup_20241121
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

 
	-- Hari - 14.Jul.2023 05:31 PM --	perhitunfan penalty dari nilai yang belum di buat invoice nya
	select	@os_principal = sum(isnull(aa.billing_amount, 0) ) 
	from	dbo.agreement_asset_amortization aa with (nolock)
	left join invoice inv on inv.invoice_no = aa.invoice_no   and inv.invoice_status  not in ('NEW','CANCEL')
	where	aa.agreement_no				  = @p_agreement_no
	and		inv.invoice_no is  null
			and aa.asset_no in
				(
					select	asset_no
					from	dbo.et_detail
					where	et_code			 = @p_reff_no
							and is_terminate = '1'
				)
			--and cast(aa.due_date as date) > cast(@p_date as date) ;

	set @os_principal = isnull(@os_principal, 0) ;

	return @os_principal ;
end ;


