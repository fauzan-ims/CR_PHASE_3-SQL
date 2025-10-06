CREATE PROCEDURE dbo.xsp_application_tc_getrow
(
	@p_application_no nvarchar(50)
)
as
begin
	select	at.application_no
			,at.tenor
			,at.dp_pct
			,at.dp_received_by
			,case at.dp_received_by
				 when 'S' then 'SUPPLIER'
				 when 'M' then 'MULTIFINANCE'
			 end 'dp_received_by_desc'
			,at.payment_schedule_type_code
			,at.amort_type_code
			,at.day_in_one_year
			,at.first_payment_type
			,case at.first_payment_type
				 when 'ADV' then 'ADVANCE'
				 when 'ARR' then 'ARREAR'
			 end 'first_payment_type_desc'
			,at.interest_type
			,at.min_interest_eff_rate
			,at.min_interest_flat_rate
			,at.interest_rate_type
			,at.interest_eff_rate
			,at.interest_eff_rate_after_rounding
			,at.interest_flat_rate
			,at.interest_flat_rate_after_rounding
			,at.disbursement_date
			,at.last_due_date
			,at.residual_value_type
			,at.residual_value_amount
			,at.security_deposit_amount
			,at.rounding_type
			,cast(at.rounding_amount as nvarchar(15)) 'rounding_amount'
			,at.floating_threshold_rate
			,at.floating_start_period
			,at.floating_period_cycle
			,at.payment_with_code
			,at.installment_amount
			,at.number_of_step
			--,mat.description 'amort_type_desc'
			--,mps.description 'payment_schedule_type_desc'
			,am.financing_amount
			--,isnull(mp.is_editable, '1') 'is_editable'
			,am.level_status
			,at.floating_margin_rate
			,at.floating_benchmark_code
			,at.floating_benchmark_name
			,am.branch_code
	from	application_tc at
			inner join dbo.application_main am on (am.application_no = at.application_no)
			--left join dbo.master_payment_schedule mps on (mps.code	 = at.payment_schedule_type_code)
			--left join dbo.master_amortization_type mat on (mat.code	 = at.amort_type_code)
			--left join dbo.master_package mp on (mp.code				 = am.package_code)
	where	at.application_no = @p_application_no ;
end ;

