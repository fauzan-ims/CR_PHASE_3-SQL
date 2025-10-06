
CREATE procedure [dbo].[xsp_insurance_policy_main_period_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,policy_code
			,sum_insured
			,rate_depreciation
			,coverage_code
			,year_periode
			,initial_buy_rate
			,initial_sell_rate
			,initial_buy_amount
			,initial_sell_amount
			,initial_discount_pct
			,initial_discount_amount
			,initial_admin_fee_amount
			,initial_stamp_fee_amount
			,adjustment_amount
			,buy_amount
			,sell_amount
			,total_buy_amount
			,total_sell_amount
	from	insurance_policy_main_period
	where	code = @p_code ;
end ;

