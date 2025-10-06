CREATE PROCEDURE dbo.xsp_sys_company_user_reset_password_update
(
	@p_code			   nvarchar(50)
	,@p_request_date   datetime
	,@p_user_code	   nvarchar(15)
	,@p_password_type  nvarchar(10)
	,@p_new_password   nvarchar(20)
	,@p_remarks		   nvarchar(4000)
	,@p_status		   nvarchar(10)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	sys_company_user_reset_password
		set		request_date		= @p_request_date
				,user_code			= @p_user_code
				,password_type		= @p_password_type
				,new_password		= @p_new_password
				,remarks			= @p_remarks
				,status				= @p_status
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code = @p_code ;
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
