
CREATE procedure [dbo].[xsp_insurance_policy_main_period_adjusment_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,policy_code
			,year_periode
			,adjustment_buy_amount
			,adjustment_admin_amount
			,adjustment_discount_amount
	from	insurance_policy_main_period_adjusment
	where	id = @p_id ;
end ;

