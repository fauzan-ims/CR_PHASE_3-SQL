CREATE PROCEDURE [dbo].[xsp_application_amortization_recalculate_due_date]
(
	@p_asset_no		   nvarchar(50)
	,@p_due_date	   datetime
	-- 
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg				   nvarchar(max)
			,@no				   int
			,@tenor				   int
			,@schedule_month	   int
			,@first_duedate		   datetime
			,@billing_date		   datetime
			,@billing_mode		   nvarchar(10)
			,@billing_mode_date	   int
			,@description		   nvarchar(4000) 
			,@first_payment_type   nvarchar(3)
			,@start_periode		   datetime	 
			,@maturity_date_asset		datetime
            ,@prorate					nvarchar(10)
			,@billing_amount_prorate	decimal
            ,@jarak_hari_duedate		int
			,@jarak_hari_billingmode	int
            ,@billing_amount			decimal(18,2)
			,@end_date					datetime
            ,@start_date				datetime
            ,@due_date					datetime
			,@lease_rounded_amount		decimal(18, 2)

	begin try 
		-- mengambil multipier di master payment schedule
		select	@schedule_month			= mbt.multiplier
				,@tenor					= am.periode
				,@billing_mode			= aa.billing_mode
				,@billing_mode_date		= aa.billing_mode_date
				,@first_payment_type	= am.first_payment_type
				,@prorate				= isnull(aa.prorate,'no')
				,@lease_rounded_amount	= aa.monthly_rental_rounded_amount
		from	dbo.master_billing_type mbt
				inner join dbo.application_main am on (am.billing_type	 = mbt.code)
				inner join dbo.application_asset aa on (aa.application_no = am.application_no)
		where	aa.asset_no = @p_asset_no ;
		
		set @no = 1 ;
		set @first_duedate = @p_due_date ;
		set @due_date = @p_due_date
		
		set @maturity_date_asset = dateadd(month, @tenor, dateadd(day, -1, @due_date))
		
		-- @schedule_month ini adalah per berapa bulan schedule yg akan terbentuk (cth: per 1 bulan/ per 2 bulan).
		-- @tenor jumlah periode utang.
		if (@prorate = 'NO')
		begin
		    
			while (@no <= @tenor / @schedule_month)
			begin  
		
				if (@first_payment_type = 'ARR')
				begin
					set @description = 'Billing ke ' + cast(@no as nvarchar(15)) + ' dari Periode ' + convert(varchar(30), dateadd(day, 0, @due_date), 103) + ' Sampai dengan ' + convert(varchar(30), dateadd(month, (@schedule_month * @no), dateadd(day, -1, @first_duedate)), 103)
					set @due_date = dateadd(month, (@schedule_month * @no), dateadd(day,-1,@first_duedate))
					set @billing_date = @due_date
				end 
				else
				begin
					set @description = 'Billing ke ' + cast(@no as nvarchar(15)) + ' dari Periode ' + convert(varchar(30), @due_date, 103) + ' Sampai dengan ' + convert(varchar(30), dateadd(month, (@schedule_month * @no), dateadd(day, -1 ,@first_duedate)), 103)
					set @billing_date = dateadd(month, (@schedule_month * @no-1), dateadd(day,0,@first_duedate))
				end

				if (@billing_mode = 'BY DATE')
				begin
				 
					if (day(@due_date) < @billing_mode_date)
					begin 
						if (day(eomonth(@billing_date)) < @billing_mode_date)
						begin
							set @billing_date = datefromparts(year(@billing_date), month(@billing_date), day(eomonth(@billing_date)));
						end
						else
						begin
							set @billing_date = datefromparts(year(@billing_date), month(@billing_date), @billing_mode_date);
						end
					end
					else
					begin
						set @billing_date = datefromparts(year(@due_date), month(@due_date), @billing_mode_date); 
					end
                
					if (@no = @tenor / @schedule_month and @billing_date > @due_date)
					begin
					   set @billing_date = @due_date;
					end
                
					if (@no = 1 and @first_payment_type = 'ADV') and (@billing_date < @first_duedate)
					begin
						set @billing_date = @due_date;
					end
               
				end
				else if (@billing_mode = 'BEFORE DUE')
				begin
					set @billing_date = dateadd(day, @billing_mode_date * -1, @due_date) ;

					if (@no = 1 and @first_payment_type = 'ADV')
					begin
						set @billing_date = @due_date;
					end
            
				end
				else if (@billing_mode = 'END MONTH')
				begin
					set @billing_date = eomonth(@due_date)

					if @billing_date > @maturity_date_asset
					begin
						set @billing_date = @maturity_date_asset
					end
				end
				else
				begin
					set @billing_date = @due_date;
				end
				
				set @billing_amount = (@lease_rounded_amount * @schedule_month)

				update	dbo.application_amortization
				set		due_date		= @due_date
						,billing_date	= @billing_date
						,description	= @description
						,billing_amount = @billing_amount
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address = @p_mod_ip_address 
				where	installment_no  = @no
						and asset_no    = @p_asset_no ; 

				set @due_date = dateadd(month, (@schedule_month * @no), @first_duedate) ;
				set @no += 1 ;
			end ;
		end
		else
		begin
		    while (@no <= (@tenor / @schedule_month)+1)
			begin  

				if (@first_payment_type = 'ARR')
				begin
					
					set @due_date = dateadd(month, (@schedule_month * @no-1), dateadd(day,-1,@first_duedate))
				
					if (@due_date > @maturity_date_asset) or (@no = (@tenor / @schedule_month)+1)
					begin
					    set @due_date = @maturity_date_asset
					end	
					else
					begin
					    set @due_date = eomonth(@due_date)
					end	
						
					if @no = 1
					begin
						set @description = 'Billing ke ' + cast(@no as nvarchar(15)) + ' dari Periode ' + convert(varchar(30), dateadd(day, 0, @first_duedate), 103) + ' Sampai dengan ' + convert(varchar(30),@due_date, 103)
					end
                    else
                    begin
						if (@billing_mode in ('BEFORE DUE','BY DATE'))
						begin
							set @description = 'Billing ke ' + cast(@no as nvarchar(15)) + ' dari Periode ' + convert(varchar(30), dateadd(day, 1, @start_date), 103) + ' Sampai dengan ' + convert(varchar(30), @due_date, 103)
						end
						else
						begin
							set @description = 'Billing ke ' + cast(@no as nvarchar(15)) + ' dari Periode ' + convert(varchar(30), dateadd(day, 1, @billing_date), 103) + ' Sampai dengan ' + convert(varchar(30), @due_date, 103)
						end
                    end
				
					set @billing_date = @due_date
			
				end 
				else
				begin
				
					if @due_date > @maturity_date_asset
					begin
					    set @end_date = @maturity_date_asset
					end	
					else
                    begin
                        set @end_date = eomonth(dateadd(month, (@schedule_month * @no-1), dateadd(day,-1,@first_duedate)))
                    end

					if @no = 1
					begin
						set @due_date = @first_duedate
					end
                    else 
                    begin
						set @due_date = datefromparts(year(@due_date), month(@due_date), 1)
                    end
					
					set @description = 'Billing ke ' + cast(@no as nvarchar(15)) + ' dari Periode ' + convert(varchar(30), @due_date, 103) + ' Sampai dengan ' + convert(varchar(30),@end_date, 103)
					set @billing_date = dateadd(month, (@schedule_month), dateadd(day,0,@billing_date))
				end
				
				--cari billing prorate
				if (@first_payment_type = 'ARR')
				begin
					if(@no = 1)
					begin
					    set @jarak_hari_duedate		=  datediff(day,@first_duedate,@due_date) 
					    set @jarak_hari_billingmode =  datediff(day,@first_duedate,dateadd(month,@schedule_month,@first_duedate)) 
						set @billing_amount_prorate = ((@lease_rounded_amount * @schedule_month) / convert(decimal(18,2),@jarak_hari_billingmode)) * @jarak_hari_duedate
						set @billing_amount			= @billing_amount_prorate

					end	
					else if (@no = (@tenor / @schedule_month)+1)
					begin
					    set @billing_amount = (@lease_rounded_amount * @schedule_month) - @billing_amount_prorate
					end
                    else
                    begin
                         set @billing_amount = (@lease_rounded_amount * @schedule_month)
                    end
				end
                else
                begin
                    if(@no = 1)
					begin
					    set @jarak_hari_duedate		=  datediff(day,@first_duedate,eomonth(@end_date)) 
					    set @jarak_hari_billingmode =  datediff(day,@first_duedate,dateadd(month,@schedule_month,@first_duedate)) 
						set @billing_amount_prorate = ((@lease_rounded_amount * @schedule_month) / convert(decimal(18,2),@jarak_hari_billingmode)) * @jarak_hari_duedate
						set @billing_amount			= @billing_amount_prorate
					end	
					else if (@no = (@tenor / @schedule_month)+1)
					begin
					    set @billing_amount = (@lease_rounded_amount * @schedule_month) - @billing_amount_prorate
					end
                    else
                    begin
                         set @billing_amount = (@lease_rounded_amount * @schedule_month)
                    end
                end

				if (@billing_mode = 'BY DATE')
				begin
					if (day(@due_date) < @billing_mode_date)
					begin 
						if (day(eomonth(@billing_date)) < @billing_mode_date)
						begin
							set @billing_date = datefromparts(year(@billing_date), month(@billing_date), day(eomonth(@billing_date)));
						end
						else
						begin
							set @billing_date = datefromparts(year(@billing_date), month(@billing_date), @billing_mode_date);
						end
					end
					else
					begin
						set @billing_date = datefromparts(year(@due_date), month(@due_date), @billing_mode_date); 
					end
        
					if ((@no =  (@tenor / @schedule_month)+1) and @billing_date > @maturity_date_asset)
					begin
					   set @billing_date = @due_date;
					end
                
					if (@no = 1 and @first_payment_type = 'ADV') or (@billing_date < @first_duedate)
					begin
						set @billing_date = @due_date;
					end
				
					set @start_date = @due_date
					
				end
				else if (@billing_mode = 'BEFORE DUE')
				begin

					if (@no = 1 and @first_payment_type = 'ADV' and cast(@due_date as date) < cast(@first_duedate as date))
					begin
						set @billing_date = @due_date;
					end
                    else
					begin
						set @billing_date = dateadd(day, @billing_mode_date * -1, @due_date) ;
					end

					set @start_date = @due_date

				end
				else if (@billing_mode = 'END MONTH')
				begin
					set @billing_date = eomonth(@due_date)

					if @billing_date > @maturity_date_asset
					begin
						set @billing_date = @maturity_date_asset
					end
				end
				else
				begin
					set @billing_date = @due_date;
				end
				 
			
				update	dbo.application_amortization
				set		due_date		= @due_date
						,billing_date	= @billing_date
						,description	= @description
						,billing_amount = @billing_amount
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address = @p_mod_ip_address 
				where	installment_no  = @no
						and asset_no    = @p_asset_no ; 

				set @due_date = dateadd(month, (@schedule_month * @no), @first_duedate) ;
				set @no += 1 ;
			end ;
		end
	
		--while (@no <= @tenor / @schedule_month)
		--begin  
		--	set @start_periode = dateadd(day,1,@p_due_date)

		--	set @description = 'Billing ke ' + cast(@no as nvarchar(15)) + ' dari Periode ' + convert(varchar(30), @start_periode, 103) + ' Sampai dengan ' + convert(varchar(30), dateadd(month, (@schedule_month * @no), @first_duedate), 103)
			
		--	if (@first_payment_type = 'ARR')
		--	begin
		--		set @p_due_date = dateadd(month, (@schedule_month * @no), @first_duedate)
		--	end 
		--	if (@billing_mode = 'BY DATE')
		--	begin
		--		if (day(@p_due_date) < @billing_mode_date)
		--		begin 
		--			set @billing_date = dateadd(month, -1, @p_due_date); 

		--			if (day(eomonth(@billing_date)) < @billing_mode_date)
		--			begin
		--				set @billing_date = datefromparts(year(@billing_date), month(@billing_date), day(eomonth(@billing_date)));
		--			end
		--			else
		--			begin
		--				set @billing_date = datefromparts(year(@billing_date), month(@billing_date), @billing_mode_date);
		--			end
		--		end
		--		else
		--		begin
		--			set @billing_date = datefromparts(year(@p_due_date), month(@p_due_date), @billing_mode_date); 
		--		end
		--	end
		--	else if (@billing_mode = 'BEFORE DUE')
		--	begin
		--		set @billing_date = dateadd(day, @billing_mode_date * -1, @p_due_date) ;
		--	end
		--	else
		--	begin
		--		set @billing_date = @p_due_date;
		--	end
			
		--	update	dbo.application_amortization
		--	set		due_date		= @p_due_date
		--			,billing_date	= @billing_date
		--			,description	= @description
		--			--
		--			,mod_date		= @p_mod_date
		--			,mod_by			= @p_mod_by
		--			,mod_ip_address = @p_mod_ip_address 
		--	where	installment_no  = @no
		--			and asset_no    = @p_asset_no ; 

		--	set @p_due_date = dateadd(month, (@schedule_month * @no), @first_duedate) ;

		--	set @no += 1 ;
		--end ;
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


