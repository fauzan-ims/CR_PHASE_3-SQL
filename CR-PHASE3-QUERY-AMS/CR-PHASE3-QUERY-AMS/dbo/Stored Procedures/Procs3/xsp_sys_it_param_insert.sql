CREATE PROCEDURE dbo.xsp_sys_it_param_insert
	@p_system_date				 datetime
	,@p_db_mail_profile			 nvarchar(50)
	,@p_user_auto_inactive		 int
	,@p_password_max_repeat_time int
	,@p_password_max_login_try	 int
	,@p_password_next_change	 int
	,@p_password_min_char		 int
	,@p_password_max_char		 int
	,@p_password_regex			 nvarchar(1)
	,@p_password_use_uppercase	 nvarchar(1)
	,@p_password_use_lowercase	 nvarchar(1)
	,@p_password_contain_number	 nvarchar(1)
	,@p_is_eod_running			 nvarchar(1)
	,@p_eod_manual_flag			 nvarchar(1)
	,@p_subscription_type_code	 nvarchar(50)
	,@p_max_user				 int
	--								
	,@p_cre_date				 datetime
	,@p_cre_by					 nvarchar(15)
	,@p_cre_ip_address			 nvarchar(15)
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into dbo.sys_it_param
		(
			system_date
			,db_mail_profile
			,user_auto_inactive
			,password_max_repeat_time
			,password_max_login_try
			,password_next_change
			,password_min_char
			,password_max_char
			,password_regex
			,password_use_uppercase
			,password_use_lowercase
			,password_contain_number
			,is_eod_running
			,eod_manual_flag
			,subscription_type_code
			,max_user
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_system_date
			,@p_db_mail_profile
			,@p_user_auto_inactive
			,@p_password_max_repeat_time
			,@p_password_max_login_try
			,@p_password_next_change
			,@p_password_min_char
			,@p_password_max_char
			,@p_password_regex
			,@p_password_use_uppercase
			,@p_password_use_lowercase
			,@p_password_contain_number
			,@p_is_eod_running
			,@p_eod_manual_flag
			,@p_subscription_type_code
			,@p_max_user
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
