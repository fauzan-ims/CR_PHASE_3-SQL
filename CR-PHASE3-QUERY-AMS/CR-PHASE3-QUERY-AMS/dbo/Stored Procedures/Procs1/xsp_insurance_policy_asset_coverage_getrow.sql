
create procedure xsp_insurance_policy_asset_coverage_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,register_asset_code
			,rate_depreciation
			,is_loading
			,coverage_code
			,year_periode
			,initial_buy_rate
			,initial_buy_amount
			,initial_discount_pct
			,initial_discount_amount
			,initial_admin_fee_amount
			,initial_stamp_fee_amount
			,buy_amount
	from	insurance_policy_asset_coverage
	where	id = @p_id ;
end ;
