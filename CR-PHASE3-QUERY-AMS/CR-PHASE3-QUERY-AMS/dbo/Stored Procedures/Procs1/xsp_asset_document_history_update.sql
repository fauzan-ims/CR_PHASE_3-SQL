CREATE PROCEDURE dbo.xsp_asset_document_history_update
(
	@p_id					bigint	= 0 output
	,@p_asset_code			nvarchar(50)
	,@p_document_code		nvarchar(50)
	,@p_document_no			nvarchar(50)
	,@p_description			nvarchar(4000)
	,@p_file_name			nvarchar(250)
	,@p_path				nvarchar(250)
		--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	asset_document_history
		set		asset_code		= @p_asset_code
				,document_code	= @p_document_code
				,document_no	= @p_document_no
				,description	= @p_description
				,file_name		= @p_file_name
				,path			= @p_path
					--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address	= @p_mod_ip_address
		where	id	= @p_id

	end try
	Begin catch
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
end
