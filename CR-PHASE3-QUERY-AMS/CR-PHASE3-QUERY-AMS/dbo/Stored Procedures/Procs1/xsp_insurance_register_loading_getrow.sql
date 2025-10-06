CREATE procedure [dbo].[xsp_insurance_register_loading_getrow]
(
	@p_id bigint
)
as
begin
	select	irl.id
			,irl.register_code
			,irl.loading_code
			,irl.year_period
			,irl.initial_buy_rate
			,irl.initial_sell_rate
			,irl.initial_buy_amount
			,irl.initial_sell_amount
			,irl.total_buy_amount
			,irl.total_sell_amount
			,mcl.loading_name
	from	insurance_register_loading irl
			inner join dbo.master_coverage_loading mcl on (mcl.code = irl.loading_code)
	where	irl.id = @p_id ;
end ;

