CREATE PROCEDURE dbo.xsp_api_log_update
(
	@p_transaction_no	 nvarchar(250)
	,@p_log_date		 datetime
	,@p_url_request		 nvarchar(max)
	,@p_json_content	 nvarchar(max)
	,@p_response_code	 nvarchar(max)
	,@p_response_message nvarchar(max)
	,@p_response_json	 nvarchar(max)
	--
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	api_log
		set		log_date			= @p_log_date
				,url_request		= @p_url_request
				,json_content		= @p_json_content
				,response_code		= @p_response_code
				,response_message	= @p_response_message
				,response_json		= @p_response_json
				--
				,mod_date			 = getdate()
				,mod_by				 = @p_mod_by
				,mod_ip_address		 = @p_mod_ip_address
		where	transaction_no = @p_transaction_no ;
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
