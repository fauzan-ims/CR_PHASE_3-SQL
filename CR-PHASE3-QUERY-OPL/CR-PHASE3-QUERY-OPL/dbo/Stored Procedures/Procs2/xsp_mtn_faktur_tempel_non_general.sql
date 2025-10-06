CREATE PROCEDURE dbo.xsp_mtn_faktur_tempel_non_general
(
	@p_invoice_no nvarchar(50)
	,@p_invoice_no_2 nvarchar(50)
	,@p_new_faktur nvarchar(50)
	,@p_old_faktur nvarchar(50)
	,@p_new_faktur_2 nvarchar(50)
)
as
begin
	declare @msg		nvarchar(max)
			,@invoice_no	nvarchar(50)	= replace(@p_invoice_no, '/', '.')
			,@invoice_no_2	nvarchar(50)	= replace(@p_invoice_no_2, '/', '.')
			,@mod_date		datetime		= getdate();

	begin transaction;
	begin try

		select	'BEFORE'
				,FAKTUR_NO
				,*
		from	dbo.INVOICE
		where INVOICE_NO in (@invoice_no, @invoice_no_2);
		select	'BEFORE'
				,FAKTUR_NO
				,*
		from	dbo.FAKTUR_MAIN
		where INVOICE_NO in (@invoice_no);
		select	'BEFORE'
				,FAKTUR_NO
				,*
		from	dbo.FAKTUR_ALLOCATION_DETAIL
		where INVOICE_NO in (@invoice_no, @invoice_no_2);
		--NEW
		update	dbo.INVOICE
		set FAKTUR_NO = @p_new_faktur	--new faktur
			,MOD_DATE = @mod_date
			,MOD_BY = 'MTN_RAFFI'
			,MOD_IP_ADDRESS = 'MTN_RAFFI'
		where INVOICE_NO = @invoice_no;

		update	dbo.FAKTUR_MAIN
		set INVOICE_NO = @invoice_no
			,MOD_DATE = @mod_date
			,MOD_BY = 'MTN_RAFFI'
			,MOD_IP_ADDRESS = 'MTN_RAFFI'
		where FAKTUR_NO = substring(@p_new_faktur, 5, 18);	--new faktur

		update	dbo.FAKTUR_ALLOCATION_DETAIL
		set FAKTUR_NO = @p_new_faktur	--invoice
			,MOD_DATE = @mod_date
			,MOD_BY = 'MTN_RAFFI'
			,MOD_IP_ADDRESS = 'MTN_RAFFI'
		where INVOICE_NO = @invoice_no;

		-- OLD
		update	dbo.FAKTUR_MAIN
		set INVOICE_NO = 'FAKTUR ALREADY USE'
			,MOD_DATE = @mod_date
			,MOD_BY = 'MTN_RAFFI'
			,MOD_IP_ADDRESS = 'MTN_RAFFI'
		where FAKTUR_NO = substring(@p_old_faktur, 5, 18);	--old faktur

		--NEW NEXT
		update	dbo.INVOICE
		set FAKTUR_NO = @p_new_faktur_2 --new faktur
			,MOD_DATE = @mod_date
			,MOD_BY = 'MTN_RAFFI'
			,MOD_IP_ADDRESS = 'MTN_RAFFI'
		where INVOICE_NO = @invoice_no_2;

		update	dbo.FAKTUR_MAIN
		set INVOICE_NO = @invoice_no_2	--invoice
			,MOD_DATE = @mod_date
			,MOD_BY = 'MTN_RAFFI'
			,MOD_IP_ADDRESS = 'MTN_RAFFI'
		where FAKTUR_NO = substring(@p_new_faktur_2, 5, 18);	--new faktur

		update	dbo.FAKTUR_ALLOCATION_DETAIL
		set FAKTUR_NO = @p_new_faktur_2 --invoice
			,MOD_DATE = @mod_date
			,MOD_BY = 'MTN_RAFFI'
			,MOD_IP_ADDRESS = 'MTN_RAFFI'
		where INVOICE_NO = @invoice_no_2;	--new faktur

		select	'AFTER'
				,FAKTUR_NO
				,*
		from	dbo.INVOICE
		where INVOICE_NO in (@invoice_no, @invoice_no_2);
		select	'AFTER'
				,FAKTUR_NO
				,*
		from	dbo.FAKTUR_MAIN
		where INVOICE_NO in (@invoice_no);
		select	'AFTER'
				,FAKTUR_NO
				,*
		from	dbo.FAKTUR_ALLOCATION_DETAIL
		where INVOICE_NO in (@invoice_no, @invoice_no_2);
		select	*
		from	dbo.FAKTUR_MAIN
		where FAKTUR_NO = substring(@p_old_faktur, 5, 18);
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
				,'TEMPEL FAKTUR UNTUK INVOICE YG SUDAH POST/PAID'
				,'INVOICE'
				,@p_invoice_no
				,@p_invoice_no_2	-- REFF_2 - nvarchar(50)
				,null				-- REFF_3 - nvarchar(50)
				,@mod_date, 'MTN_RAFFI');
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
