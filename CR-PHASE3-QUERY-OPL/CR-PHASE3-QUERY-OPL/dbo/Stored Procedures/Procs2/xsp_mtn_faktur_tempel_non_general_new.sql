CREATE PROCEDURE dbo.xsp_mtn_faktur_tempel_non_general_new
(
	 @p_invoice_no nvarchar(50)
	,@p_faktur_no_new nvarchar(50)
	,@p_faktur_no_old nvarchar(50)
	,@p_mod_by nvarchar(50)
	,@p_remark nvarchar(4000)
)
as
begin
	declare @msg				nvarchar(max)
			,@invoice_no		nvarchar(50) = replace(@p_invoice_no, '/', '.')
			,@mod_date			datetime = dbo.xfn_get_system_date()
			,@p_mod_ip_adress	nvarchar(20) = @p_mod_by
			,@invoice_no_validation nvarchar(50)

	begin transaction;
	begin try

		if not exists (SELECT 1 FROM dbo.FAKTUR_MAIN where FAKTUR_NO = substring(@p_faktur_no_new, 5, 18) )
		begin
			set @msg = 'MOHON DAFTARKAN TERLEBIH DAHULU UNTUK FAKTUR BARUNYA';
			raiserror(@msg, 16, 1) ;
			return
		end

		SELECT @invoice_no_validation = INVOICE_EXTERNAL_NO
		from dbo.INVOICE 
		where FAKTUR_NO = @p_faktur_no_new 
		and INVOICE_STATUS <> 'CANCEL'

		if exists (SELECT 1 FROM dbo.INVOICE where FAKTUR_NO = @p_faktur_no_new and INVOICE_STATUS <> 'CANCEL' )
		begin
			set @msg = 'FAKTUR SUDAH DIGUNAKAN DI INVOICE BERIKUT : ' + @invoice_no_validation;
			raiserror(@msg, 16, 1) ;
			return
		end

		update	dbo.INVOICE
		set FAKTUR_NO = @p_faktur_no_new	--new faktur
			,MOD_DATE = @mod_date
			,MOD_BY = @p_mod_by
			,MOD_IP_ADDRESS = @p_mod_by
		where INVOICE_NO = @invoice_no;
		
		update	dbo.FAKTUR_MAIN
		set INVOICE_NO = @invoice_no
			,MOD_DATE = @mod_date
			,MOD_BY = @p_mod_by
			,MOD_IP_ADDRESS = @p_mod_by
		where FAKTUR_NO = substring(@p_faktur_no_new, 5, 18);	--new faktur
		
		update	dbo.FAKTUR_ALLOCATION_DETAIL
		set FAKTUR_NO = @p_faktur_no_new	--invoice
			,MOD_DATE = @mod_date
			,MOD_BY = @p_mod_by
			,MOD_IP_ADDRESS = @p_mod_by
		where INVOICE_NO = @invoice_no;

		update	dbo.FAKTUR_MAIN
		set INVOICE_NO = 'FAKTUR ALREADY USE'
			,MOD_DATE = @mod_date
			,MOD_BY = @p_mod_by
			,MOD_IP_ADDRESS = @p_mod_by
		where FAKTUR_NO = substring(@p_faktur_no_old, 5, 18);	--old faktur

		select	'AFTER'
				,FAKTUR_NO
				,*
		from	dbo.INVOICE
		where INVOICE_NO = @invoice_no

		select	'AFTER'
				,FAKTUR_NO
				,*
		from	dbo.FAKTUR_MAIN
		where INVOICE_NO = @invoice_no

		select	'AFTER'
				,FAKTUR_NO
				,*
		from	dbo.FAKTUR_ALLOCATION_DETAIL
		where INVOICE_NO = @invoice_no

		select	'OLD_FAKTUR',FAKTUR_NO,*
		from	dbo.FAKTUR_MAIN
		where FAKTUR_NO = substring(@p_faktur_no_old, 5, 18);

		--insert mtn log data
		begin
			insert into dbo.MTN_DATA_DSF_LOG
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
			(	'MTN FAKTUR TEMPEL'
				,@p_remark
				,'INVOICE'
				,@invoice_no
				,null	-- REFF_2 - nvarchar(50)
				,null				-- REFF_3 - nvarchar(50)
				,@mod_date
				,@p_mod_by
			);
		end;

		if @@error = 0
		begin
			select	'SUCCESS';
			commit transaction;
		end;
		else
		begin
			select	'GAGAL';
			rollback transaction;
		end;
	end try
	begin catch

		rollback transaction;

		if (len(@msg) <> 0)
		begin
			set @msg = N'V' + N';' + @msg;
		end;
		else
		begin
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message();
			end;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message();
			end;
		end;

		raiserror(@msg, 16, -1);

		return;
	end catch;
end;
