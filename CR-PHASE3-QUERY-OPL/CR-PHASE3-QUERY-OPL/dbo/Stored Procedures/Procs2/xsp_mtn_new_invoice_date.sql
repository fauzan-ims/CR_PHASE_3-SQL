CREATE PROCEDURE dbo.xsp_mtn_new_invoice_date
(
	--SCRIPT NEW INVOICE DATE
	@p_invoice_no		nvarchar(50)
	,@p_new_invoice_date DATETIME
	,@p_mtn_remrk		NVARCHAR(4000)
	--
	,@p_mod_by			nvarchar(15)
	,@p_from			NVARCHAR(50) ='SINGLE'
)
as
begin
	declare @msg					nvarchar(max)
			,@invoice_no			nvarchar(50) 
			,@mod_date				DATETIME = GETDATE()
			,@mod_ip_address		NVARCHAR(15) = @p_mod_by
			,@ahreement_no			NVARCHAR(50)

	begin TRY
		set @invoice_no = replace(@p_invoice_no,'/','.')

		select @ahreement_no = invvd.agreement_no
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

		IF (@p_from <> 'MULTIPLE')
		BEGIN
			SELECT 'BEFORE',NEW_INVOICE_DATE,* from ifinopl.dbo.invoice where invoice_no = @invoice_no
		END
		update ifinopl.dbo.invoice
		set new_invoice_date	= cast(@p_new_invoice_date as date)
			,mod_date			= @mod_date
			,mod_by				= @p_mod_by
			,mod_ip_address		= @mod_ip_address
		where invoice_no = @invoice_no

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
				'MTN NEW INVOICE DATE'
				,@p_mtn_remrk
				,'INVOICE'
				,@ahreement_no
				,@p_invoice_no -- REFF_2 - nvarchar(50)
				,'' -- REFF_3 - nvarchar(50)
				,getdate()
				,@p_mod_by
			)

		IF (@p_from <> 'MULTIPLE')
		BEGIN
			SELECT 'AFTER',NEW_INVOICE_DATE,* from ifinopl.dbo.invoice where invoice_no = @invoice_no
		END

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

GO
GRANT ALTER
    ON OBJECT::[dbo].[xsp_mtn_new_invoice_date] TO [DSF\eddy.rakhman]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_mtn_new_invoice_date] TO [DSF\eddy.rakhman]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[dbo].[xsp_mtn_new_invoice_date] TO [eddy.r]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_mtn_new_invoice_date] TO [eddy.r]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_mtn_new_invoice_date] TO [aryo.budi]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_mtn_new_invoice_date] TO [DSF\windy.nurbani]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_mtn_new_invoice_date] TO [windy.nurbani]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[dbo].[xsp_mtn_new_invoice_date] TO [eddy.rakhman]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_mtn_new_invoice_date] TO [eddy.rakhman]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_mtn_new_invoice_date] TO [bsi-miki.maulana]
    AS [dbo];

