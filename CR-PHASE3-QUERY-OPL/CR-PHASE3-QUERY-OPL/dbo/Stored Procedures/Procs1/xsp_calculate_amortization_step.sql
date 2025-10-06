CREATE PROCEDURE dbo.xsp_calculate_amortization_step
(
	@p_reff_no							   nvarchar(50)
	,@p_leasead_value					   decimal(18, 2)
	--									   
	,@p_tenor							   int
	,@p_interest_rate_eff				   decimal(9, 6)
	,@p_rate_flat						   decimal(9, 6)
	,@p_payment_schedule				   nvarchar(50)
	,@p_first_payment_type				   nvarchar(3)
	,@p_day_in_one_year					   nvarchar(10)
	,@p_rv_type							   nvarchar(20)
	,@p_residual_value					   decimal(18, 2)
	,@p_due_date						   datetime
	--									   
	,@p_rounding_value					   decimal(18, 2)
	,@p_rounding_type					   nvarchar(10)
	,@p_facility_code					   nvarchar(50)
	,@p_last_due_date					   DATETIME
	--									   
	,@p_cre_date						   datetime
	,@p_cre_by							   nvarchar(15)
	,@p_cre_ip_address					   nvarchar(15)
	,@p_mod_date						   datetime
	,@p_mod_by							   nvarchar(15)
	,@p_mod_ip_address					   nvarchar(15)
	,@p_until_step_no					   int = NULL --- ini hanya diisi jika di panggil untuk update step tertentu
)
as
begin

	begin try 

		delete dbo.amortization_calculate
		where	user_id		= @p_mod_by
				and reff_no = @p_reff_no ;

		declare @principal_awal			decimal(18, 2)
				,@count					int
				--
				,@installment_awal		decimal(18, 2)
				,@payment_schedule		nvarchar(10)
				,@schedule_month		int
				,@step					int
				,@step_installment		int
				,@step_principal_amount decimal(18, 2)
				,@step_rental_amount	decimal(18, 2)
				,@recovery_flag			nvarchar(10)
				,@even_flag				nvarchar(15)
				--
				,@leasead_value			decimal(18, 2)
				,@tenor					int
				,@eff_rate				decimal(9, 6)
				,@installment_no		int
				,@due_date				datetime
				,@step_code				nvarchar(50)
				,@rv_type				nvarchar(50)
				,@residual_value		decimal(18, 2)
				,@last_step_no			int ;
			 
		if exists
		(
			select	1
			from	dbo.application_main
			where	application_no = @p_reff_no
		)
		begin
			-- mengambil data dari application tc
			select	@eff_rate = atc.interest_eff_rate
					,@due_date = atc.disbursement_date
					--
					,@leasead_value = am.financing_amount
			from	dbo.application_tc atc
					inner join dbo.application_main am			on (am.application_no		  = atc.application_no)
			where	atc.application_no = @p_reff_no 

			select top 1
						@last_step_no = step_no
			from		dbo.application_step_period
			where		application_no = @p_reff_no
			order by	step_no desc ;
		end ;
		else
		begin
			begin
				-- mengambil data dari drawdown tc
				select	@eff_rate = dtc.interest_eff_rate
						,@due_date = dtc.disbursement_date
						--
						,@leasead_value = dm.financing_amount
				from	dbo.drawdown_tc dtc
						inner join dbo.drawdown_main dm on (dm.drawdown_no			= dtc.drawdown_no)
				where	dtc.drawdown_no = @p_reff_no ;

				select top 1
							@last_step_no = step_no
				from		dbo.drawdown_step_period
				where		drawdown_no = @p_reff_no
				order by	step_no desc ;
			end ;
		end ;
	 
		-- open cursor
		if exists
		(
			select	1
			from	dbo.application_main
			where	application_no = @p_reff_no
		)
		begin
			declare c_main cursor for
			select		step_no
						,recovery_flag
						,even_method
						,payment_schedule_type_code
						,number_of_installment
						,recovery_principal_amount
						,recovery_installment_amount
			from		dbo.application_step_period
			where		application_no	= @p_reff_no
			and			step_no			<= isnull(@p_until_step_no,step_no)
			order by	step_no ;
		 
		end ;
		else
		begin
			declare c_main cursor for
			select		step_no
						,recovery_flag
						,even_method
						,payment_schedule_type_code
						,number_of_installment
						,recovery_principal_amount
						,recovery_installment_amount
			from		dbo.drawdown_step_period
			where	drawdown_no		= @p_reff_no
			and		step_no			<= isnull(@p_until_step_no,step_no)
			order by	step_no ;
		end ;

		open c_main ;

		fetch c_main
		into @step
			 ,@recovery_flag
			 ,@even_flag
			 ,@payment_schedule
			 ,@step_installment
			 ,@step_principal_amount
			 ,@step_rental_amount ;

		while @@fetch_status = 0
		begin

			-- mengecek apakah amortization calculate sudah ada data atau belom
			select	@count = count(installment_no)
			from	dbo.amortization_calculate
			where	reff_no = @p_reff_no ;
			if (@count <> 0)
			begin
				select top 1
							@principal_awal = os_principal_amount
							,@installment_no = installment_no + 1
							,@due_date = due_date
				from		dbo.amortization_calculate
				where		reff_no = @p_reff_no
				order by	installment_no desc ;

				set @installment_awal = @installment_no ;
			end ;
			else
			begin
				set @principal_awal = @leasead_value ;
				set @installment_no = 0 ;
				set @installment_awal = 1 ;
			end ;

			-- mengambil multipier di master payment schedule
			select	@schedule_month = multiplier
			from	dbo.master_payment_schedule
			where	code = @payment_schedule ;
			--print @recovery_flag print @even_flag
			-- ngupdate ke application asset amortization
			if (
				   @recovery_flag = 'PRINCIPAL'
				   and	@even_flag = 'PRINCIPAL'
			   )
			begin
				exec xsp_calculate_amortization_recovery_principal_even_principal @p_reff_no
																				  ,@step
																				  ,@step_installment
																				  ,@step_principal_amount
																				  ,@leasead_value
																				  ,@eff_rate
																				  ,@due_date
																				  ,@installment_awal
																				  ,@principal_awal
																				  ,@installment_no
																				  ,@schedule_month
																				  ,@p_mod_by
																				  ,@p_mod_date
																				  ,@p_mod_ip_address
																				  ,@p_mod_by
																				  ,@p_mod_date
																				  ,@p_mod_ip_address ;
			end ;
			else if (
						@recovery_flag = 'PRINCIPAL'
						and @even_flag = 'INSTALLMENT'
					)
			begin
				exec xsp_calculate_amortization_recovery_principal_even_rental @p_reff_no
																			   ,@step
																			   ,@step_installment
																			   ,@step_principal_amount
																			   ,@leasead_value
																			   ,@eff_rate
																			   ,@due_date
																			   ,@installment_awal
																			   ,@principal_awal
																			   ,@installment_no
																			   ,@schedule_month
																			   ,@p_mod_by
																			   ,@p_mod_date
																			   ,@p_mod_ip_address
																			   ,@p_mod_by
																			   ,@p_mod_date
																			   ,@p_mod_ip_address ;
			end ;
			else if (
						@recovery_flag = 'INSTALLMENT'
						and @even_flag = 'INSTALLMENT'
					)
			begin
				-- Jika step yang terakhir maka yang terset adalah recovery principal, even rental
				if (@step = @last_step_no)
				begin
					exec xsp_calculate_amortization_recovery_principal_even_rental @p_reff_no
																				   --,@step_code
																				   ,@step
																				   ,@step_installment
																				   ,@step_principal_amount
																				   ,@leasead_value
																				   ,@eff_rate
																				   ,@due_date
																				   ,@installment_awal
																				   ,@principal_awal
																				   ,@installment_no
																				   ,@schedule_month
																				   ,@p_mod_by
																				   ,@p_mod_date
																				   ,@p_mod_ip_address
																				   ,@p_mod_by
																				   ,@p_mod_date
																				   ,@p_mod_ip_address ;
				end ;
				else
				begin
					exec xsp_calculate_amortization_recovery_rental_even_rental @p_reff_no
																				,@step
																				,@step_installment
																				,@step_rental_amount
																				,@leasead_value
																				,@eff_rate
																				,@due_date
																				,@installment_awal
																				,@principal_awal
																				,@installment_no
																				,@schedule_month
																				,@p_mod_by
																				,@p_mod_date
																				,@p_mod_ip_address
																				,@p_mod_by
																				,@p_mod_date
																				,@p_mod_ip_address ;
				end ;
			end ;

			fetch c_main
			into @step
				 ,@recovery_flag
				 ,@even_flag
				 ,@payment_schedule
				 ,@step_installment
				 ,@step_principal_amount
				 ,@step_rental_amount ;
		end ;

		close c_main ;
		deallocate c_main ;

		/* validasi installment principal harus sama */
		declare @total_installment_principal decimal(18, 2)
				,@financing_amount			 decimal(18, 2) ;

		select	@total_installment_principal = sum(installment_principal_amount)
		from	dbo.amortization_calculate
		where	reff_no = @p_reff_no ;

		if exists
		(
			select	1
			from	dbo.application_main
			where	application_no = @p_reff_no
		)
		begin
			select	@financing_amount = am.financing_amount
					,@residual_value = atc.residual_value_amount
					,@rv_type = atc.residual_value_type
			from	dbo.application_main am
					inner join dbo.application_tc atc on (am.application_no = atc.application_no)
			where	am.application_no = @p_reff_no ;
		end ;
		else
		begin
			select	@financing_amount = am.financing_amount
					,@residual_value = 0  -- default untuk drawdown
					,@rv_type = 'NOTIONAL' -- default untuk drawdown
			from	dbo.drawdown_main am
					inner join dbo.drawdown_tc atc on (am.drawdown_no = atc.drawdown_no)
			where	am.drawdown_no = @p_reff_no ;
		end ;

		-- JIka rv type contractual maka financing amount di kurang dengan residual value
		if (@rv_type <> 'NOTIONAL')
			set @financing_amount = @financing_amount - @residual_value ;

		--set	@financing_amount = @financing_amount
		if ((@financing_amount <> @total_installment_principal) and @p_until_step_no <> null)
		BEGIN
			DECLARE @msg NVARCHAR(400)
			SET @msg = 'Principal amount does not match with Financing amount '+ format(@total_installment_principal, 'N2') +' dan ' +format(@financing_amount, 'N2')
			raiserror(@msg, 16, 0) ;

			return ;
		end ;
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
