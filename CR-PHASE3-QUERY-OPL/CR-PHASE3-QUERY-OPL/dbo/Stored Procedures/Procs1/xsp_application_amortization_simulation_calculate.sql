CREATE PROCEDURE dbo.xsp_application_amortization_simulation_calculate
(
	@p_application_simulation_code  nvarchar(50)
	--
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg				 nvarchar(max)
			,@sp_default_name	 nvarchar(250)
			,@sp_override_name	 nvarchar(250)
			,@is_sp_override	 nvarchar(1)
			,@leasead_value		 decimal(18, 2)		 
			--				   						 
			,@tenor				 int				 
			,@interest_rate_eff	 decimal(9, 6)	
			,@p_rate_flat	 	 decimal(9, 6)	
			,@payment_schedule	 nvarchar(50)		 
			,@first_payment_type nvarchar(3)		 
			,@day_in_one_year	 nvarchar(10)
			,@rv_type			 nvarchar(20)		 
			,@residual_value	 decimal(18, 2)		 
			,@due_date			 datetime			 
			--				   						 
			,@rounding_value	 decimal(18, 2)		 
			,@rounding_type		 nvarchar(10)		 
			,@facility_code		 nvarchar(50)		 
			,@last_due_date		 datetime 
			--
			,@first_installment_amount	 decimal(18, 2)		 
			,@max_due_date		datetime;

	begin try
		-- validation
		begin
			--if exists
			--(
			--	select	1
			--	from	dbo.application_tc_simulation
			--	where	application_simulation_code		= @p_application_simulation_code
			--			and amort_type_code = 'STEP'
			--)
			--begin
			--	if not exists(select 1 from dbo.application_step_period where application_simulation_code = @p_application_simulation_code)
			--	begin 
			--		set @msg = 'Please input Aplication Step';
			--		raiserror(@msg, 16, 1) ;
			--	end
			--	if ((
			--			select	financing_amount
			--			from	dbo.application_simulation
			--			where	code = @p_application_simulation_code
			--		) <>
			--	   (
			--		   select	sum(recovery_principal_amount)
			--		   from		dbo.application_step_period
			--		   where	application_simulation_code = @p_application_simulation_code
			--	   )
			--	   )
			--	begin
			--		set @msg = 'Please update Aplication Step, Application Financing Amount must be equal to Recovery Financing Amount' ;

			--		raiserror(@msg, 16, 1) ;
			--	end ;
			--end ;
			if exists
			(
				select	1
				from	dbo.application_tc_simulation
				where	application_simulation_code				  = @p_application_simulation_code
						and (
								tenor				  = 0
								or	disbursement_date is null
							)
			)
			begin
				set @msg = 'Please setting Application Tc Tenor must be greater than 0 or Disbursement Date cannot be null' ;

				raiserror(@msg, 16, 1) ;
			end ;

			if exists
			(
				select	1
				from	dbo.application_tc_simulation
				where	application_simulation_code				   = @p_application_simulation_code
						and (
								interest_eff_rate  = 0
								or	interest_flat_rate = 0
							)
						and amort_type_code <> 'EVP'
			)
			begin
				set @msg = 'Please setting Application Tc Effective Rate (p.a) and Flat Rate (p.a) must be greater than 0';
				raiserror(@msg, 16, 1) ;
			end ;
		end ;
		begin
			-- mengambil data dari application main	
			select	@leasead_value			= am.financing_amount
					--
					,@tenor					= at.tenor
					,@interest_rate_eff		= at.interest_eff_rate
					,@p_rate_flat			= at.interest_flat_rate
					,@payment_schedule		= at.payment_schedule_type_code
					,@first_payment_type	= at.first_payment_type
					,@day_in_one_year		= at.day_in_one_year
					,@rv_type				= at.residual_value_type
					,@residual_value		= at.residual_value_amount
					,@due_date				= at.disbursement_date
					--
					,@rounding_value		= at.rounding_amount
					,@rounding_type			= at.rounding_type
					,@facility_code			= ''
					,@last_due_date			= at.last_due_date
			from	application_simulation am
					inner join dbo.application_tc_simulation at on (am.code = at.application_simulation_code) 
			where	am.code = @p_application_simulation_code ;
		end ;

		-- exec sp dinamis
		begin
			delete dbo.application_amortization_simulation
			where	application_simulation_code = @p_application_simulation_code ;

			select	@sp_default_name = mat.sp_default_name
					,@sp_override_name = mat.sp_override_name
					,@is_sp_override = mat.is_sp_override
			from	master_amortization_type mat
					inner join dbo.application_tc_simulation at on (
															at.amort_type_code	  = mat.code
															and at.application_simulation_code = @p_application_simulation_code
														) ; 
			if (@is_sp_override = '0')
			begin
				exec @sp_default_name @p_application_simulation_code
									  ,@leasead_value
									  --
									  ,@tenor
									  ,@interest_rate_eff
									  ,@p_rate_flat
									  ,@payment_schedule
									  ,@first_payment_type
									  ,@day_in_one_year
									  ,@rv_type
									  ,@residual_value
									  ,@due_date
									  --
									  ,@rounding_value
									  ,@rounding_type
									  ,@facility_code
									  ,@last_due_date
									  ,@p_mod_date
									  ,@p_mod_by
									  ,@p_mod_ip_address
									  ,@p_mod_date
									  ,@p_mod_by
									  ,@p_mod_ip_address ;
			end ;
			else
			begin
				exec @sp_override_name @p_application_simulation_code
									   ,@leasead_value
									   --
									   ,@tenor
									   ,@interest_rate_eff
									   ,@p_rate_flat
									   ,@payment_schedule
									   ,@first_payment_type
									   ,@day_in_one_year
									   ,@rv_type
									   ,@residual_value
									   ,@due_date
									   --
									   ,@rounding_value
									   ,@rounding_type
									   ,@facility_code
									   ,@last_due_date
									   ,@p_mod_date
									   ,@p_mod_by
									   ,@p_mod_ip_address
									   ,@p_mod_date
									   ,@p_mod_by
									   ,@p_mod_ip_address ;
			end ;

			-- insert into application amortization dari amortization calculate
			begin
				delete application_amortization_simulation where application_simulation_code = @p_application_simulation_code

				insert into dbo.application_amortization_simulation
				(
					application_simulation_code
					,installment_no
					,due_date
					,principal_amount
					,installment_amount
					,installment_principal_amount
					,installment_interest_amount
					,os_principal_amount
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				select	reff_no
						,installment_no
						,due_date
						,principal_amount
						,installment_amount
						,installment_principal_amount
						,installment_interest_amount
						,os_principal_amount
						,cre_date
						,cre_by
						,cre_ip_address
						,mod_date
						,mod_by
						,mod_ip_address
				from	dbo.amortization_calculate
				where	reff_no		= @p_application_simulation_code
						and user_id = @p_mod_by ;
				
				select @max_due_date = max(due_date)
				from	dbo.amortization_calculate
				where	reff_no		= @p_application_simulation_code
						and user_id = @p_mod_by ;
				
				select @first_installment_amount = installment_amount
				from	dbo.amortization_calculate
				where	reff_no		= @p_application_simulation_code
				and installment_no	= 1
				and user_id = @p_mod_by ;

				update dbo.application_tc_simulation 
				set last_due_date		= @max_due_date 
					,installment_amount = @first_installment_amount
					,is_amortization_valid = '1'
				where application_simulation_code = @p_application_simulation_code
				

				update	application_amortization_simulation
				set		os_interest_amount = isnull((
														select	sum(aa1.installment_interest_amount)
														from	application_amortization_simulation aa1
														where	aa1.installment_no  > aa2.installment_no
																and aa1.application_simulation_code = aa2.application_simulation_code
													), 0
												   )
				from	application_amortization_simulation aa2
				where	aa2.application_simulation_code = application_simulation_code ; 
				 
			end ;
		end ;

		-- hitung irr -  hanya jika bunga diatas 0
		if @interest_rate_eff > 0
		begin
		exec [dbo].[xsp_get_irr_application] @p_application_no	= @p_application_simulation_code
											 ,@p_mod_by			= @p_mod_by 
											 ,@p_mod_date		= @p_mod_date
											 ,@p_mod_ip_address = @p_mod_ip_address
		end
		else
		begin
			update	dbo.application_tc_simulation 
			set		interest_eff_rate_after_rounding = 0
			where	application_simulation_code = @p_application_simulation_code
		end

		--exec dbo.xsp_application_first_installment_amount_fee_update @p_application_no		= @p_application_simulation_code
		--															 ,@p_first_payment_type	= @first_payment_type
		--															 ,@p_mod_date			= @p_mod_date
		--															 ,@p_mod_by				= @p_mod_by 
		--															 ,@p_mod_ip_address		= @p_mod_ip_address
		
		
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










