create function dbo.xfn_insurance_policy_main_get_admin_stamp_amount
(
	@p_policy_main_code nvarchar(50)
)
returns decimal(18, 2)
as
begin
	declare @return_amount			decimal(18, 2)
			,@total_admin_period	decimal(18, 2)
			,@adjustment_buy_amount decimal(18, 2)
			,@total_stamp_period	decimal(18, 2) ;

	if exists
	(
		select	1
		from	dbo.insurance_policy_main
		where	code					= @p_policy_main_code
				and policy_payment_type = 'FTAP'
	)
	begin
		select	@total_admin_period = sum(initial_admin_fee_amount)
				,@total_stamp_period = sum(initial_stamp_fee_amount)
		from	dbo.insurance_policy_main_period
		where	policy_code		 = @p_policy_main_code
				and year_periode = '1' ;

		select	@adjustment_buy_amount = sum(adjustment_buy_amount)
		from	dbo.insurance_policy_main_period_adjusment
		where	policy_code		 = @p_policy_main_code
				and year_periode = '1' ;
	end ;
	else
	begin
		select	@total_admin_period = sum(initial_admin_fee_amount)
				,@total_stamp_period = sum(initial_stamp_fee_amount)
		from	dbo.insurance_policy_main_period
		where	policy_code = @p_policy_main_code ;

		select	@adjustment_buy_amount = sum(adjustment_buy_amount)
		from	dbo.insurance_policy_main_period_adjusment
		where	policy_code = @p_policy_main_code ;
	end ;

	set @return_amount = isnull(@total_admin_period + @adjustment_buy_amount + @total_stamp_period, 0) ;

	return @return_amount ;
end ;
