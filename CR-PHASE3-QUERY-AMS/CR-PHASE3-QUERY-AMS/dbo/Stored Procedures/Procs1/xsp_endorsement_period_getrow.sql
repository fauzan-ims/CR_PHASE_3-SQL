CREATE procedure dbo.xsp_endorsement_period_getrow
(
	@p_id bigint
)
as
begin
	select	ep.id
			,ep.endorsement_code
			,ep.old_or_new
			,ep.sum_insured
			,ep.rate_depreciation
			,ep.coverage_code
			,ep.year_period
			,ep.initial_buy_rate
			,ep.initial_sell_rate
			,ep.initial_buy_amount
			,ep.initial_sell_amount
			,ep.buy_amount
			,ep.sell_amount
			,ep.initial_discount_pct
			,ep.initial_discount_amount
			,ep.initial_buy_admin_fee_amount
			,ep.initial_sell_admin_fee_amount
			,ep.initial_stamp_fee_amount
			,ep.total_buy_amount
			,ep.total_sell_amount
			,ep.remain_buy
			,ep.remain_sell
			--,am.agreement_external_no 
			,ipm.fa_code
			,aa.item_name
			,mc.coverage_name
			,mc.insurance_type
			,mc.currency_code
	from	endorsement_period ep
			inner join dbo.master_coverage mc on (mc.code		  = ep.coverage_code)
			inner join dbo.endorsement_main em on (em.code		  = ep.endorsement_code)
			inner join dbo.insurance_policy_main ipm on (ipm.code = em.policy_code)
			left join dbo.asset aa on (aa.code					  = ipm.fa_code)
	where	id = @p_id ;
end ;
