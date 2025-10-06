CREATE PROCEDURE dbo.xsp_sys_company_user_history_password_update
(
	@p_running_number	 int
	,@p_user_code		 nvarchar(15)
	,@p_password_type	 nvarchar(10)
	,@p_date_change_pass datetime
	,@p_oldpass			 nvarchar(20)
	,@p_newpass			 nvarchar(20)
	--
	,@p_mod_date		 datetime
	,@p_mod_by			 nvarchar(15)
	,@p_mod_ip_address	 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	sys_company_user_history_password
		set		running_number		= @p_running_number
				,user_code			= @p_user_code
				,password_type		= @p_password_type
				,date_change_pass	= @p_date_change_pass
				,oldpass			= @p_oldpass
				,newpass			= @p_newpass
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	user_code			= @p_user_code ;
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
