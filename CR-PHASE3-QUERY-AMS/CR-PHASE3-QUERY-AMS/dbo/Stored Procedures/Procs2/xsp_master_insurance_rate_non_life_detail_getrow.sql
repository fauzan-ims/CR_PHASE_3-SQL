
CREATE procedure [dbo].[xsp_master_insurance_rate_non_life_detail_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,rate_non_life_code
			,sum_insured_from
			,sum_insured_to
			,is_commercial
			,is_authorized
			,calculate_by
			,buy_rate
			,sell_rate
			,buy_amount
			,sell_amount
			,discount_pct
	from	master_insurance_rate_non_life_detail
	where	id = @p_id ;
end ;



