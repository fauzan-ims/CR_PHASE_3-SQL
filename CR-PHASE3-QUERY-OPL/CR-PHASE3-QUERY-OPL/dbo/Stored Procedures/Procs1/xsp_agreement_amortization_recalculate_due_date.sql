CREATE PROCEDURE dbo.xsp_agreement_amortization_recalculate_due_date
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

	begin try 
		update	dbo.application_asset
		set		bast_date				= @p_due_date
				,handover_bast_date		= @p_due_date 
				--
				,mod_date				= @p_mod_date	  
				,mod_by					= @p_mod_by		  
				,mod_ip_address			= @p_mod_ip_address
		where	asset_no				= @p_asset_no ; 

		update	dbo.agreement_asset
		set		handover_bast_date	= @p_due_date
		where	asset_no			= @p_asset_no ;

		-- mengambil multipier di master payment schedule
		select	@schedule_month			= mbt.multiplier
				,@tenor					= am.periode
				,@billing_mode			= aa.billing_mode
				,@billing_mode_date		= aa.billing_mode_date
				,@first_payment_type	= am.first_payment_type
		from	dbo.master_billing_type mbt
				inner join dbo.agreement_main am on (am.billing_type	 = mbt.code)
				inner join dbo.agreement_asset aa on (aa.agreement_no = am.agreement_no)
		where	aa.asset_no = @p_asset_no ;
		
		set @no = 1 ;
		set @first_duedate = @p_due_date ;
		
		-- @schedule_month ini adalah per berapa bulan schedule yg akan terbentuk (cth: per 1 bulan/ per 2 bulan).
		-- @tenor jumlah periode utang.

		while (@no <= @tenor / @schedule_month)
		begin  
			set @start_periode = dateadd(day,1,@p_due_date)
			set @description = 'Billing ke ' + cast(@no as nvarchar(15)) + ' dari Periode ' + convert(varchar(30), @start_periode, 103) + ' Sampai dengan ' + convert(varchar(30), dateadd(month, (@schedule_month * @no), @first_duedate), 103)
			
			if (@first_payment_type = 'ARR')
			begin
				set @p_due_date = dateadd(month, (@schedule_month * @no), @first_duedate)
			end  

			if (@billing_mode = 'BY DATE')
			begin
				if (day(@p_due_date) < @billing_mode_date)
				begin 
					set @billing_date = dateadd(month, -1, @p_due_date); 

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
					set @billing_date = datefromparts(year(@p_due_date), month(@p_due_date), @billing_mode_date); 
				end
			end
			else if (@billing_mode = 'BEFORE DUE')
			begin
				set @billing_date = dateadd(day, @billing_mode_date * -1, @p_due_date) ;
			end
			else
			begin
				set @billing_date = @p_due_date;
			end
			
			update	dbo.agreement_asset_amortization
			set		due_date		= @p_due_date
					,billing_date	= @billing_date
					,description	= @description
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address 
			where	billing_no	    = @no
					and asset_no    = @p_asset_no ; 

			set @p_due_date = dateadd(month, (@schedule_month * @no), @first_duedate) ;

			set @no += 1 ;
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


