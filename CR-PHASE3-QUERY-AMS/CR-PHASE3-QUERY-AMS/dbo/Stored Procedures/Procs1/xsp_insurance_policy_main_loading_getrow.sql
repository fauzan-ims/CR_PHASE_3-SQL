
CREATE procedure [dbo].[xsp_insurance_policy_main_loading_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,policy_code
			,loading_code
			,year_period
			,initial_buy_rate
			,initial_sell_rate
			,initial_buy_amount
			,initial_sell_amount
			,total_buy_amount
			,total_sell_amount
	from	insurance_policy_main_loading
	where	id = @p_id ;
end ;

