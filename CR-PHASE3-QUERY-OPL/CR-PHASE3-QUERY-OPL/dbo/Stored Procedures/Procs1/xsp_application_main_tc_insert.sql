CREATE PROCEDURE dbo.xsp_application_main_tc_insert
(
	@p_application_no  nvarchar(50)
	,@p_package_code   nvarchar(50)
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg				 nvarchar(max)
			,@tenor				 int
			,@interest_rate_type nvarchar(10)
			,@interest_eff_rate	 decimal(9, 6)
			,@interest_flat_rate decimal(9, 6) ;

	begin try
		if (isnull(@p_package_code, '') <> '')
		begin
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
			select	@p_application_no
					,mpt.tenor
					,mpt.minimun_dp_pct
					,'S'
					,mpt.payment_schedule_type_code
					,mpt.amort_type_code
					,mpt.day_in_one_year
					,mpt.first_payment_type
					,mpt.interest_type
					,mpt.min_eff_rate
					,mpt.min_flat_rate
					,mpt.interest_rate_type
					,mpt.interest_rate_eff
					,mpt.interest_rate_eff
					,mpt.interest_rate_flat
					,mpt.interest_rate_flat
					,null
					,null
					,'NONE'
					,0
					,0
					,mpt.rounding_code
					,mpt.rounding_amount
					,mpt.floating_margin_rate	
					,mpt.floating_benchmark_code
					,mpt.floating_benchmark_name
					,mpt.floating_threshold_rate
					,mpt.floating_start_period
					,mpt.floating_period_cycle
					,'TRANSFER'
					,0
					--
					,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
			from	dbo.master_package_tc mpt
					left join dbo.master_rounding mr on (mr.code = mpt.rounding_code)
			where	package_code = @p_package_code ;
		end
		else
		begin 
				set @tenor = 0 ;
				set @interest_rate_type = 'EFFECTIVE' ;
				set @interest_eff_rate = 0 ;
				set @interest_flat_rate = 0 ; 

			exec dbo.xsp_application_tc_insert @p_application_no						= @p_application_no
											   ,@p_tenor								= @tenor 
											   ,@p_dp_pct								= 0 
											   ,@p_dp_received_by						= 'S' 
											   ,@p_payment_schedule_type_code			= ''
											   ,@p_amort_type_code						= '' 
											   ,@p_day_in_one_year						= 'ACTUAL' 
											   ,@p_first_payment_type					= 'ADV' 
											   ,@p_interest_type						= 'FIXED' 
											   ,@p_min_interest_eff_rate				= 0
											   ,@p_min_interest_flat_rate				= 0 
											   ,@p_interest_rate_type					= @interest_rate_type
											   ,@p_interest_eff_rate					= @interest_eff_rate
											   ,@p_interest_eff_rate_after_rounding		= 0
											   ,@p_interest_flat_rate					= @interest_flat_rate
											   ,@p_interest_flat_rate_after_rounding	= 0
											   ,@p_disbursement_date					= null
											   ,@p_last_due_date						= null
											   ,@p_residual_value_type					= 'NONE'
											   ,@p_residual_value_amount				= 0
											   ,@p_security_deposit_amount				= 0
											   ,@p_rounding_type						= 'DOWN'
											   ,@p_rounding_amount						= 0.01
											   ,@p_floating_margin_rate					= 0
											   ,@p_floating_benchmark_code				= null
											   ,@p_floating_benchmark_name				= null
											   ,@p_floating_threshold_rate				= 0
											   ,@p_floating_start_period				= 0 
											   ,@p_floating_period_cycle				= 0 
											   ,@p_payment_with_code					= 'TRANSFER'
											   ,@p_installment_amount					= 0
											   ,@p_cre_date								= @p_cre_date
											   ,@p_cre_by								= @p_cre_by
											   ,@p_cre_ip_address						= @p_cre_ip_address
											   ,@p_mod_date								= @p_mod_date
											   ,@p_mod_by								= @p_mod_by
											   ,@p_mod_ip_address						= @p_mod_ip_address
		end
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











