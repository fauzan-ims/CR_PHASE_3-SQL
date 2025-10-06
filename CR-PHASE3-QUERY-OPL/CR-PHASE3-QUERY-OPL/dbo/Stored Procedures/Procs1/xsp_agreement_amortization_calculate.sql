CREATE PROCEDURE [dbo].[xsp_agreement_amortization_calculate]
(
   @p_asset_no        nvarchar(50)
   --
   ,@p_cre_date       datetime
   ,@p_cre_by         nvarchar(15)
   ,@p_cre_ip_address nvarchar(15)
   ,@p_mod_date       datetime
   ,@p_mod_by         nvarchar(15)
   ,@p_mod_ip_address nvarchar(15)
)
as
begin
   declare
      @msg                   nvarchar(max)
      ,@due_date             datetime
      ,@agreement_no         nvarchar(50)
      ,@no                   int
      ,@tenor                int
      ,@schedule_month       int
      ,@first_duedate        datetime
      ,@billing_date         datetime
      ,@billing_mode         nvarchar(10)
      ,@billing_mode_date    int
      ,@lease_rounded_amount decimal(18, 2)
      ,@description          nvarchar(4000) 
	  ,@first_payment_type	 nvarchar(3)
	  ,@start_periode		 datetime	 
	  ,@invoice_no		     nvarchar(50) -- (+) Ari 2023-11-27 ket : add invoice_no
	  --
	  ,@maturity_date_asset		datetime
	  ,@prorate					nvarchar(10)
	  ,@billing_amount_prorate	decimal
      ,@jarak_hari_duedate		int
	  ,@jarak_hari_billingmode	int
      ,@billing_amount			decimal(18,2)
	  ,@end_date				datetime
      ,@start_date				datetime
	  
   begin try
      delete dbo.agreement_asset_amortization
      where  asset_no = @p_asset_no ;

      -- mengambil multipier di master payment schedule
      select
            @schedule_month        = multiplier
            ,@agreement_no         = aa.agreement_no
            ,@due_date             = aa.handover_bast_date
            ,@lease_rounded_amount = aa.monthly_rental_rounded_amount--aa.lease_rounded_amount
            ,@tenor                = aa.periode
            ,@billing_mode         = aa.billing_mode
            ,@billing_mode_date    = aa.billing_mode_date
			,@first_payment_type   = aa.first_payment_type
			,@prorate				= isnull(aa.prorate,'no')
      FROM  dbo.master_billing_type        mbt
            INNER JOIN dbo.agreement_asset aa ON (aa.billing_type = mbt.code)
            INNER JOIN dbo.agreement_main  am ON (am.agreement_no = aa.agreement_no)
      WHERE aa.asset_no = @p_asset_no ;
	
      set @no = 1 ;
      set @first_duedate = @due_date ;
	  set @maturity_date_asset = dateadd(month, @tenor, dateadd(day, -1, @due_date))

	  update	dbo.agreement_asset
	  set		maturity_date	= @maturity_date_asset
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address	= @p_mod_ip_address	
	  where		asset_no = @p_asset_no

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

			 insert into dbo.agreement_asset_amortization
			 (
				agreement_no
				,billing_no
				,asset_no
				,due_date
				,billing_date
				,billing_amount
				,description -- (+) ari 2023-11-27 ket : add description
				,invoice_no
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			 )
			 values
			 (
				@agreement_no
				,@no
				,@p_asset_no
				,@due_date
				,@billing_date
				,@billing_amount
				,@description
				,@invoice_no  -- (+) ari 2023-11-27 ket : add invoice_no
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
			 ) ;

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
				
				insert into dbo.agreement_asset_amortization
				 (
					agreement_no
					,billing_no
					,asset_no
					,due_date
					,billing_date
					,billing_amount
					,description -- (+) ari 2023-11-27 ket : add description
					,invoice_no
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				 )
				 values
				 (
					@agreement_no
					,@no
					,@p_asset_no
					,@due_date
					,@billing_date
					,@billing_amount
					,@description
					,@invoice_no  -- (+) ari 2023-11-27 ket : add invoice_no
					--
					,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
				 ) ;

				set @due_date = dateadd(month, (@schedule_month * @no), @first_duedate) ;
				set @no += 1 ;
			end ;
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
