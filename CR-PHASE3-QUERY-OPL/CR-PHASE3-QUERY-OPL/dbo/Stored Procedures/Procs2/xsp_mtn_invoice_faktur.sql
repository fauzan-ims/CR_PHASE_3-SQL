CREATE PROCEDURE dbo.xsp_mtn_invoice_faktur
(
   @p_invoice_no	 nvarchar(50) --= replace('00560/INV/2015/11/2023', '/', '.') -- NEW NO INVOICE
   ,@p_old_faktur_no nvarchar(50)  --= NO FAKTUR YANG LAMA
   ,@p_new_faktur_no nvarchar(50)  --= NO FAKTUR YANG BARU
   --				 
   ,@p_mtn_remark	 nvarchar(4000)
   ,@p_mtn_cre_by	 nvarchar(250)
)
as
begin
	declare @msg		 nvarchar(max)
			,@invoice_no nvarchar(50) = replace(@p_invoice_no, '/', '.') ;

	BEGIN TRANSACTION 
	begin try 
		--validasi
		begin
			if (isnull(@p_mtn_remark, '') = '')
			begin
				set @msg = 'Harap diisi MTN Remark';
				raiserror(@msg, 16, 1) ;
				return
			end

			if (isnull(@p_mtn_cre_by, '') = '')
			begin
				set @msg = 'Harap diisi MTN Cre By';
				raiserror(@msg, 16, 1) ;
				return
			end

			if exists
			(
				select	1
				from	dbo.invoice
				where	invoice_no		   = @invoice_no
						and invoice_status <> 'NEW'
			)
			begin
				set @msg = 'Invoice already Process';
				raiserror(@msg, 16, 1) ;
				return
			end ;
			 
			if exists
			(
				select	1
				from	dbo.invoice
				where	faktur_no		   = @p_old_faktur_no
						and invoice_status <> 'CANCEL'
			)
			begin
				set @msg = 'Invoice With Faktur No : ' + @p_old_faktur_no + ' cannot Process because Invoice Status Not Cancel YET';
				raiserror(@msg, 16, 1) ;
				return
			end ;
		end ;
		
		SELECT 'BEFORE',FAKTUR_NO,* FROM dbo.INVOICE where FAKTUR_NO =  @p_old_faktur_no
		SELECT 'BEFORE',FAKTUR_NO,* FROM dbo.faktur_allocation_detail where FAKTUR_NO =  @p_old_faktur_no
		SELECT 'BEFORE',FAKTUR_NO,* FROM dbo.FAKTUR_MAIN where FAKTUR_NO =  substring(@p_old_faktur_no, 5, 18) ;

		--update invoice faktur no
		begin
			update	dbo.invoice
			set		faktur_no		= ''
					,mod_date		= getdate()
					,mod_by			= N'MTN_DATA'
					,mod_ip_address = N'MTN_DATA'
			where	faktur_no		= @p_old_faktur_no ;

			update	dbo.invoice
			set		faktur_no		= @p_new_faktur_no
					,mod_date		= getdate()
					,mod_by			= N'MTN_DATA'
					,mod_ip_address = N'MTN_DATA'
			where	invoice_no		= @invoice_no;
		end ;

		--update faktur main with new invoice no
		begin
			update	dbo.faktur_main
			set		invoice_no		= @invoice_no
					,mod_date		= getdate()
					,mod_by			= N'MTN_DATA'
					,mod_ip_address = N'MTN_DATA'
			where	faktur_no		= substring(@p_old_faktur_no, 5, 18) ;

			update	dbo.faktur_allocation_detail
			set		invoice_no		= @invoice_no
					,mod_date		= getdate()
					,mod_by			= N'MTN_DATA'
					,mod_ip_address = N'MTN_DATA'
			where	substring(faktur_no, 5, 18)		= substring(@p_old_faktur_no, 5, 18) ;
		end ;
		
		SELECT 'AFTER',FAKTUR_NO,* FROM dbo.INVOICE where INVOICE_NO = @invoice_no
		SELECT 'AFTER',FAKTUR_NO,* FROM dbo.faktur_allocation_detail where INVOICE_NO = @invoice_no
		SELECT 'AFTER',FAKTUR_NO,* FROM dbo.FAKTUR_MAIN where FAKTUR_NO =  substring(@p_old_faktur_no, 5, 18) ;
		
		--insert mtn log data
		begin
			INSERT INTO dbo.MTN_DATA_DSF_LOG
			(
				MAINTENANCE_NAME
				,REMARK
				,TABEL_UTAMA
				,REFF_1
				,REFF_2
				,REFF_3
				,CRE_DATE
				,CRE_BY
			)
			values
			(
				'MTN KOREKSI FAKTUR'
				,@p_mtn_remark
				,'INVOICE'
				,@invoice_no
				,@p_old_faktur_no -- REFF_2 - nvarchar(50)
				,@p_new_faktur_no -- REFF_3 - nvarchar(50)
				,getdate()
				,@p_mtn_cre_by
			)
		end

		if @@error = 0
		begin
			select 'SUCCESS'
			commit transaction ;
			--rollback transaction ;
		end ;
		else
		begin
			select 'GAGAL'
			rollback transaction ;
		end ;
	end try
	begin catch 
		
		rollback transaction ;

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
