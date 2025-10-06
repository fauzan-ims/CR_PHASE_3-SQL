--SET QUOTED_IDENTIFIER ON|OFF
--SET ANSI_NULLS ON|OFF
--GO
CREATE PROCEDURE dbo.xsp_agreement_asset_return_post
   @p_asset_no        nvarchar(50)
   ,@p_return_remark  nvarchar(max) -- ini gk disimpan di table manapun?
                                    --
   ,@p_mod_date       datetime
   ,@p_mod_by         nvarchar(15)
   ,@p_mod_ip_address nvarchar(15)
-- WITH ENCRYPTION, RECOMPILE, EXECUTE AS CALLER|SELF|OWNER| 'user_name'
as
begin
   /*
	untuk mengupdate saat asset yang di sewa sudah selesai dan dikembalikan ke multifinance
	proses ini untuk memposting saat asset tersebut sudah dikembalikan
   */
   declare
      @msg          nvarchar(max)
      ,@agreementno nvarchar(50) ;

   --hanya boleh di post jika [asset status] nya RENTED
   if not exists (
                    select
                          1
                    from  dbo.AGREEMENT_ASSET
                    where ASSET_NO         = @p_asset_no
                          and ASSET_STATUS = 'RENTED'
                 )
   begin
      set @msg = N'Status Asset harus RENTED! Transaksi tidak dapat diproses lebih lanjut!' ;

      raiserror(@msg, 16, -1) ;
   end ;

   begin try
      -- update related asset, menjadi returned/dikembalikan/unused
      update
            dbo.AGREEMENT_ASSET
      set
            ASSET_STATUS = 'RETURNED'
            ,RETURN_DATE = @p_mod_date
            ,MOD_DATE = @p_mod_date
            ,MOD_BY = @p_mod_by
            ,MOD_IP_ADDRESS = @p_mod_ip_address
      where ASSET_NO = @p_asset_no ;

      select
            @agreementno = AGREEMENT_NO
      from  dbo.AGREEMENT_ASSET
      where ASSET_NO = @p_asset_no ;

      -- IF ALL ASSET STATUS = RETURNED, MAKA UPDATE AGREEMENT STATUS = FINISH
      if not exists (
                       select
                             1
                       from  dbo.AGREEMENT_ASSET
                       where AGREEMENT_NO = @agreementno
                             and ASSET_STATUS in
                                 (
                                    'RESERVED', 'RENTED', 'SWITCHING'
                                 )
                    )
      begin
         update
               dbo.AGREEMENT_MAIN
         set
               AGREEMENT_STATUS = 'FINISH'
               ,AGREEMENT_SUB_STATUS = ''
               ,MOD_DATE = @p_mod_date
               ,MOD_BY = @p_mod_by
               ,MOD_IP_ADDRESS = @p_mod_ip_address
         where AGREEMENT_NO = @agreementno ;
      end ;

      set @msg = N'BAST for return asset ' + @p_asset_no + N', ' + @p_return_remark ;

      -- entry ke log
      insert into dbo.AGREEMENT_LOG
      (
         AGREEMENT_NO
         ,LOG_SOURCE_NO
         ,LOG_DATE
         ,LOG_REMARKS
         ,CRE_DATE
         ,CRE_BY
         ,CRE_IP_ADDRESS
         ,MOD_DATE
         ,MOD_BY
         ,MOD_IP_ADDRESS
      )
      values
      (
         @agreementno       -- AGREEMENT_NO - nvarchar(50)
         ,N''               -- LOG_SOURCE_NO - nvarchar(50)
         ,@p_mod_date       -- LOG_DATE - datetime
         ,@msg              -- LOG_REMARKS - nvarchar(4000)
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
