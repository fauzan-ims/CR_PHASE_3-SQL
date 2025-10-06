
create procedure xsp_sys_company_user_login_log_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,user_code
			,login_date
			,flag_code
			,session_id
	from	sys_company_user_login_log
	where	id = @p_id ;
end ;
