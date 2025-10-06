CREATE PROCEDURE dbo.xsp_sys_it_param_update
(
    --@p_system_date datetime,
    @p_db_mail_profile				nvarchar(50)
    ,@p_user_auto_inactive			int
    ,@p_password_max_repeat_time	int
    ,@p_password_max_login_try		int
    ,@p_password_next_change		int
    ,@p_password_min_char			int
    ,@p_password_max_char			int
    ,@p_password_regex				nvarchar(1)
    ,@p_password_use_uppercase		nvarchar(1)
    ,@p_password_use_lowercase		nvarchar(1)
    ,@p_password_contain_number		nvarchar(1)
    ,@p_is_eod_running				nvarchar(1)
    ,@p_eod_manual_flag				nvarchar(1)
	,@p_subscription_type_code		nvarchar(50)  = ''
	,@p_max_user					int			  = 0
    --								
    ,@p_mod_date					datetime
    ,@p_mod_by						nvarchar(15)
    ,@p_mod_ip_address				nvarchar(15)
)
AS
BEGIN
    DECLARE @msg NVARCHAR(MAX);

    if @p_password_use_uppercase = 'T'
        set @p_password_use_uppercase = '1';
    else
        set @p_password_use_uppercase = '0';

    if @p_password_use_lowercase = 'T'
        set @p_password_use_lowercase = '1';
    else
        set @p_password_use_lowercase = '0';

    if @p_password_contain_number = 'T'
        set @p_password_contain_number = '1';
    else
        set @p_password_contain_number = '0';

    if @p_is_eod_running = 'T'
        set @p_is_eod_running = '1';
    else
        set @p_is_eod_running = '0';

    if @p_eod_manual_flag = 'T'
        set @p_eod_manual_flag = '1';
    else
        set @p_eod_manual_flag = '0';

    begin try

        if (@p_password_min_char > @p_password_max_char)
        begin
            set @msg = 'Maximum Length must be larger than Minimum Length';
            raiserror(@msg, 16, -1);
        end;
        if (@p_password_max_char < 4)
        begin
            set @msg = 'Maximum Length must be larger than 4';
            raiserror(@msg, 16, -1);
        end;
        if (@p_password_min_char < 4)
        begin
            set @msg = 'Minimum Length must be larger than 4';
            raiserror(@msg, 16, -1);
        end;
				update	sys_it_param
				set		 db_mail_profile			= @p_db_mail_profile
						,user_auto_inactive			= @p_user_auto_inactive
						,password_max_repeat_time	= @p_password_max_repeat_time
						,password_max_login_try		= @p_password_max_login_try
						,password_next_change		= @p_password_next_change
						,password_min_char			= @p_password_min_char
						,password_max_char			= @p_password_max_char
						,password_regex				= @p_password_regex
						,password_use_uppercase		= @p_password_use_uppercase
						,password_use_lowercase		= @p_password_use_lowercase
						,password_contain_number	= @p_password_contain_number
						,is_eod_running				= @p_is_eod_running
						,eod_manual_flag			= @p_eod_manual_flag
						,subscription_type_code		= @p_subscription_type_code
						,max_user					= @p_max_user
						--							 
						,mod_date					= @p_mod_date
						,mod_by						= @p_mod_by
						,mod_ip_address				= @p_mod_ip_address ;
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
end;
