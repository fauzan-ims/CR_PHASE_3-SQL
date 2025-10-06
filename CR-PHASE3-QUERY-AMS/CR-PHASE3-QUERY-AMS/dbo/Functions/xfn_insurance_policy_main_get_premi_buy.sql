CREATE FUNCTION dbo.xfn_insurance_policy_main_get_premi_buy
(
	@p_policy_main_code nvarchar(50)
)
returns decimal(18, 2)
as
begin
	declare @return_amount			   decimal(18, 2)
			,@total_buy_amount_period  decimal(18, 2)
			,@total_buy_amount_loading decimal(18, 2)
			,@adjustment_buy_amount	   decimal(18, 2)
			,@total_admin_period	   decimal(18, 2)
			,@total_stamp_period	   decimal(18, 2) ;

	if exists
	(
		select	1
		from	dbo.insurance_policy_main
		where	code					= @p_policy_main_code
				and policy_payment_type = 'FTAP'
	)
	begin
		select	@total_buy_amount_period = sum(ipmp.buy_amount)
				,@total_admin_period = sum(initial_admin_fee_amount)
				,@total_stamp_period = sum(initial_stamp_fee_amount)
		from	dbo.insurance_policy_main_period ipmp
		where	ipmp.policy_code = @p_policy_main_code
				and year_periode = '1' ;

		select	@total_buy_amount_loading = isnull(sum(total_buy_amount), 0)
		from	dbo.insurance_policy_main_loading
		where	policy_code		= @p_policy_main_code
				and year_period = '1' ;
	end ;
	else
	begin
		select	@total_buy_amount_period = sum(buy_amount)
				,@total_admin_period = sum(initial_admin_fee_amount)
				,@total_stamp_period = sum(initial_stamp_fee_amount)
		from	dbo.insurance_policy_main_period ipmp
		where	ipmp.policy_code = @p_policy_main_code ;

		select	@total_buy_amount_loading = isnull(sum(total_buy_amount), 0)
		from	dbo.insurance_policy_main_loading
		where	policy_code = @p_policy_main_code ;
	end ;

	set @return_amount = isnull(@total_buy_amount_period + @total_buy_amount_loading, 0) ;

	return @return_amount ;
end ;
