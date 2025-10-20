CREATE PROCEDURE dbo.xsp_due_date_change_main_generate_amortization
(
	@p_asset_no				 NVARCHAR(50)
	,@p_due_date_change_code NVARCHAR(50)
	--
	,@p_mod_date			 DATETIME
	,@p_mod_by				 NVARCHAR(15)
	,@p_mod_ip_address		 NVARCHAR(15)
)
AS
BEGIN
	DECLARE @msg						NVARCHAR(MAX)
			,@due_date					DATETIME
			,@no						INT
			,@schedule_month			INT
			,@first_duedate				DATETIME
			,@billing_date				DATETIME
			,@billing_mode				NVARCHAR(10)
			,@billing_mode_date			INT
			,@lease_rounded_amount		DECIMAL(18, 2)
			,@installment_amount		DECIMAL(18, 2)
			,@description				NVARCHAR(4000)
			,@max_billing_no			INT
			,@first_payment_type		NVARCHAR(3)
			,@new_due_date_day			DATETIME
			,@at_installment_no			INT
			,@total_days				INT
			,@propotional_rental_amount DECIMAL(18, 2)
			,@max_installment_no		INT
			,@maximum_duedate			DATETIME
			,@maturity_date				DATETIME
			,@due_date_day				datetime 
			,@handover_bast_date		datetime
			,@periode					int
			,@rounding_type				nvarchar(20)
			,@rounding_value			decimal(18, 2)
			,@total_real_day			int
			,@is_every_eom				nvarchar(1)
			--
			,@duedate_next				datetime
			,@start_due_date			datetime
			--,@new_billing_date			datetime
			,@new_due_date				datetime
			,@new_due_date_next			datetime 
			--
			,@prorate					nvarchar(15)
			,@is_change_billing_date	nvarchar(1)
			,@is_change_due_date		nvarchar(1)
			,@new_billing_date			datetime
			,@tenor						int
            ,@billing_amount			decimal(18,2)
			,@maturity_date_asset		datetime
            ,@last_due_date				datetime
			,@end_date					datetime
			,@start_date				datetime
            ,@jarak_hari_duedate		int
			 ,@jarak_hari_billingmode	int
			,@billing_amount_prorate	decimal
            ,@loop						int
			,@date_for_billing			int	
			--
	begin try
	
		-- mengambil multipier di master payment schedule
		select	@schedule_month				= multiplier
				,@due_date					= ddcd.new_due_date_day --dateadd(month, mbt.multiplier, ddcd.new_due_date_day)
				,@new_due_date_day			= ddcd.new_due_date_day
				,@at_installment_no			= ddcd.at_installment_no
				,@handover_bast_date		= aa.handover_bast_date
				,@periode					= aa.periode
				,@rounding_value			= aa.lease_round_amount
				,@rounding_type				= aa.lease_round_type
				,@is_every_eom				= ddcd.is_every_eom
				--
				,@is_change_billing_date	= ddcd.is_change_billing_date
				,@is_change_due_date		= ddcd.is_change
				,@new_billing_date			= ddcd.new_billing_date
				--,@maturity_date			= aa.maturity_date
				--
				,@billing_mode				= ddcd.billing_mode
				,@first_payment_type		= am.first_payment_type
				,@prorate					= isnull(ddcd.prorate,'no')
				,@tenor						= am.periode
				,@lease_rounded_amount		= aa.monthly_rental_rounded_amount
				,@maturity_date_asset		= aa.maturity_date
				,@date_for_billing			= ddcd.date_for_billing
		from	dbo.due_date_change_detail ddcd
				inner join dbo.agreement_asset aa		on (aa.asset_no		= ddcd.asset_no)
				inner join dbo.master_billing_type mbt	on (mbt.code		= aa.billing_type)
				inner join dbo.agreement_main am		on (am.agreement_no = aa.agreement_no) 
		where	ddcd.asset_no					= @p_asset_no
				and ddcd.due_date_change_code	= @p_due_date_change_code ;
		
		delete dbo.due_date_change_amortization_history
		where	due_date_change_code = @p_due_date_change_code
				and asset_no		 = @p_asset_no
				and installment_no	>= @at_installment_no

		select	top 1 @first_duedate = due_date
		from	dbo.agreement_asset_amortization
		where	asset_no = @p_asset_no
		and		billing_no <= @at_installment_no
		order by billing_no desc	

		set @no = @at_installment_no ;
		set @maturity_date_asset = isnull(@maturity_date_asset,(dateadd(month, @tenor, @handover_bast_date)))
		set @propotional_rental_amount = dbo.fn_get_ceiling(((@total_days * 1.0 / @total_real_day * 1.0) * @lease_rounded_amount), 1) ; 
		set @billing_date = @new_billing_date

		if (@is_change_due_date = '1')
		begin
		    set @loop = (@tenor / @schedule_month)+1
			set @due_date = @new_due_date_day
		end
		else
        begin
             set @loop = (@tenor / @schedule_month)
			 set @due_date = @first_duedate

			 select	top 1 @due_date = due_date
			from	dbo.agreement_asset_amortization
			where	asset_no = @p_asset_no
			and		billing_no = @at_installment_no
			order by billing_no desc	
        end
	
		while (@no <= @loop)
			begin  
				-- jika @is_change_due_date = 1, maka yang berubah change due date dan billing amount, jika is_change_billing_date = 1, yang berubah billing datenya.
				if (@is_change_due_date = '1' and isnull(@is_change_billing_date,'0') = '0')
				begin
					if(@prorate = 'YES' and @first_payment_type = 'ARR')
					begin
						set @due_date = eomonth(@due_date)
					end
                    else if(@prorate = 'YES' and @first_payment_type = 'ADV')
					begin
						set @due_date = (datefromparts(year(@due_date), month(@due_date), 1))
					end
		
					if (@due_date > @maturity_date_asset) 
					begin
						set @due_date = @maturity_date_asset
					end	
					else
                    begin
					  set @due_date		= @due_date
                    end
					
					select	@billing_date = billing_date
					from	dbo.agreement_asset_amortization
					where	asset_no	= @p_asset_no
					and		billing_no	= @no
				end
				else if (@is_change_due_date = '0' and isnull(@is_change_billing_date,'0') = '1')
                begin
			
					if (@billing_mode = 'END MONTH')
					begin
						set @billing_date = eomonth(@billing_date)
					end
                    else if (@billing_mode = 'BY DATE')
					begin
						if (day(@billing_date) < @date_for_billing)
						begin
							set @billing_date = eomonth(@billing_date)
						end
						else
                        begin
							set @billing_date = datefromparts(year(@billing_date), month(@billing_date), @date_for_billing);
                        end
					end
                    else if (@billing_mode = 'BEFORE DUE')
					begin
					    set @billing_date = dateadd(day, -1 * @date_for_billing, @due_date)
					end
					else if (@billing_mode = 'NORMAL')
                    begin
						if (day(@billing_date) < day(@new_billing_date))
						begin
							set @billing_date = eomonth(@billing_date)
						end
						else
                        begin
							set @billing_date = datefromparts(year(@billing_date), month(@billing_date), day(@new_billing_date));
                        end
                    end

					select	@due_date = due_date
							,@billing_amount = billing_amount
					from	dbo.agreement_asset_amortization
					where	asset_no	= @p_asset_no
					and		billing_no	= @no
                end
				else
                begin
					if(@prorate = 'YES' and @first_payment_type = 'ARR')
					begin
						set @due_date = eomonth(@due_date)
					end
                    else if(@prorate = 'YES' and @first_payment_type = 'ADV')
					begin
						set @due_date = (datefromparts(year(@due_date), month(@due_date), 1))
					end
			
					if (@due_date > @maturity_date_asset) 
					begin
						set @due_date = @maturity_date_asset
					end
					else
						set @due_date		= @due_date

					if (@billing_mode = 'END MONTH')
					begin
						set @billing_date = eomonth(@billing_date)
					end
                    else if (@billing_mode = 'BY DATE')
					begin
						if (day(@billing_date) < @date_for_billing)
						begin
							set @billing_date = eomonth(@billing_date)
						end
						else
                        begin
							set @billing_date = datefromparts(year(@billing_date), month(@billing_date), @date_for_billing);
                        end
					end
                    else if (@billing_mode = 'BEFORE DUE')
					begin
					    set @billing_date = dateadd(day, -1 * @date_for_billing, @due_date)
					end
					else if (@billing_mode = 'NORMAL')
                    begin
						if (day(@billing_date) < day(@new_billing_date))
						begin
							set @billing_date = eomonth(@billing_date)
						end
						else
                        begin
							set @billing_date = datefromparts(year(@billing_date), month(@billing_date), day(@new_billing_date));
                        end
                    end
                end
				
				if @at_installment_no = 1 and @no = @at_installment_no
				begin
				    select	@start_date = handover_bast_date
					from	dbo.agreement_asset
					where	asset_no			= @p_asset_no

					set @first_duedate = @start_date
				end
				else
                begin
                    select	@start_date			= due_date
					from	dbo.due_date_change_amortization_history
					where	due_date_change_code = @p_due_date_change_code
					and		asset_no			= @p_asset_no
					and		installment_no		= @no - 1
                end
				

				if (@billing_date > @maturity_date_asset) 
				begin
					set @billing_date = @maturity_date_asset
				end	
				

				if (@first_payment_type = 'ARR')
				begin
					set @end_date = @due_date
					set @description = 'Billing ke ' + cast(@no as nvarchar(15)) + ' dari Periode ' + convert(varchar(30), dateadd(day, 0,@start_date), 103) + ' Sampai dengan ' + convert(varchar(30), dateadd(day, -1,@end_date), 103)
				end
				else
                begin
					set @end_date = dateadd(day, -1, (dateadd(month, (@schedule_month), @due_date))) ;

					if (@end_date > @maturity_date_asset) 
					begin
						set @end_date = @maturity_date_asset
					end	

					set @description = 'Billing ke ' + cast(@no as nvarchar(15)) + ' dari Periode ' + convert(varchar(30), @due_date, 103) + ' Sampai dengan ' + convert(varchar(30), dateadd(day, -1,@end_date), 103)
                end
			
				if (isnull(@is_change_due_date,'0') = '1')
				begin
						if(@no = @at_installment_no)
						begin
							set @jarak_hari_duedate		=  datediff(day,@first_duedate,@due_date) 
							set @jarak_hari_billingmode =  datediff(day,@first_duedate,dateadd(month,@schedule_month,@first_duedate)) 
							set @billing_amount_prorate = ((@lease_rounded_amount * @schedule_month) / convert(decimal(18,2),@jarak_hari_billingmode)) * @jarak_hari_duedate
							set @billing_amount			= @billing_amount_prorate
						end	
						else if (@no = @loop)
						begin
							set @billing_amount = (@lease_rounded_amount * @schedule_month) - @billing_amount_prorate
							
							if (@billing_amount <= 0)
							begin
								set @billing_amount = (@lease_rounded_amount * @schedule_month) + @billing_amount
							end
						end
						else
						begin
							 set @billing_amount = (@lease_rounded_amount * @schedule_month)
						end
				end
				
				 insert into dbo.due_date_change_amortization_history
				 (
					 due_date_change_code,
					 installment_no,
					 asset_no,
					 due_date,
					 billing_date,
					 billing_amount,
					 description,
					 old_or_new,
					 cre_date,
					 cre_by,
					 cre_ip_address,
					 mod_date,
					 mod_by,
					 mod_ip_address
				 )
				 values
				 (  @p_due_date_change_code
					,@no
					,@p_asset_no
					,@due_date
					,@billing_date
					,@billing_amount
					,isnull(@description,'')
					,'NEW'
					--
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
				 ) ;

				set @due_date = dateadd(month, (@schedule_month), @due_date) ;
				set @billing_date = dateadd(month, (@schedule_month), @billing_date) ;

				set @no += 1 ;
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