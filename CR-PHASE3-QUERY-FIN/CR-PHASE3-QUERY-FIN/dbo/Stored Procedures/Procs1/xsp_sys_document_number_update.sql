CREATE PROCEDURE dbo.xsp_sys_document_number_update
(
	@p_code					nvarchar(50)
	,@p_code_document		nvarchar(50)
	,@p_description			nvarchar(250)
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
BEGIN

	declare @msg nvarchar(max) ;

	begin TRY
		
		if exists (select 1 from sys_document_number where code_document = @p_code_document and code <> @p_code)
		begin
			set @msg = 'Document Code already exist';
			raiserror(@msg, 16, -1) ;
		END
        
		if exists (select 1 from sys_document_number where description = @p_description and code <> @p_code)
		begin
			set @msg = 'Description already exist';
			raiserror(@msg, 16, -1) ;
		end 

		update	dbo.sys_document_number
		set		code_document	= upper(@p_code_document)
				,description	= upper(@p_description)
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	code			= @p_code ;

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
