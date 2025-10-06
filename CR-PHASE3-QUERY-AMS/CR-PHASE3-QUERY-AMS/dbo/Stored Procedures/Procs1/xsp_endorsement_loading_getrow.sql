CREATE PROCEDURE [dbo].[xsp_endorsement_loading_getrow]
(
	@p_id bigint
)
as
begin
	select	el.id
			,el.endorsement_code
			,el.old_or_new
			,el.loading_code
			,el.year_period
			,el.initial_buy_rate
			,el.initial_sell_rate
			,el.initial_buy_amount
			,el.initial_sell_amount
			,el.remain_buy
			,el.remain_sell
			,el.total_buy_amount
			,el.total_sell_amount
			,el.remain_buy
			,el.remain_sell 
			,mcl.loading_name
	from	dbo.endorsement_loading el
			inner join dbo.master_coverage_loading mcl on (mcl.code = el.loading_code)
			inner join dbo.endorsement_main em on (em.code			= el.endorsement_code)
			inner join dbo.insurance_policy_main ipm on (ipm.code	= em.policy_code) 
	where	id = @p_id ;
end ;

