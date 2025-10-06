--set quoted_identifier on|off
--set ansi_nulls on|off
--go
CREATE PROCEDURE dbo.xsp_application_asset_purchase_request_post
   @p_code as         nvarchar(50)
   ,@p_application_no nvarchar(50)
   --
   ,@p_mod_date       datetime
   ,@p_mod_by         nvarchar(15)
   ,@p_mod_ip_address nvarchar(15)
-- with encryption, recompile, execute as caller|self|owner| 'user_name'
as
begin
   /*
		saat pemilihan asset, ada 2 option
		jika unit nya ada : bisa melakukan pemilihan asset langsung
		jika unit tidak ada : melakukan proses ini, permintaan purchase. data permintaan ini akan di lanjutkan di process purchase
	*/
   declare
      @msg         nvarchar(max)
      ,@asset_desc nvarchar(max) ;

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

   begin try
      insert into dbo.OPL_INTERFACE_PURCHASE_REQUEST
      (
         CODE
         ,BRANCH_CODE
         ,BRANCH_NAME
         ,REQUEST_DATE
         ,REQUEST_STATUS
         ,DESCRIPTION
         ,FA_CATEGORY_CODE
         ,FA_CATEGORY_NAME
         ,FA_MERK_CODE
         ,FA_MERK_NAME
         ,FA_MODEL_CODE
         ,FA_MODEL_NAME
         ,FA_TYPE_CODE
         ,FA_TYPE_NAME
         ,RESULT_FA_CODE
         ,RESULT_FA_NAME
         ,RESULT_DATE 
         ,CRE_DATE
         ,CRE_BY
         ,CRE_IP_ADDRESS
         ,MOD_DATE
         ,MOD_BY
         ,MOD_IP_ADDRESS
      )
                  select
                        CODE
                        ,BRANCH_CODE
                        ,BRANCH_NAME
                        ,REQUEST_DATE
                        ,REQUEST_STATUS
                        ,DESCRIPTION
                        ,FA_CATEGORY_CODE
                        ,FA_CATEGORY_NAME
                        ,FA_MERK_CODE
                        ,FA_MERK_NAME
                        ,FA_MODEL_CODE
                        ,FA_MODEL_NAME
                        ,FA_TYPE_CODE
                        ,FA_TYPE_NAME
                        ,RESULT_FA_CODE
                        ,RESULT_FA_NAME
                        ,RESULT_DATE
                        ,@p_mod_date
                        ,@p_mod_by
                        ,@p_mod_ip_address
                        ,@p_mod_date
                        ,@p_mod_by
                        ,@p_mod_ip_address
                  from  dbo.PURCHASE_REQUEST
                  where CODE               = @p_code
                        and REQUEST_STATUS = 'HOLD' ;

      select
            @asset_desc = DESCRIPTION
      from  dbo.PURCHASE_REQUEST
      where CODE               = @p_code
            and REQUEST_STATUS = 'HOLD' ;

      set @msg = N'Purchase request for' + @p_code + N' - ' + @asset_desc + N' proceed' ;

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

      --update status PR
      update
            dbo.PURCHASE_REQUEST
      set
            REQUEST_STATUS = 'ONPROCESS'
            ,MOD_DATE = @p_mod_date
            ,MOD_BY = @p_mod_by
            ,MOD_IP_ADDRESS = @p_mod_ip_address
      where CODE = @p_code ;
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
