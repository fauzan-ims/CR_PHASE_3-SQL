CREATE PROCEDURE dbo.xsp_application_tc_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	application_tc
	where	(
				application_no like '%' + @p_keywords + '%'
				or	tenor like '%' + @p_keywords + '%'
				or	dp_pct like '%' + @p_keywords + '%'
				or	dp_received_by like '%' + @p_keywords + '%'
				or	payment_schedule_type_code like '%' + @p_keywords + '%'
				or	amort_type_code like '%' + @p_keywords + '%'
				or	day_in_one_year like '%' + @p_keywords + '%'
				or	first_payment_type like '%' + @p_keywords + '%'
				or	interest_type like '%' + @p_keywords + '%'
				or	min_interest_eff_rate like '%' + @p_keywords + '%'
				or	min_interest_flat_rate like '%' + @p_keywords + '%'
				or	interest_rate_type like '%' + @p_keywords + '%'
				or	interest_eff_rate like '%' + @p_keywords + '%'
				or	interest_eff_rate_after_rounding like '%' + @p_keywords + '%'
				or	interest_flat_rate like '%' + @p_keywords + '%'
				or	interest_flat_rate_after_rounding like '%' + @p_keywords + '%'
				or	disbursement_date like '%' + @p_keywords + '%'
				or	last_due_date like '%' + @p_keywords + '%'
				or	residual_value_type like '%' + @p_keywords + '%'
				or	residual_value_amount like '%' + @p_keywords + '%'
				or	security_deposit_amount like '%' + @p_keywords + '%'
				or	rounding_amount like '%' + @p_keywords + '%'
				or	floating_threshold_rate like '%' + @p_keywords + '%'
				or	floating_start_period like '%' + @p_keywords + '%'
				or	floating_period_cycle like '%' + @p_keywords + '%'
				or	payment_with_code like '%' + @p_keywords + '%'
				or	installment_amount like '%' + @p_keywords + '%'
			) ;

		select		application_no
					,tenor
					,dp_pct
					,dp_received_by
					,payment_schedule_type_code
					,amort_type_code
					,day_in_one_year
					,first_payment_type
					,interest_type
					,min_interest_eff_rate
					,min_interest_flat_rate
					,interest_rate_type
					,interest_eff_rate
					,interest_eff_rate_after_rounding
					,interest_flat_rate
					,interest_flat_rate_after_rounding
					,disbursement_date
					,last_due_date
					,residual_value_type
					,residual_value_amount
					,security_deposit_amount
					,rounding_amount
					,floating_threshold_rate
					,floating_start_period
					,floating_period_cycle
					,payment_with_code
					,installment_amount
					,@rows_count 'rowcount'
		from		application_tc
		where		(
						application_no like '%' + @p_keywords + '%'
						or	tenor like '%' + @p_keywords + '%'
						or	dp_pct like '%' + @p_keywords + '%'
						or	dp_received_by like '%' + @p_keywords + '%'
						or	payment_schedule_type_code like '%' + @p_keywords + '%'
						or	amort_type_code like '%' + @p_keywords + '%'
						or	day_in_one_year like '%' + @p_keywords + '%'
						or	first_payment_type like '%' + @p_keywords + '%'
						or	interest_type like '%' + @p_keywords + '%'
						or	min_interest_eff_rate like '%' + @p_keywords + '%'
						or	min_interest_flat_rate like '%' + @p_keywords + '%'
						or	interest_rate_type like '%' + @p_keywords + '%'
						or	interest_eff_rate like '%' + @p_keywords + '%'
						or	interest_eff_rate_after_rounding like '%' + @p_keywords + '%'
						or	interest_flat_rate like '%' + @p_keywords + '%'
						or	interest_flat_rate_after_rounding like '%' + @p_keywords + '%'
						or	disbursement_date like '%' + @p_keywords + '%'
						or	last_due_date like '%' + @p_keywords + '%'
						or	residual_value_type like '%' + @p_keywords + '%'
						or	residual_value_amount like '%' + @p_keywords + '%'
						or	security_deposit_amount like '%' + @p_keywords + '%'
						or	rounding_amount like '%' + @p_keywords + '%'
						or	floating_threshold_rate like '%' + @p_keywords + '%'
						or	floating_start_period like '%' + @p_keywords + '%'
						or	floating_period_cycle like '%' + @p_keywords + '%'
						or	payment_with_code like '%' + @p_keywords + '%'
						or	installment_amount like '%' + @p_keywords + '%'
					) 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then application_no
													when 2 then dp_received_by
													when 3 then payment_schedule_type_code
													when 4 then amort_type_code
													when 5 then day_in_one_year
													when 6 then first_payment_type
													when 7 then interest_type
													when 8 then interest_rate_type
													when 9 then residual_value_type
													when 10 then payment_with_code
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then application_no
													when 2 then dp_received_by
													when 3 then payment_schedule_type_code
													when 4 then amort_type_code
													when 5 then day_in_one_year
													when 6 then first_payment_type
													when 7 then interest_type
													when 8 then interest_rate_type
													when 9 then residual_value_type
													when 10 then payment_with_code
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

