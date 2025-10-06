CREATE PROCEDURE dbo.xsp_sys_company_user_main_update
(
	@p_code				 nvarchar(50)
	,@p_company_code	 nvarchar(50)
	,@p_upass			 nvarchar(20)
	,@p_upassapproval	 nvarchar(20)
	,@p_name			 nvarchar(100)
	,@p_username		 nvarchar(50)
	,@p_main_task_code	 nvarchar(50)
	,@p_email			 nvarchar(50)
	,@p_phone_no		 nvarchar(25)
	,@p_province_code	 nvarchar(50)
	,@p_province_name	 nvarchar(250)
	,@p_city_code		 nvarchar(50)
	,@p_city_name		 nvarchar(250)
	,@p_last_login_date	 datetime	 = null
	,@p_last_fail_count	 int		 = 0
	,@p_next_change_pass datetime	 = null
	,@p_module			 nvarchar(20)
	,@p_is_default		 nvarchar(1)
	,@p_is_active		 nvarchar(1)
	--
	,@p_mod_date		 datetime
	,@p_mod_by			 nvarchar(15)
	,@p_mod_ip_address	 nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max) 
			,@upass				nvarchar(20)
			,@next_change_pass	datetime 
			,@username_old		nvarchar(50)
			,@email_old			nvarchar(50);

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	begin try
		select	@upass = dbo.fn_generate_md5(@p_username) ;

		select	@next_change_pass = dateadd(month, password_next_change, dbo.xfn_get_system_date())
		from	dbo.sys_it_param ;
		
		select	@username_old = username
				,@email_old = email
		from	dbo.sys_company_user_main 
		where	code = @p_code;
		
		if @p_username = upper(@p_username) and @p_username like '%[^a-zA-Z0-9_]%'
		begin
			set @msg = 'Invalid Special Character for Username';
			raiserror(@msg, 16, -1) ;
		end

		if (@p_username <> @username_old)
		begin
			if exists (select 1 from dbo.sys_company_user_main where username = @p_username and code <> @p_code)
			begin
				set @msg = 'Username already exist';
				raiserror(@msg, 16, -1) ;
			end
		end
		
		if (@p_email <> @email_old)
		begin
			if exists (select 1 from dbo.sys_company_user_main where email = @p_email and code <> @p_code)
			begin
				set @msg = 'Email already exist';
				raiserror(@msg, 16, -1) ;
			end
		end
		
		update	sys_company_user_main
		set		company_code		= @p_company_code
				--,upass				= @upass
				--,upassapproval		= @upass
				,name				= @p_name
				,username			= @p_username
				,main_task_code		= @p_main_task_code
				,email				= @p_email
				,phone_no			= @p_phone_no
				,province_code		= @p_province_code
				,province_name		= @p_province_name
				,city_code			= @p_city_code
				,city_name			= @p_city_name
				,last_login_date	= @p_last_login_date
				,last_fail_count	= @p_last_fail_count
				,next_change_pass	= @next_change_pass
				,module				= @p_module
				,is_default			= @p_is_default
				,is_active			= @p_is_active
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
