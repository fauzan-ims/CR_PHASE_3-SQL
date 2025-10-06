CREATE PROCEDURE dbo.xsp_application_tc_insert
(
	@p_application_no					  nvarchar(50)
	,@p_tenor							  int
	,@p_dp_pct							  decimal(9, 6)
	,@p_dp_received_by					  nvarchar(1)
	,@p_payment_schedule_type_code		  nvarchar(50)
	,@p_amort_type_code					  nvarchar(50)
	,@p_day_in_one_year					  nvarchar(10)
	,@p_first_payment_type				  nvarchar(3)
	,@p_interest_type					  nvarchar(10)
	,@p_min_interest_eff_rate			  decimal(9, 6)
	,@p_min_interest_flat_rate			  decimal(9, 6)
	,@p_interest_rate_type				  nvarchar(10)
	,@p_interest_eff_rate				  decimal(9, 6)
	,@p_interest_eff_rate_after_rounding  decimal(9, 6)
	,@p_interest_flat_rate				  decimal(9, 6)
	,@p_interest_flat_rate_after_rounding decimal(9, 6)
	,@p_disbursement_date				  datetime
	,@p_last_due_date					  datetime
	,@p_residual_value_type				  nvarchar(20)
	,@p_residual_value_amount			  decimal(18, 2)
	,@p_security_deposit_amount			  decimal(18, 2)
	,@p_rounding_type					  nvarchar(10)
	,@p_rounding_amount					  decimal(18, 2)
	,@p_floating_margin_rate			  decimal(9, 6)
	,@p_floating_benchmark_code			  nvarchar(50)
	,@p_floating_benchmark_name			  nvarchar(250)
	,@p_floating_threshold_rate			  decimal(9, 6)
	,@p_floating_start_period			  int
	,@p_floating_period_cycle			  int
	,@p_payment_with_code				  nvarchar(50)
	,@p_installment_amount				  decimal(18, 2)
	--
	,@p_cre_date						  datetime
	,@p_cre_by							  nvarchar(15)
	,@p_cre_ip_address					  nvarchar(15)
	,@p_mod_date						  datetime
	,@p_mod_by							  nvarchar(15)
	,@p_mod_ip_address					  nvarchar(15)
)
as
begin
 			
	declare @msg				nvarchar(max)
			,@rounding_type		nvarchar(10)
			,@rounding_amount	decimal(18, 2) ;

	exec dbo.xsp_master_rounding_get_amount @p_application_no	= @p_application_no
											,@p_drawdown_no		= N'' -- nvarchar(50)
											,@p_rounding_type	= @rounding_type output 
											,@p_rounding_amount = @rounding_amount output 

	begin try
		insert into application_tc
		(
			application_no
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
			,rounding_type
			,rounding_amount
			,floating_margin_rate	
			,floating_benchmark_code
			,floating_benchmark_name
			,floating_threshold_rate
			,floating_start_period
			,floating_period_cycle
			,payment_with_code
			,installment_amount
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_application_no
			,@p_tenor
			,@p_dp_pct
			,@p_dp_received_by
			,@p_payment_schedule_type_code
			,@p_amort_type_code
			,@p_day_in_one_year
			,@p_first_payment_type
			,@p_interest_type
			,@p_min_interest_eff_rate
			,@p_min_interest_flat_rate
			,@p_interest_rate_type
			,@p_interest_eff_rate
			,@p_interest_eff_rate_after_rounding
			,@p_interest_flat_rate
			,@p_interest_flat_rate_after_rounding
			,@p_disbursement_date
			,@p_last_due_date
			,@p_residual_value_type
			,@p_residual_value_amount
			,@p_security_deposit_amount
			,@rounding_type
			,@rounding_amount
			,@p_floating_margin_rate	
			,@p_floating_benchmark_code
			,@p_floating_benchmark_name
			,@p_floating_threshold_rate
			,@p_floating_start_period
			,@p_floating_period_cycle
			,@p_payment_with_code
			,@p_installment_amount
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;	
end ;




