CREATE PROCEDURE dbo.xsp_mtn_new_invoice_date_multiple
(
	--SCRIPT NEW INVOICE DATE multiple invoice
	@p_mtn_remrk		NVARCHAR(4000)
	--
	,@p_mod_by			nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@invoice_no			nvarchar(50) 
			,@mod_date				DATETIME = GETDATE()
			,@mod_ip_address		NVARCHAR(15) 
			,@ahreement_no			NVARCHAR(50)
			,@new_invoice_date	DATETIME
			,@invoice_status		NVARCHAR(50)

	BEGIN TRY

		SELECT @ahreement_no = invvd.agreement_no
		from ifinopl.dbo.invoice inv
		inner join dbo.invoice_detail invvd on invvd.invoice_no = inv.invoice_no
		where inv.INVOICE_NO = @invoice_no

		IF (isnull(@p_mtn_remrk, '') = '')
		begin
			set @msg = 'Harap diisi MTN Remark';
			raiserror(@msg, 16, 1) ;
			return
		end

		if (isnull(@p_mod_by, '') = '')
		begin
			set @msg = 'Harap diisi MTN Mod By';
			raiserror(@msg, 16, 1) ;
			return
		end


		select 'BEFORE',NEW_INVOICE_DATE,* from ifinopl.dbo.invoice where INVOICE_EXTERNAL_NO IN
		(
			SELECT INVOICE_NO 
			FROM dbo.MTN_NEW_INVOICE_DATE
			WHERE STATUS = 'HOLD'

		)
		declare cur_reason cursor fast_forward read_only for
		select	mtn.INVOICE_NO,
				invoice_status,
				mtn.NEW_INVOICE_DATE,
				mtn.cre_ip_address
		from	dbo.mtn_new_invoice_date mtn
		inner join dbo.invoice i on i.invoice_external_no = mtn.invoice_no
		where	mtn.status = 'HOLD'

		open cur_reason
		
		fetch next from cur_reason 
		into	@invoice_no
				,@invoice_status
				,@new_invoice_date
				,@mod_ip_address

		while @@fetch_status = 0
		begin

		IF (@invoice_status = 'NEW')
		BEGIN

			EXEC dbo.xsp_mtn_new_invoice_date @p_invoice_no		= @invoice_no,                         -- nvarchar(50)
											@p_new_invoice_date = @new_invoice_date,		-- datetime
											@p_mtn_remrk		= @p_mtn_remrk,                          -- nvarchar(4000)
											@p_mod_by			= @p_mod_by,                              -- nvarchar(15)
											@p_from				= 'MULTIPLE'

			INSERT INTO IFINOPL.dbo.MTN_DATA_DSF_LOG
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
				'MTN NEW INVOICE DATE MULTIPLE'
				,@p_mtn_remrk
				,'INVOICE'
				,@invoice_no
				,@new_invoice_date -- REFF_2 - nvarchar(50)
				,@p_mod_by -- REFF_3 - nvarchar(50)
				,getdate()
				,@p_mod_by
			)

			update dbo.mtn_new_invoice_date
			set		status			= 'POST'
					--
					,mod_by			= @p_mod_by
					,mod_date		= getdate()
					,mod_ip_address	= @mod_ip_address
			where invoice_no		= @invoice_no


		END
		fetch next from cur_reason 
		into	@invoice_no
				,@invoice_status
				,@new_invoice_date
				,@mod_ip_address
			
		end
		close cur_reason
		deallocate cur_reason


		select 'AFTER',NEW_INVOICE_DATE,* from ifinopl.dbo.invoice where INVOICE_EXTERNAL_NO IN
		(
			select	invoice_no 
			from	dbo.mtn_new_invoice_date
			where	status = 'POST'
			and		cast(mod_date as date) = cast(getdate() as date)
		)

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
