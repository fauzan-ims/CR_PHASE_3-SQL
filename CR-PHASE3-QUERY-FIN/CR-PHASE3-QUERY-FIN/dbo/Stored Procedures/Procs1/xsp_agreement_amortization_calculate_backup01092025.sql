CREATE PROCEDURE [dbo].[xsp_agreement_amortization_calculate_backup01092025]
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

   begin try
      delete dbo.agreement_asset_amortization
      where  asset_no = @p_asset_no ;

      -- mengambil multipier di master payment schedule
      select
            @schedule_month        = multiplier
            ,@agreement_no         = aa.agreement_no
            ,@due_date             = aa.handover_bast_date
            ,@lease_rounded_amount = aa.lease_rounded_amount
            ,@tenor                = aa.periode
            ,@billing_mode         = aa.billing_mode
            ,@billing_mode_date    = aa.billing_mode_date
			,@first_payment_type   = aa.first_payment_type
      from  dbo.master_billing_type        mbt
            inner join dbo.agreement_asset aa on (aa.billing_type = mbt.code)
            inner join dbo.agreement_main  am on (am.agreement_no = aa.agreement_no)
      where aa.asset_no = @p_asset_no ;
	  
      set @no = 1 ;
      set @first_duedate = @due_date ;

      while (@no <= @tenor / @schedule_month)
      begin
		set @start_periode = dateadd(day,1,@due_date)

		set @description = 'Billing ke ' + cast(@no as nvarchar(15)) + ' dari Periode ' + convert(varchar(30), @start_periode, 103) + ' Sampai dengan ' + convert(varchar(30), dateadd(month, (@schedule_month * @no), @first_duedate), 103)
			 
		if (@first_payment_type = 'ARR')
		begin
			set @due_date = dateadd(month, (@schedule_month * @no), @first_duedate)
		end 

		if (@billing_mode = 'BY DATE')
		begin
			if (day(@due_date) < @billing_mode_date)
			begin 
				set @billing_date = dateadd(month, -1, @due_date); 

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
		end
		else if (@billing_mode = 'BEFORE DUE')
		begin
			set @billing_date = dateadd(day, @billing_mode_date * -1, @due_date) ;
		end
		else
		begin
			set @billing_date = @due_date;
		end

         insert into dbo.AGREEMENT_ASSET_AMORTIZATION
         (
            AGREEMENT_NO
            ,BILLING_NO
            ,ASSET_NO
            ,DUE_DATE
            ,BILLING_DATE
            ,BILLING_AMOUNT
			,DESCRIPTION -- (+) Ari 2023-11-27 ket : add description
            ,INVOICE_NO
            ,CRE_DATE
            ,CRE_BY
            ,CRE_IP_ADDRESS
            ,MOD_DATE
            ,MOD_BY
            ,MOD_IP_ADDRESS
         )
         values
         (
            @agreement_no
            ,@no
            ,@p_asset_no
            ,@due_date
            ,@billing_date
            ,@lease_rounded_amount
            ,@description
			,@invoice_no  -- (+) Ari 2023-11-27 ket : add invoice_no
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
