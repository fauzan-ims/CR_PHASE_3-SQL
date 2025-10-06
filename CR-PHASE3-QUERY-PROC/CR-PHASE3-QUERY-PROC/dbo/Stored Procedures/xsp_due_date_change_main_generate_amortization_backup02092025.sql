CREATE PROCEDURE [dbo].[xsp_due_date_change_main_generate_amortization_backup02092025]
(
	@p_asset_no				 nvarchar(50)
	,@p_due_date_change_code nvarchar(50)
	--
	,@p_mod_date			 datetime
	,@p_mod_by				 nvarchar(15)
	,@p_mod_ip_address		 nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max)
			,@due_date					datetime
			,@no						int
			,@schedule_month			int
			,@first_duedate				datetime
			,@billing_date				datetime
			,@billing_mode				nvarchar(10)
			,@billing_mode_date			int
			,@lease_rounded_amount		decimal(18, 2)
			,@installment_amount		decimal(18, 2)
			,@description				nvarchar(4000)
			,@max_billing_no			int
			,@first_payment_type		nvarchar(3)
			,@new_due_date_day			datetime
			,@at_installment_no			int
			,@total_days				int
			,@propotional_rental_amount decimal(18, 2)
			,@max_installment_no		int
			,@maximum_duedate			datetime
			,@maturity_date				datetime
			,@due_date_day				datetime 
			,@handover_bast_date		datetime
			,@periode					int
			,@rounding_type				nvarchar(20)
			,@rounding_value			decimal(18, 2)
			,@bast_asset_date			datetime
			,@total_real_day			int
			,@is_every_eom				nvarchar(1)

	begin try
	 
		-- mengambil multipier di master payment schedule
		select	@schedule_month				= multiplier
				,@billing_mode				= aa.billing_mode
				,@billing_mode_date			= aa.billing_mode_date
				,@first_payment_type		= am.first_payment_type
				,@due_date					= ddcd.new_due_date_day --dateadd(month, mbt.multiplier, ddcd.new_due_date_day)
				,@new_due_date_day			= ddcd.new_due_date_day
				,@at_installment_no			= ddcd.at_installment_no
				,@handover_bast_date		= aa.handover_bast_date
				,@periode					= aa.periode
				,@rounding_value			= aa.lease_round_amount
				,@rounding_type				= aa.lease_round_type
				,@is_every_eom				= ddcd.is_every_eom
		from	dbo.due_date_change_detail ddcd
				inner join dbo.agreement_asset aa		on (aa.asset_no		= ddcd.asset_no)
				inner join dbo.master_billing_type mbt	on (mbt.code		= aa.billing_type)
				inner join dbo.agreement_main am		on (am.agreement_no = aa.agreement_no) 
		where	ddcd.asset_no					= @p_asset_no
				and ddcd.due_date_change_code	= @p_due_date_change_code ;
				
		set @handover_bast_date = dateadd(month, @periode, @handover_bast_date)

		select	@maximum_duedate = max(due_date)
		from	dbo.agreement_asset_amortization
		where	asset_no = @p_asset_no ;


		delete dbo.due_date_change_amortization_history
		where	due_date_change_code = @p_due_date_change_code
				and asset_no		 = @p_asset_no
				and old_or_new		 = 'NEW' ;

		-- ambil maturity
		begin
			if @first_payment_type = 'ADV'
			begin
				select	@total_days = abs(datediff(day, due_date, @due_date))
						,@total_real_day = abs(datediff(day, due_date, dateadd(month, @schedule_month, due_date)))
						,@lease_rounded_amount = billing_amount
				from	dbo.agreement_asset_amortization
				where	asset_no	   = @p_asset_no
						and billing_no = @at_installment_no ;

				set @maturity_date = @handover_bast_date ;
			end ;
			else
			begin 
				if @at_installment_no = '1'
				begin
					if exists
					(
						select	1
						from	agreement_asset_amortization
						where	asset_no	   = @p_asset_no
								and billing_no = @at_installment_no
								and due_date   > @due_date
					)
					begin 
						select	@bast_asset_date = handover_bast_date
								,@total_real_day = abs(datediff(day, handover_bast_date, dateadd(month, @schedule_month, handover_bast_date)))
						from	dbo.agreement_asset
						where	asset_no = @p_asset_no ;

						select	@total_days = abs(datediff(day, @due_date, @bast_asset_date))
								,@lease_rounded_amount = billing_amount
						from	dbo.agreement_asset_amortization
						where	asset_no	   = @p_asset_no
								and billing_no = @at_installment_no ;
					end ;
					else
					begin
						select	@total_days = abs(datediff(day, @due_date, due_date))
								,@total_real_day = abs(datediff(day, due_date, dateadd(month, @schedule_month, due_date)))
								,@lease_rounded_amount = billing_amount
						from	dbo.agreement_asset_amortization
						where	asset_no	   = @p_asset_no
								and billing_no = @at_installment_no ;
					end ;
				end
                else
                begin
					select	@total_days = abs(datediff(day, @due_date, due_date))
							,@total_real_day = abs(datediff(day, due_date, dateadd(month, @schedule_month, due_date)))
							,@lease_rounded_amount = billing_amount
					from	dbo.agreement_asset_amortization
					where	asset_no	   = @p_asset_no
							and billing_no = @at_installment_no -1;
					--select	@total_real_day = day(eomonth(new_due_date_day)) --(+)raffy 2025/02/21
					--from	dbo.due_date_change_detail
					--where	due_date_change_code = @p_due_date_change_code
					--and		asset_no		=  @p_asset_no
				end
				--set @due_date = dateadd(month, @schedule_month, @new_due_date_day)

				set @maturity_date = @maximum_duedate ;

			end ;

		end ;
		
		set @no = 1
		set @first_duedate = @due_date ;
		 
		set @propotional_rental_amount = dbo.fn_get_ceiling(((@total_days * 1.0 / @total_real_day * 1.0) * @lease_rounded_amount), 1) ; 

		insert into dbo.due_date_change_amortization_history
		(
			due_date_change_code
			,installment_no
			,asset_no
			,due_date
			,billing_date
			,billing_amount
			,description
			,old_or_new
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	@p_due_date_change_code
				,billing_no
				,@p_asset_no
				,due_date
				,billing_date
				,billing_amount
				,description
				,'NEW'
				--
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.agreement_asset_amortization
		where	asset_no	 = @p_asset_no
				and billing_no < @at_installment_no ; 

		if (@first_payment_type = 'ADV')
		begin
			select	@due_date_day = due_date
			from	dbo.agreement_asset_amortization
			where	asset_no	   = @p_asset_no
					and billing_no = @at_installment_no ;

			set @description = 'Billing ke ' + cast(@at_installment_no as nvarchar(15)) + ' dari Periode ' + convert(varchar(30), dateadd(day,1,@due_date_day), 103) + ' Sampai dengan ' + convert(varchar(30), @due_date, 103) ;
			
			insert into dbo.due_date_change_amortization_history
			(
				due_date_change_code
				,installment_no
				,asset_no
				,due_date
				,billing_date
				,billing_amount
				,description
				,old_or_new
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	@p_due_date_change_code
					,billing_no
					,@p_asset_no
					,due_date
					,billing_date
					,@propotional_rental_amount
					,@description
					,'NEW'
					--
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
			from	dbo.agreement_asset_amortization
			where	asset_no	   = @p_asset_no
					and billing_no = @at_installment_no ; 
		end ;
		else
		begin
					 
			select	@due_date_day = dateadd(month, (@schedule_month * (-1)), due_date)
			from	dbo.agreement_asset_amortization
			where	asset_no	   = @p_asset_no
					and billing_no = @at_installment_no ; 

			set @description = 'Billing ke ' + cast(@at_installment_no as nvarchar(15)) + ' dari Periode ' + convert(varchar(30), dateadd(day,1,@due_date_day), 103) + ' Sampai dengan ' + convert(varchar(30), @new_due_date_day, 103) ;
				 
			
			insert into dbo.due_date_change_amortization_history
			(
				due_date_change_code
				,installment_no
				,asset_no
				,due_date
				,billing_date
				,billing_amount
				,description
				,old_or_new
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	@p_due_date_change_code
					,billing_no
					,@p_asset_no
					,@new_due_date_day
					,@new_due_date_day
					,@propotional_rental_amount
					,@description
					,'NEW'
					--
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
			from	dbo.agreement_asset_amortization
			where	asset_no	   = @p_asset_no
					and billing_no = @at_installment_no 
		end ;
		 
		set @max_billing_no = 0 ;

		select	@max_billing_no		= max(installment_no) + 1
		from	dbo.due_date_change_amortization_history
		where	due_date_change_code = @p_due_date_change_code
				and asset_no		 = @p_asset_no
				and old_or_new		 = 'NEW' ;

		declare @duedate_next		datetime
				,@start_due_date	datetime
				,@new_billing_date	datetime
				,@new_due_date		datetime
				,@new_due_date_next datetime ; 

		set @duedate_next = @due_date ;
		 
		while (@duedate_next < @maturity_date)
		begin
			
			--sementara untuk endofmonth
			if @is_every_eom = '1'
			begin
				set @duedate_next = eomonth(@duedate_next) ;
			end ;
			else
			begin
				set @duedate_next = @duedate_next ;
			end ;

			set @start_due_date = dateadd(day,1,@duedate_next)

			if (@first_payment_type = 'ADV')
			begin
			
				if @is_every_eom = '1'
				begin
					set @description = 'Billing ke ' + cast(@max_billing_no as nvarchar(15)) + ' dari Periode ' + convert(varchar(30), @start_due_date, 103) + ' Sampai dengan ' + convert(varchar(30), eomonth(dateadd(month, (@schedule_month * (1)), @duedate_next)), 103) ;
				end
				else
				begin
					set @description = 'Billing ke ' + cast(@max_billing_no as nvarchar(15)) + ' dari Periode ' + convert(varchar(30), @start_due_date, 103) + ' Sampai dengan ' + convert(varchar(30), dateadd(month, (@schedule_month * (1)), @duedate_next), 103) ;
				end

				set @new_billing_date	= @duedate_next
				set @new_due_date		= @duedate_next
			end ;
			else
			begin
				if @is_every_eom = '1'
				begin
					set @description = 'Billing ke ' + cast(@max_billing_no as nvarchar(15)) + ' dari Periode ' + convert(varchar(30), @start_due_date, 103) + ' Sampai dengan ' + convert(varchar(30), eomonth(dateadd(month, (@schedule_month * (1)), @duedate_next)), 103) ;
				end
				else
				begin
					set @description = 'Billing ke ' + cast(@max_billing_no as nvarchar(15)) + ' dari Periode ' + convert(varchar(30), @duedate_next, 103) + ' Sampai dengan ' + convert(varchar(30), dateadd(month, (@schedule_month * (1)), @duedate_next), 103) ;
				end	 

				if (dateadd(month, (@schedule_month * (1)), @duedate_next) <> eomonth(dateadd(month, (@schedule_month * (1)), @duedate_next)))
				begin
					set @new_due_date_next	= dateadd(month, (@schedule_month * (1)), @duedate_next)
					set @new_due_date		= datefromparts(year(@new_due_date_next), month(@new_due_date_next), day(@first_duedate)) ;
					set @new_billing_date	= datefromparts(year(@new_due_date_next), month(@new_due_date_next), day(@first_duedate)) ;
				end
				else
				begin
					set @new_billing_date	= dateadd(month, (@schedule_month * (1)), @duedate_next)
					set @new_due_date		= dateadd(month, (@schedule_month * (1)), @duedate_next)
				end
			end ;
			
			--convert to endofmonth if is_every_eom = '1'
			if @is_every_eom = '1'
			begin
				set @new_due_date = eomonth(@new_due_date)
				set @new_billing_date = eomonth(@new_billing_date)
			end

			set @installment_amount = @lease_rounded_amount ;

			if (@billing_mode = 'BY DATE')
			begin
				if (day(@new_due_date) < @billing_mode_date)
				begin
					set @new_billing_date = dateadd(month, -1, @new_due_date) ;

					if (day(eomonth(@new_billing_date)) < @billing_mode_date)
					begin
						set @new_billing_date = datefromparts(year(@new_billing_date), month(@new_billing_date), day(eomonth(@new_billing_date))) ;
					end ;
					else
					begin
						set @new_billing_date = datefromparts(year(@new_billing_date), month(@new_billing_date), @billing_mode_date) ;
					end ;
				end ;
				else
				begin
					set @new_billing_date = datefromparts(year(@new_due_date), month(@new_due_date), @billing_mode_date) ;
				end ;
			end ;
			else if (@billing_mode = 'BEFORE DUE')
			begin
				set @new_billing_date = dateadd(day, @billing_mode_date * -1, @new_due_date) ;
			end ;
			else
			begin
				set @new_billing_date = @new_due_date ;
			end ;

			exec dbo.xsp_due_date_change_amortization_history_insert @p_due_date_change_code	= @p_due_date_change_code
																	 ,@p_installment_no			= @max_billing_no
																	 ,@p_asset_no				= @p_asset_no
																	 ,@p_due_date				= @new_due_date
																	 ,@p_billing_date			= @new_billing_date
																	 ,@p_billing_amount			= @installment_amount
																	 ,@p_description			= @description
																	 ,@p_old_or_new				= 'NEW'
																	 ,@p_cre_date				= @p_mod_date
																	 ,@p_cre_by					= @p_mod_by
																	 ,@p_cre_ip_address			= @p_mod_ip_address
																	 ,@p_mod_date				= @p_mod_date
																	 ,@p_mod_by					= @p_mod_by
																	 ,@p_mod_ip_address			= @p_mod_ip_address ;
			
			set @duedate_next = dateadd(month, (@no * @schedule_month), @first_duedate) ; -- tambah bulan

			set @no += 1 ;
			set @max_billing_no += 1 ;

			set @new_due_date		= null
			set @new_billing_date	= null
			set @installment_amount	= null
			set @description		= null
		end ; 
		 
		select		@max_installment_no		= max(installment_no)
					,@due_date_day			= max(due_date)
		from		dbo.due_date_change_amortization_history
		where		asset_no				 = @p_asset_no
					and due_date_change_code = @p_due_date_change_code
					and old_or_new			 = 'NEW'
					
		select		@new_due_date_day		= due_date
		from		dbo.due_date_change_amortization_history
		where		asset_no				 = @p_asset_no
					and due_date_change_code = @p_due_date_change_code
					and installment_no		 = @max_installment_no
					and old_or_new			 = 'NEW'

		select	@due_date = due_date
		from	dbo.agreement_asset_amortization
		where	asset_no	   = @p_asset_no
				and billing_no = @max_installment_no - 1 ;

		if (@first_payment_type = 'ADV')
		begin
			set @description = 'Billing ke ' + cast(@max_installment_no as nvarchar(15)) + ' dari Periode ' + convert(varchar(30), dateadd(day,1,@new_due_date_day), 103) + ' Sampai dengan ' + convert(varchar(30), dateadd(month, @schedule_month, @due_date), 103) ;

			update	dbo.due_date_change_amortization_history
			set		description				= @description
					,billing_amount			= billing_amount - @propotional_rental_amount
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	due_date_change_code	= @p_due_date_change_code
					and installment_no		= @max_installment_no
					and asset_no			= @p_asset_no
					and old_or_new			= 'NEW'
		end ;
		else
		begin
		  
			--insert into dbo.due_date_change_amortization_history
			--(
			--	due_date_change_code
			--	,installment_no
			--	,asset_no
			--	,due_date
			--	,billing_date
			--	,billing_amount
			--	,description
			--	,old_or_new
			--	--
			--	,cre_date
			--	,cre_by
			--	,cre_ip_address
			--	,mod_date
			--	,mod_by
			--	,mod_ip_address
			--)
			--select	@p_due_date_change_code
			--		,billing_no + 1
			--		,asset_no
			--		,due_date
			--		,billing_date
			--		,billing_amount - @propotional_rental_amount
			--		,description
			--		,'NEW'
			--		--
			--		,@p_mod_date
			--		,@p_mod_by
			--		,@p_mod_ip_address
			--		,@p_mod_date
			--		,@p_mod_by
			--		,@p_mod_ip_address
			--from	dbo.agreement_asset_amortization
			--where	asset_no	   = @p_asset_no
			--		and billing_no = @max_installment_no ;

			--select	@due_date_day = min(due_date)
			--from	dbo.due_date_change_amortization_history
			--where	due_date_change_code = @p_due_date_change_code
			--		and asset_no		 = @p_asset_no
			--		and installment_no	 = @max_installment_no ;

			select	@max_installment_no		= max(installment_no)
					,@due_date				= max(due_date)
					,@due_date_day			= max(due_date)
			from	dbo.due_date_change_amortization_history
			where	due_date_change_code	= @p_due_date_change_code
					and asset_no			= @p_asset_no 
					and old_or_new			 = 'NEW'
				 
			set @description = 'Billing ke ' + cast(@max_installment_no as nvarchar(15)) + ' dari Periode ' + convert(varchar(30), dateadd(day,1,dateadd(month, (@schedule_month * (-1)), @due_date_day)), 103) + ' Sampai dengan ' + convert(varchar(30), @maturity_date, 103) ;
			
			if (@billing_mode = 'BY DATE')
			begin
				if (day(@maturity_date) < @billing_mode_date)
				begin
					set @new_billing_date = dateadd(month, -1, @maturity_date) ;

					if (day(eomonth(@new_billing_date)) < @billing_mode_date)
					begin
						set @new_billing_date = datefromparts(year(@new_billing_date), month(@new_billing_date), day(eomonth(@new_billing_date))) ;
					end ;
					else
					begin
						set @new_billing_date = datefromparts(year(@new_billing_date), month(@new_billing_date), @billing_mode_date) ;
					end ;
				end ;
				else
				begin
					set @new_billing_date = datefromparts(year(@maturity_date), month(@maturity_date), @billing_mode_date) ;
				end ;
			end ;
			else if (@billing_mode = 'BEFORE DUE')
			begin
				set @new_billing_date = dateadd(day, @billing_mode_date * -1, @maturity_date) ;
			end ;
			else
			begin
				set @new_billing_date = @maturity_date ;
			end ;
		
			update	dbo.due_date_change_amortization_history
			set		description				= @description
					,billing_amount			= billing_amount - @propotional_rental_amount
					,due_date				= @maturity_date
					,billing_date			= @new_billing_date
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	due_date_change_code	= @p_due_date_change_code
					and asset_no			= @p_asset_no
					and installment_no		= @max_installment_no ;
		end ; 
	end try
	begin catch
		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;


