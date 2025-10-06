CREATE PROCEDURE dbo.xsp_calculate_amortization_recovery_rental_even_rental
(
	@p_reff_no			 nvarchar(50)
	,@p_step_no			 int
	,@p_step_installment int
	,@p_step_amount		 decimal(18, 2)
	,@p_leadsead_amount	 decimal(18, 2)
	,@p_eff_rate		 decimal(9, 6)
	,@p_due_date		 datetime
	,@p_installment_awal int
	,@p_principal_awal	 decimal(18, 2)
	,@p_installment_no	 int
	,@p_schedule_month	 int
	,@p_cre_by			 nvarchar(15)
	,@p_cre_date		 datetime
	,@p_cre_ip_address	 nvarchar(15)
	,@p_mod_by			 nvarchar(15)
	,@p_mod_date		 datetime
	,@p_mod_ip_address	 nvarchar(15)
)
as
begin
	declare	@msg					nvarchar(max)
			,@installment_amount	decimal(18, 2) = 0
			,@installment_principal decimal(18, 2) = 0
			,@installment_interest	decimal(18, 2) = 0
			,@principal_sisa		decimal(18, 2) = 0
			,@no					int
			,@amount_after_rounding decimal(18, 2) = 0
			--
			,@first_payment_type	nvarchar(10)
			,@rounding_value		decimal(18, 2)
			,@rounding_type			nvarchar(20)
			,@rv_type				nvarchar(50)
			,@residual_value		decimal(18, 2)
			,@last_step_no			int
			,@disburse_date			datetime ;

	begin try
		if exists
		(
			select	1
			from	application_main
			where	application_no = @p_reff_no
		)
		begin
			select	@first_payment_type = at.first_payment_type
					,@rv_type = at.residual_value_type
					,@residual_value = at.residual_value_amount
					--
					,@rounding_value = at.rounding_amount
					,@rounding_type = at.rounding_type
					,@disburse_date = at.disbursement_date
			from	dbo.application_tc at
			where	application_no = @p_reff_no ;

			-- ambil step no terakhir
			select top 1
						@last_step_no = step_no
			from		dbo.application_step_period
			where		application_no = @p_reff_no
			order by	step_no desc ;
		end ;

		-- jika rv_type = national maka tidak ada sisa (residual_value = 0)
		if (@rv_type = 'NOTIONAL')
			set @residual_value = 0 ;

		if (@p_step_no = @last_step_no)
		begin
			if (@p_principal_awal < @residual_value)
			begin
				raiserror('last period step amortization can not less than total residual value. ', 16, 1) ;

				return ;
			end ;
		end ;
		else
			set @residual_value = 0 ;

		set @no = 0 ;

		if (@p_step_amount > 0)
		begin
			if (
				   @first_payment_type = 'ADV'
				   and	@p_installment_no = 0
			   )
			begin
				set @principal_sisa = @p_principal_awal ;
				set @p_principal_awal = 0 ;

				while (@no <= @p_step_installment)
				begin
					insert into dbo.amortization_calculate
					(
						user_id
						,reff_no
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
					values
					(	@p_cre_by
						,@p_reff_no
						,@p_installment_no
						,@p_due_date
						,@p_principal_awal
						,@amount_after_rounding
						,@installment_principal
						,@installment_interest
						,@principal_sisa
						--
						,@p_cre_date
						,@p_cre_by
						,@p_cre_ip_address
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
					) ;

					set @p_principal_awal = @principal_sisa ;

					if (@p_installment_no = 0)
					begin
						set @installment_amount = @p_step_amount / @p_step_installment ;

						if (@rounding_type = 'DOWN')
							set @amount_after_rounding = dbo.fn_get_floor(@installment_amount, @rounding_value) ;
						else if (@rounding_type = 'UP')
							set @amount_after_rounding = dbo.fn_get_ceiling(@installment_amount, @rounding_value) ;
						else
							set @amount_after_rounding = dbo.fn_get_round(@installment_amount, @rounding_value) ;

						set @installment_interest = 0 ;
					end ;
					else
					begin
						set @installment_interest = @p_principal_awal * (@p_eff_rate / 100) * @p_schedule_month / 12 ;
						set @installment_interest = (@amount_after_rounding - @installment_amount) + @installment_interest ;
					end ;

					set @installment_principal = @amount_after_rounding - @installment_interest ;
					set @p_due_date = dateadd(month, @p_schedule_month, @p_due_date) ;
					set @p_due_date = dbo.fn_get_next_amortization_due_date(@disburse_date, @p_due_date) ;
					set @p_principal_awal = @principal_sisa ;
					set @principal_sisa = @p_principal_awal - @installment_principal ;
					set @no += 1 ;
					set @p_installment_no += 1 ;
				end ;
			end ;
			else if (@p_installment_no = 0)
			begin
				set @principal_sisa = @p_principal_awal ;
				set @p_principal_awal = 0 ;

				while (@no <= @p_step_installment)
				begin
					insert into dbo.amortization_calculate
					(
						user_id
						,reff_no
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
					values
					(	@p_cre_by
						,@p_reff_no
						,@p_installment_no
						,@p_due_date
						,@p_principal_awal
						,@amount_after_rounding
						,@installment_principal
						,@installment_interest
						,@principal_sisa
						--
						,@p_cre_date
						,@p_cre_by
						,@p_cre_ip_address
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
					) ;

					set @p_principal_awal = @principal_sisa ;

					if (@p_installment_no = 0)
					begin
						set @installment_amount = @p_step_amount / @p_step_installment ;

						if (@rounding_type = 'DOWN')
							set @amount_after_rounding = dbo.fn_get_floor(@installment_amount, @rounding_value) ;
						else if (@rounding_type = 'UP')
							set @amount_after_rounding = dbo.fn_get_ceiling(@installment_amount, @rounding_value) ;
						else
							set @amount_after_rounding = dbo.fn_get_round(@installment_amount, @rounding_value) ;
					end ;

					set @p_due_date = dateadd(month, @p_schedule_month, @p_due_date) ;
					set @p_due_date = dbo.fn_get_next_amortization_due_date(@disburse_date, @p_due_date) ;
					set @installment_interest = @p_principal_awal * (@p_eff_rate / 100) * @p_schedule_month / 12 ;
					set @installment_principal = @installment_amount - @installment_interest ;
					set @installment_interest = (@amount_after_rounding - @installment_amount) + @installment_interest ;
					set @principal_sisa = @p_principal_awal - @installment_principal ;
					set @no += 1 ;
					set @p_installment_no += 1 ;
				end ;
			end ;
			else
			begin
		 
				if (@p_step_no = @last_step_no)
					set @installment_amount = (@p_step_amount - @residual_value) / @p_step_installment ;
				else
					set @installment_amount = @p_step_amount / @p_step_installment ;

				if (@rounding_type = 'DOWN')
					set @amount_after_rounding = dbo.fn_get_floor(@installment_amount, @rounding_value) ;
				else if (@rounding_type = 'UP')
					set @amount_after_rounding = dbo.fn_get_ceiling(@installment_amount, @rounding_value) ;
				else
					set @amount_after_rounding = dbo.fn_get_round(@installment_amount, @rounding_value) ;

				while (@no < @p_step_installment)
				begin
					set @p_due_date = dateadd(month, @p_schedule_month, @p_due_date) ;
					set @p_due_date = dbo.fn_get_next_amortization_due_date(@disburse_date, @p_due_date) ;
					set @installment_interest = @p_principal_awal * (@p_eff_rate / 100) * @p_schedule_month / 12 ;
					set @installment_principal = @installment_amount - @installment_interest ;
					set @installment_interest = (@amount_after_rounding - @installment_amount) + @installment_interest ;
					set @principal_sisa = @p_principal_awal - @installment_principal ;

					insert into dbo.amortization_calculate
					(
						user_id
						,reff_no
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
					values
					(	@p_cre_by
						,@p_reff_no
						,@p_installment_no
						,@p_due_date
						,@p_principal_awal
						,@amount_after_rounding
						,@installment_principal
						,@installment_interest
						,@principal_sisa
						--
						,@p_cre_date
						,@p_cre_by
						,@p_cre_ip_address
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
					) ;

					set @p_principal_awal = @principal_sisa ;
					set @no += 1 ;
					set @p_installment_no += 1 ;
				end ;
			end ;
		end ;
		else
		begin
			set @installment_amount = 0 ;

			if (@p_installment_no = 0)
			begin
				set @principal_sisa = @p_principal_awal ;
				set @p_principal_awal = 0 ;
				set @no = 0 ;
			end ;
			else
			begin
				set @p_due_date = dateadd(month, @p_schedule_month, @p_due_date) ;
				set @p_due_date = dbo.fn_get_next_amortization_due_date(@disburse_date, @p_due_date) ;
				set @installment_interest = 0 ;
				set @installment_principal = @installment_amount - @installment_interest ;
				set @principal_sisa = @p_principal_awal - @installment_principal ;
				set @no = 1 ;
			end ;

			while (@no <= @p_step_installment)
			begin
				select @no, * from  amortization_calculate	
				insert into dbo.amortization_calculate
				(
					user_id
					,reff_no
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
				values
				(	@p_cre_by
					,@p_reff_no
					,@p_installment_no
					,@p_due_date
					,@p_principal_awal
					,@amount_after_rounding
					,@installment_principal
					,@installment_interest
					,@principal_sisa
					--
					,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
				) ;

				set @p_principal_awal = @principal_sisa ;

				if (
					   @p_installment_no = 0
					   and	@first_payment_type = 'ADV'
				   )
				begin
					set @p_due_date = dateadd(month, @p_schedule_month, @p_due_date) ;
					set @p_due_date = dbo.fn_get_next_amortization_due_date(@disburse_date, @p_due_date) ;
				end ;

				set @installment_interest = 0 ;
				set @installment_principal = @installment_amount - @installment_interest ;
				set @principal_sisa = @p_principal_awal - @installment_principal ;
				set @no += 1 ;
				set @p_installment_no += 1 ;
			end ;
		end ;

		-- last checking
		declare @total_rental_amort		   decimal(18, 2)
				,@total_rental_step_period decimal(18, 2) ;

		select	@total_rental_amort = sum(installment_amount)
		from	dbo.amortization_calculate
		where	reff_no = @p_reff_no ;

		if exists
		(
			select	1
			from	application_main
			where	application_no = @p_reff_no
		)
		begin
			select	@total_rental_step_period = sum(recovery_installment_amount)
			from	dbo.application_step_period
			where	application_no		= @p_reff_no
					and step_no <= @p_step_no ;
		end ;
		else
		begin
			select	@total_rental_step_period = sum(recovery_installment_amount)
			from	dbo.drawdown_step_period
			where	drawdown_no		= @p_reff_no
					and step_no <= @p_step_no ;
		end ;

		if abs(@total_rental_amort - @total_rental_step_period) <> 0
		begin
			select top 1
						@installment_principal = installment_principal_amount
						,@installment_interest = installment_interest_amount
						,@principal_sisa = os_principal_amount
						,@p_installment_no = installment_no
			from		dbo.amortization_calculate
			where		reff_no = @p_reff_no
			order by	installment_no desc ;

			set @installment_principal = @installment_principal - ((@total_rental_step_period - @residual_value) - @total_rental_amort) ;
			set @installment_interest = @installment_interest + ((@total_rental_step_period - @residual_value) - @total_rental_amort) ;
			set @principal_sisa = @principal_sisa + ((@total_rental_step_period - @residual_value) - @total_rental_amort) ;

			update	amortization_calculate
			set		installment_principal_amount = @installment_principal
					,installment_interest_amount = @installment_interest
					,os_principal_amount = @principal_sisa
			where	installment_no = @p_installment_no
					and reff_no	   = @p_reff_no ;
		end ;

		-- untuk mencari total principal
		declare @total_installment_principal decimal(18, 2) ;

		select	@total_installment_principal = sum(installment_principal_amount)
		from	dbo.amortization_calculate
		where	reff_no = @p_reff_no
				and installment_no
				between @p_installment_awal and @p_installment_no ;

		-- validasi amount tidak boleh minus
		if (@total_installment_principal < 0)
		begin
			raiserror('you should be input greater amount !', 16, -1) ;

			return ;
		end ;

		-- update total principal
		if exists
		(
			select	1
			from	application_main
			where	application_no = @p_reff_no
		)
		begin
			update	dbo.application_step_period
			set		recovery_principal_amount = @total_installment_principal
			where	application_no		= @p_reff_no
					and step_no = @p_step_no ;
		end ;
		else
		begin
			update	dbo.drawdown_step_period
			set		recovery_principal_amount = @total_installment_principal
			where	drawdown_no		= @p_reff_no
					and step_no = @p_step_no ;
		end ;

		-- ngupdate principal di application asset step biar jumlah principal sama dengan jumlah leasead_amount
		declare @total_principal_step_period decimal(18, 2)
				,@principal_outstanding		 decimal(18, 2) ;

		-- menghitung total principal
		if exists
		(
			select	1
			from	application_main
			where	application_no = @p_reff_no
		)
		begin
			select	@total_principal_step_period = sum(recovery_principal_amount)
			from	dbo.application_step_period
			where	application_no		= @p_reff_no
					and step_no < @last_step_no ;
		end ;
		else
		begin
			select	@total_principal_step_period = sum(recovery_principal_amount)
			from	dbo.drawdown_step_period
			where	drawdown_no		= @p_reff_no
					and step_no < @last_step_no ;
		end ;

		set @principal_outstanding = @p_leadsead_amount - @total_principal_step_period ;

		-- update principal di step terakhir
		if exists
		(
			select	1
			from	application_main
			where	application_no = @p_reff_no
		)
		begin
			update	dbo.application_step_period
			set		recovery_principal_amount = @principal_outstanding
			where	application_no		= @p_reff_no
					and step_no = @last_step_no ;
		end ;
		else
		begin
			update	dbo.drawdown_step_period
			set		recovery_principal_amount = @principal_outstanding
			where	drawdown_no		= @p_reff_no
					and step_no = @last_step_no ;
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

