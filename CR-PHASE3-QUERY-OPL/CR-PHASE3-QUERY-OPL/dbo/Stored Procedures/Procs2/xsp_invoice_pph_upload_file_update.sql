CREATE PROCEDURE dbo.xsp_invoice_pph_upload_file_update
(
	@p_invoice_no  nvarchar(50)
	,@p_file_name	nvarchar(250)
	,@p_file_paths	nvarchar(250)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	dbo.invoice_pph
		set		file_name	= upper(@p_file_name)
				,file_path	= upper(@p_file_paths)
		where	invoice_no	= @p_invoice_no ;
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
