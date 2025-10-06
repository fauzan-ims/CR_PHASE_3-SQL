
CREATE procedure dbo.xsp_sys_document_upload_update
(
	@p_reff_no		   nvarchar(50)
	,@p_reff_name	   nvarchar(250)
	,@p_reff_trx_code  nvarchar(50)
	,@p_file_name	   nvarchar(250)
	,@p_base64		   varchar(max)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	sys_document_upload
		set		file_name		  = @p_file_name
				,doc_file		  = cast(@p_base64 as varbinary(max))
				--				  
				,mod_date		  = @p_mod_date
				,mod_by			  = @p_mod_by
				,mod_ip_address	  = @p_mod_ip_address
		where	reff_no			  = @p_reff_no
				and reff_name	  = @p_reff_name
				and reff_trx_code = @p_reff_trx_code ;
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
