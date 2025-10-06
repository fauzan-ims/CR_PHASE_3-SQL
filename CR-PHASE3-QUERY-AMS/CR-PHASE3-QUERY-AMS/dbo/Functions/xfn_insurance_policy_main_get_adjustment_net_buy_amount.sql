create function dbo.xfn_insurance_policy_main_get_adjustment_net_buy_amount
(
	@p_policy_main_code nvarchar(50)
)
returns decimal(18, 2)
as
begin
	declare @adjustment_buy_amount decimal(18, 2) ;

	if exists
	(
		select	1
		from	dbo.insurance_policy_main
		where	code					= @p_policy_main_code
				and policy_payment_type = 'FTAP'
	)
	begin
		select	@adjustment_buy_amount = isnull(adjustment_buy_amount, 0)
		from	dbo.insurance_policy_main_period_adjusment
		where	policy_code		 = @p_policy_main_code
				and year_periode = '1' ;
	end ;
	else
	begin
		select	@adjustment_buy_amount = isnull(sum(adjustment_buy_amount), 0)
		from	dbo.insurance_policy_main_period_adjusment
		where	policy_code = @p_policy_main_code ;
	end ;

	return @adjustment_buy_amount ;
end ;
