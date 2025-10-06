CREATE PROCEDURE dbo.xsp_sys_it_param_getrow
as
begin
	select	convert(varchar(30), system_date, 103) 'system_date'
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
	from	sys_it_param ;
end ;
