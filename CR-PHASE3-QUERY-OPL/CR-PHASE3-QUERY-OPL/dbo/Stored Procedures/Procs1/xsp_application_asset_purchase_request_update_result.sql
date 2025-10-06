--SET QUOTED_IDENTIFIER ON|OFF
--SET ANSI_NULLS ON|OFF
--GO
CREATE PROCEDURE dbo.xsp_application_asset_purchase_request_update_result
   @p_code as         nvarchar(50)
   ,@p_application_no nvarchar(50)
   --
   ,@p_mod_date       datetime
   ,@p_mod_by         nvarchar(15)
   ,@p_mod_ip_address nvarchar(15)
-- WITH ENCRYPTION, RECOMPILE, EXECUTE AS CALLER|SELF|OWNER| 'user_name'
as
begin
   /*
	SAAT ASSET SUDAH DI LAKUKAN PEMBELIAN OLEH MODULE PROCRUMENT
	MAKA NOMOR ASSET NYA AKAN DI INFORMASIKAN KEMBALI KE MODULE OPL
	NOMOR INI AKAN DI UPDATE KE PURCHASE REQUEST DAN APPLICATION ASSET YANG ADA DI OPL
   */
   declare
      @result_fa_code  nvarchar(50)
      ,@result_fa_name nvarchar(250)
      ,@result_date    datetime
      ,@msg            nvarchar(max)
      ,@asset_desc     nvarchar(4000) ;

   --hanya boleh di post jika [REQUEST_STATUS] nya HOLD
   if not exists (
                    select
                          1
                    from  dbo.PURCHASE_REQUEST
                    where CODE               = @p_code
                          and REQUEST_STATUS = 'HOLD'
                 )
   begin
      set @msg = N'Status Request harus HOLD! Transaksi tidak dapat dipost!' ;

      raiserror(@msg, 16, -1) ;
   end ;

   -- ambil informasi
   select
         @result_fa_code  = RESULT_FA_CODE
         ,@result_fa_name = RESULT_FA_NAME
         ,@result_date    = RESULT_DATE
   from  dbo.OPL_INTERFACE_PURCHASE_REQUEST
   where CODE = @p_code ;

   begin try

      --update status PR
      update
            dbo.PURCHASE_REQUEST
      set
            REQUEST_STATUS = 'POST'
            ,RESULT_FA_CODE = @result_fa_code
            ,RESULT_FA_NAME = @result_fa_name
            ,REQUEST_DATE = @result_date
            ,MOD_DATE = @p_mod_date
            ,MOD_BY = @p_mod_by
            ,MOD_IP_ADDRESS = @p_mod_ip_address
      where CODE = @p_code ;

      --update application asset
      update
            dbo.APPLICATION_ASSET
      set
            PURCHASE_STATUS = 'POST'
            ,FA_CODE = @result_fa_code
            ,FA_NAME = @result_fa_name
            ,MOD_DATE = @p_mod_date
            ,MOD_BY = @p_mod_by
            ,MOD_IP_ADDRESS = @p_mod_ip_address
      where PURCHASE_CODE = @p_code ;

      -- ambil informasi
      select
            @asset_desc = DESCRIPTION
      from  dbo.PURCHASE_REQUEST
      where CODE               = @p_code
            and REQUEST_STATUS = 'HOLD' ;

      set @msg = N'Purchase request for' + @p_code + N' - ' + @asset_desc ;

      -- insert to log application
      insert into dbo.APPLICATION_LOG
      (
         APPLICATION_NO
         ,LOG_DATE
         ,LOG_DESCRIPTION
         ,LOG_CYCLE
         ,CRE_DATE
         ,CRE_BY
         ,CRE_IP_ADDRESS
         ,MOD_DATE
         ,MOD_BY
         ,MOD_IP_ADDRESS
      )
      values
      (
         @p_application_no  -- APPLICATION_NO - nvarchar(50)
         ,@p_mod_date       -- LOG_DATE - datetime
         ,@msg              -- LOG_DESCRIPTION - nvarchar(4000)
         ,0                 -- LOG_CYCLE - int
         ,@p_mod_date       -- CRE_DATE - datetime
         ,@p_mod_by         -- CRE_BY - nvarchar(15)
         ,@p_mod_ip_address -- CRE_IP_ADDRESS - nvarchar(15)
         ,@p_mod_date       -- MOD_DATE - datetime
         ,@p_mod_by         -- MOD_BY - nvarchar(15)
         ,@p_mod_ip_address -- MOD_IP_ADDRESS - nvarchar(15)
      ) ;
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
