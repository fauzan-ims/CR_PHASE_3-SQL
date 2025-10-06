CREATE PROCEDURE [dbo].[xsp_asset_gps_schedule_insert]
(
	@p_id							bigint	= 0 output
	,@p_installment_no				nvarchar(50)
	,@p_periode						nvarchar(250)
	,@p_fa_code						NVARCHAR(50)
	,@p_due_date					DATETIME
	,@p_vendor_code					nvarchar(50)
	,@p_vendor_name					nvarchar(250)
	,@p_subcribe_amount_month		DECIMAL(18,2)
	,@p_next_billing_date			DATETIME
	,@p_status						NVARCHAR(25)
	,@p_vendor_npwp					NVARCHAR(50)
	,@p_vendor_nitku				NVARCHAR(50)
	,@p_vendor_npwp_pusat			NVARCHAR(50)
	--
	,@p_cre_date					datetime
	,@p_cre_by						nvarchar(15)
	,@p_cre_ip_address				nvarchar(15)
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin TRY
    
		INSERT INTO dbo.ASSET_GPS_SCHEDULE
		(
		    INSTALLMENT_NO
		    ,PERIODE
		    ,FA_CODE
		    ,DUE_DATE
		    ,VENDOR_CODE
		    ,VENDOR_NAME
		    ,SUBCRIBE_AMOUNT_MONTH
		    ,NEXT_BILLING_DATE
		    ,STATUS
		    ,VENDOR_NPWP
		    ,VENDOR_NITKU
		    ,VENDOR_NPWP_PUSAT
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		VALUES
		(   
			@p_installment_no				
			,@p_periode						
			,@p_fa_code						
			,@p_due_date					
			,@p_vendor_code					
			,@p_vendor_name					
			,@p_subcribe_amount_month		
			,@p_next_billing_date			
			,@p_status						
			,@p_vendor_npwp					
			,@p_vendor_nitku				
			,@p_vendor_npwp_pusat			
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		)
		
		set @p_id = @@IDENTITY

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
end
