CREATE PROCEDURE [dbo].[xsp_amortization_update_first_due_date]
(
	@p_reff_no			nvarchar(50)
	,@p_bast_date	   datetime
	,@p_first_date	   int
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	begin try
		declare @from_inst_no				int		   = 1
				,@multiplier				int
				,@first_payment_type		nvarchar(10)
				,@amort_inst_no				int
				,@amort_inst_no_update		int
				,@total_day					int
				,@day_in_month				int
				,@principal_awal			decimal(18,2)
				,@interest_rate				decimal(9,6)
				,@interim_interest			decimal(18,2)
				,@rounding_type				nvarchar(20)
				,@rounding_value			decimal(18,2)
				,@temp_date					datetime
				,@inst_principal_awal		decimal(18,2)
				,@inst_installment			decimal(18,2)
				,@day_duedate_awal			int

				,@next_date					datetime	   = getdate()
				,@msg						nvarchar(4000) ;

		if exists (select 1 from dbo.application_main where application_no = @p_reff_no)
		begin
			select	@first_payment_type = first_payment_type
					,@multiplier		= mps.multiplier
			from	dbo.application_tc atc
					inner join master_payment_schedule mps on payment_schedule_type_code = code
			where	application_no		= @p_reff_no ;
		end
		else
		begin
			select	@first_payment_type = first_payment_type
					,@multiplier		= mps.multiplier
			from	dbo.drawdown_tc atc
					inner join master_payment_schedule mps on payment_schedule_type_code = code
			where	drawdown_no		= @p_reff_no ;
		end

		if (@first_payment_type = 'ADV')
		begin
			set @from_inst_no = 2 ;
		end ;

		
		if exists (select 1 from dbo.application_main where application_no = @p_reff_no)
		begin
			update	dbo.application_amortization
			set		due_date			= @p_bast_date
			where	application_no		= @p_reff_no
					and installment_no	< @from_inst_no ;
		end
		else
		begin
			update	dbo.drawdown_amortization
			set		due_date			= @p_bast_date
			where	drawdown_no			= @p_reff_no
					and installment_no	< @from_inst_no ;
		end


		declare curr_amort cursor fast_forward read_only for
			select	installment_no
			from	dbo.application_amortization
			where	application_no	   = @p_reff_no
					and installment_no >= @from_inst_no 
			union
			select	installment_no
			from	dbo.drawdown_amortization
			where	drawdown_no			= @p_reff_no
					and installment_no >= @from_inst_no ;

		open curr_amort ;

		fetch next from curr_amort
		into @amort_inst_no

		while @@fetch_status = 0
		begin
			if (@first_payment_type = 'adv')
			begin
				set @amort_inst_no_update = (@amort_inst_no - 1 ) * @multiplier;
			end ;
			else
			begin
				set @amort_inst_no_update = @amort_inst_no * @multiplier ;
			end ;

			begin try
				set @next_date = dateadd(month, (@amort_inst_no_update), @p_bast_date) ;
				set @next_date = left(convert(char(10), cast(@next_date as date), 126), 8) + convert(nvarchar(2), @p_first_date) ;
			end try
			begin catch
				begin try
					set @next_date = dateadd(month, (@amort_inst_no_update), @p_bast_date) ;
					set @next_date = left(convert(char(10), cast(@next_date as date), 126), 8) + convert(nvarchar(2), (@p_first_date - 1)) ;
				end try
				begin catch
					begin try
						set @next_date = dateadd(month, (@amort_inst_no_update), @p_bast_date) ;
						set @next_date = left(convert(char(10), cast(@next_date as date), 126), 8) + convert(nvarchar(2), (@p_first_date - 2)) ;
					end try
					begin catch
						set @next_date = dateadd(month, (@amort_inst_no_update), @p_bast_date) ;
						set @next_date = left(convert(char(10), cast(@next_date as date), 126), 8) + convert(nvarchar(2), (@p_first_date - 3)) ;
					end catch
				end catch
			end catch ;
			
			if exists (select 1 from dbo.application_main where application_no = @p_reff_no)
			begin
				update	dbo.application_amortization
				set		due_date			= @next_date
						,mod_date			= @p_mod_date
						,mod_by				= @p_mod_by
						,mod_ip_address		= @p_mod_ip_address
				where	application_no		= @p_reff_no
						and installment_no	= @amort_inst_no ;
			end
			else
			begin
				update	dbo.drawdown_amortization
				set		due_date			= @next_date
						,mod_date			= @p_mod_date
						,mod_by				= @p_mod_by
						,mod_ip_address		= @p_mod_ip_address
				where	drawdown_no			= @p_reff_no
						and installment_no	= @amort_inst_no ;
			end

			fetch next from curr_amort
			into @amort_inst_no
		end ;

		close curr_amort ;
		deallocate curr_amort ;

		set @day_in_month =day(eomonth (@p_bast_date))

		-- interim interest
		if exists (select 1 from dbo.application_main where application_no = @p_reff_no)
		begin
			update	dbo.application_tc
			set		last_due_date				= @next_date -- date berasal dari last cursor
			where	application_no				= @p_reff_no 

			select	@interest_rate			= at.interest_eff_rate_after_rounding
					,@rounding_type			= at.rounding_type
					,@rounding_value		= at.rounding_amount
			from	dbo.application_main am
					inner join dbo.application_tc at on ( at.application_no = am.application_no )
			where	am.application_no		= @p_reff_no

			select	@principal_awal =  os_principal_amount
			from	dbo.application_amortization
			where	application_no	   = @p_reff_no
					and installment_no = @from_inst_no - 1 ;

			select	@total_day				= datediff(day,@p_bast_date,due_date)
					,@inst_principal_awal	= installment_principal_amount
					,@day_duedate_awal		= day(due_date)
			from	dbo.application_amortization
			where	application_no			= @p_reff_no 
			and		installment_no			= @from_inst_no 
			 
			
			if (day(@p_bast_date) = @day_duedate_awal)
			begin
				select	@interim_interest = interest_for_first_duedate_amount
				from	dbo.application_information
				where	application_no = @p_reff_no ;
			end
			else
			begin
				set @interim_interest =  @principal_awal * (@interest_rate/100) * @multiplier * @total_day / 360 ;
			end

			if (@rounding_type = 'DOWN')
				set @inst_installment = dbo.fn_get_floor((@inst_principal_awal+@interim_interest), @rounding_value) ;
			else if (@rounding_type = 'UP')
				set @inst_installment = dbo.fn_get_ceiling((@inst_principal_awal+@interim_interest), @rounding_value) ;
			else
				set @inst_installment = dbo.fn_get_round((@inst_principal_awal+@interim_interest), @rounding_value) ;

			select @inst_installment
			update	dbo.application_amortization
			set		installment_interest_amount = @inst_installment - @inst_principal_awal
					,installment_amount			= @inst_installment
			where	application_no				= @p_reff_no 
			and		installment_no				= @from_inst_no
		end
		else
		begin
			update	dbo.drawdown_tc
			set		last_due_date				= @next_date -- date berasal dari last cursor
			where	drawdown_no					= @p_reff_no 

			select	@interest_rate			= at.interest_eff_rate_after_rounding
					,@rounding_type			= at.rounding_type
					,@rounding_value		= at.rounding_amount
			from	dbo.drawdown_main am
					inner join dbo.drawdown_tc at on ( at.drawdown_no = am.drawdown_no )
			where	am.drawdown_no		= @p_reff_no

			select	@principal_awal =  os_principal_amount
			from	dbo.drawdown_amortization
			where	drawdown_no	   = @p_reff_no
					and installment_no = @from_inst_no - 1 ;

			select	@total_day				= datediff(day,@p_bast_date,due_date)
					,@inst_principal_awal	= installment_principal_amount
					,@day_duedate_awal		= day(due_date)
			from	dbo.drawdown_amortization
			where	drawdown_no			= @p_reff_no 
			and		installment_no			= @from_inst_no 
			
			if (day(@p_bast_date) = @day_duedate_awal)
			begin
				select	@interim_interest = interest_for_first_duedate_amount
				from	dbo.drawdown_information
				where	drawdown_code = @p_reff_no ;
			end
			else
			begin
				set @interim_interest =  @principal_awal * (@interest_rate/100) * @multiplier * @total_day / 360 ;
			end


			
			if (@rounding_type = 'DOWN')
				set @inst_installment = dbo.fn_get_floor((@inst_principal_awal+@interim_interest), @rounding_value) ;
			else if (@rounding_type = 'UP')
				set @inst_installment = dbo.fn_get_ceiling((@inst_principal_awal+@interim_interest), @rounding_value) ;
			else
				set @inst_installment = dbo.fn_get_round((@inst_principal_awal+@interim_interest), @rounding_value) ;

			 
			update	dbo.drawdown_amortization
			set		installment_interest_amount = @inst_installment - @inst_principal_awal
					,installment_amount			= @inst_installment
			where	drawdown_no					= @p_reff_no 
			and		installment_no				= @from_inst_no

		
		end

		-- update last due date di tc

	end try
	begin catch

		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;





