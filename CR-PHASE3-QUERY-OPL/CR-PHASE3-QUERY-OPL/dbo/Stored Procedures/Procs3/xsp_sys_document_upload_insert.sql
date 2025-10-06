CREATE PROCEDURE dbo.xsp_sys_document_upload_insert
(
	@p_child		   nvarchar(50)
	,@p_header		   nvarchar(250)
	,@p_id			   bigint		= 0
	,@p_code		   nvarchar(50) = null
	,@p_invoice_no	   nvarchar(50) = null
	,@p_file_name	   nvarchar(250)
	,@p_base64		   varchar(max)
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max)
			,@reff_trx_code nvarchar(50) ;

	if (@p_id <> 0)
	begin
		set @reff_trx_code = cast(@p_id as nvarchar(50)) ;
	end ;
	else
	begin
		set @reff_trx_code = isnull(@p_code, @p_invoice_no) ;
	end ;

	begin try
		insert into dbo.sys_document_upload
		(
			reff_no
			,reff_name
			,reff_trx_code
			,file_name
			,doc_file
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_child
			,@p_header
			,@reff_trx_code
			,@p_file_name
			,cast(@p_base64 as varbinary(max))
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
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
