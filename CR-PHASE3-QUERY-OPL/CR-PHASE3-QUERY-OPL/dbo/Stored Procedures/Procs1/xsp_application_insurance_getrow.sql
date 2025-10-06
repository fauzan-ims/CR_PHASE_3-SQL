CREATE PROCEDURE [dbo].[xsp_application_insurance_getrow]
(
	@p_id			   bigint
	,@p_application_no nvarchar(50)
)
as
begin
	select	id
			,insurance_code
			,insurance_name
			,application_no
			,coverage_code
			,coverage_name
			,tenor
			,eff_date
			,exp_date
			,sum_insured_amount
			,initial_buy_rate
			,initial_sell_rate
			,initial_buy_amount
			,initial_sell_amount
			,initial_discount_pct
			,initial_discount_amount
			,initial_admin_fee_amount
			,initial_sell_admin_fee_amount
			,initial_stamp_fee_amount
			,buy_amount
			,sell_amount
			,adjustment_amount
			,total_buy_amount
			,total_sell_amount
			,currency_code
			,insurance_type
	from	application_insurance
	where	id				   = @p_id
			and application_no = @p_application_no ;
end ;

