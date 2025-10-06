CREATE FUNCTION dbo.xfn_et_get_os_interest
(
	@p_reff_no		 nvarchar(50)
	,@p_agreement_no nvarchar(50)
	,@p_date		 datetime
)
returns decimal(18, 2)
as
begin
	-- untuk mendapatkan nilai bunga yang belum jatuh tempo
	declare @os_interest decimal(18, 2) ;

	select	@os_interest = sum(isnull(aa.income_amount, 0))
	from	dbo.agreement_asset_interest_income aa with (nolock)
	where	aa.agreement_no = @p_agreement_no
			and aa.asset_no in
				(
					select	asset_no
					from	dbo.et_detail with (nolock)
					where	et_code			 = @p_reff_no
							and is_terminate = '1'
				) ;

	return isnull(@os_interest, 0) ;
end ;

