CREATE PROCEDURE dbo.xsp_application_document_request_upload_file_update
(
	@p_code		   nvarchar(50)
	,@p_file_name  nvarchar(250)
	,@p_file_paths nvarchar(250)
)
as
begin
	declare	@msg	nvarchar(max)
	begin try

		update	application_document_request
		set		file_name	= upper(@p_file_name)
				,paths		= upper(@p_file_paths)
		where	code		= @p_code ;
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

