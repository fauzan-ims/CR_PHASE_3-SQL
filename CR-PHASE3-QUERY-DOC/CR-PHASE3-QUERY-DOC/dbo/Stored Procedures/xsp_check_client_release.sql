CREATE PROCEDURE dbo.xsp_check_client_release
(
	@p_agreement_no	   nvarchar(50)
	,@p_collateral_no  nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg				 nvarchar(max)
			,@agreement_status	 nvarchar(20)
			,@termination_status nvarchar(20)
			,@collateral_status	 nvarchar(20) ;

	select	@agreement_status		= agreement_status
			,@termination_status	= termination_status
	from	dbo.agreement_main
	where	agreement_no			= @p_agreement_no ;

	select	@collateral_status		= collateral_status
	from	dbo.agreement_collateral
	where	collateral_no			= @p_collateral_no ;

	if (@termination_status in ('WO ACC', 'WO COLL'))
	begin
		set @msg = 'This document cannot be release because account has been write off' ;

		raiserror(@msg, 16, 1) ;
	end ;

	if (@agreement_status = 'GO LIVE' and @collateral_status = 'AVAILABLE')
	begin
		set @msg = 'This document cannot be release because contract still active' ;

		raiserror(@msg, 16, 1) ;
	end ;
end ;
