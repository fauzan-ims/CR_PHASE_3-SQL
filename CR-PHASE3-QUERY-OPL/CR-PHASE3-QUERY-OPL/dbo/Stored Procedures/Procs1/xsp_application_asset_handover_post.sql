--SET QUOTED_IDENTIFIER ON|OFF
--SET ANSI_NULLS ON|OFF
--GO
CREATE procedure dbo.xsp_application_asset_handover_post
   @p_asset_no        nvarchar(50)
   --
   ,@p_mod_date       datetime
   ,@p_mod_by         nvarchar(15)
   ,@p_mod_ip_address nvarchar(15)
-- WITH ENCRYPTION, RECOMPILE, EXECUTE AS CALLER|SELF|OWNER| 'user_name'
as
begin
   /*
	UNTUK MEMPOSTING BAHWA ASSET YANG DI OPERATING LEASE KAN SUDAH DITERIMA OLEH CLIENT
	*/
   declare
      @msg              nvarchar(max)
      ,@agreementno     nvarchar(50)
      ,@handover_remark nvarchar(max) ;

   --hanya boleh di post jika HANDOVER STATUS nya HOLD
   --hanya boleh di post jika ASSET STATUS nya RESERVED
   if not exists (
                    select
                          1
                    from  dbo.AGREEMENT_ASSET
                    where ASSET_NO            = @p_asset_no
                          and ASSET_STATUS    = 'RESERVED'
                          and HANDOVER_STATUS = 'HOLD'
                 )
   begin
      set @msg = N'Status Asset harus RESERVED dan Handover status harus HOLD! Transaksi tidak dapat diproses lebih lanjut!' ;

      raiserror(@msg, 16, -1) ;
   end ;

   --HANDOVER_BAST_DATE tidak boleh null
   if exists (
                select
                      1
                from  dbo.AGREEMENT_ASSET
                where ASSET_NO = @p_asset_no
                      and HANDOVER_BAST_DATE is null
             )
   begin
      set @msg = N'Harap diisi informasi Handover BAST Date!' ;

      raiserror(@msg, 16, -1) ;
   end ;

   -- ambil informasi
   select
         @agreementno      = AGREEMENT_NO
         ,@handover_remark = HANDOVER_REMARK
   from  dbo.AGREEMENT_ASSET
   where ASSET_NO = @p_asset_no ;

   begin try

      -- update status agreement asset
      update
            dbo.AGREEMENT_ASSET
      set
            HANDOVER_STATUS = 'POST'
            ,ASSET_STATUS = 'RENTED'
            ,MOD_DATE = @p_mod_date
            ,MOD_BY = @p_mod_by
            ,MOD_IP_ADDRESS = @p_mod_ip_address
      where AGREEMENT_NO = @p_asset_no ;

      -- recalculate application amortization
      exec dbo.xsp_agreement_amortization_calculate
         @p_asset_no = @p_asset_no                -- nvarchar(50)
         ,@p_cre_date = @p_mod_date               -- datetime
         ,@p_cre_by = @p_mod_by                   -- nvarchar(15)
         ,@p_cre_ip_address = @p_mod_ip_address   -- nvarchar(15)
         ,@p_mod_date = @p_mod_date               -- datetime
         ,@p_mod_by = @p_mod_by                   -- nvarchar(15)
         ,@p_mod_ip_address = @p_mod_ip_address ; -- nvarchar(15)

      set @msg = N'BAST for asset ' + @p_asset_no + N', ' + @handover_remark ;

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
