CREATE procedure dbo.xsp_insurance_register_period_getrow
(
	@p_id bigint
)
as
begin
	select	irp.id
			,irp.register_code
			--,irp.sum_insured
			--,irp.rate_depreciation
			,irp.coverage_code
			,irp.year_periode
			--,irp.initial_buy_rate
			--,irp.initial_sell_rate
			--,irp.initial_buy_amount
			--,irp.initial_sell_amount
			--,irp.initial_discount_pct
			--,irp.initial_discount_amount
			--,irp.initial_buy_admin_fee_amount
			--,irp.initial_sell_admin_fee_amount
			--,irp.initial_stamp_fee_amount
			,irp.deduction_amount
			,irp.buy_amount
			--,irp.sell_amount
			,irp.total_buy_amount
			--,irp.total_sell_amount
			,mc.coverage_name
			,mc.insurance_type
			,mc.currency_code 'currency'
			,ir.register_status
	from	insurance_register_period irp
			inner join dbo.insurance_register ir on (ir.code = irp.register_code)
			inner join dbo.master_coverage mc on (mc.code = irp.coverage_code)
	where	irp.id = @p_id ;
end ;

