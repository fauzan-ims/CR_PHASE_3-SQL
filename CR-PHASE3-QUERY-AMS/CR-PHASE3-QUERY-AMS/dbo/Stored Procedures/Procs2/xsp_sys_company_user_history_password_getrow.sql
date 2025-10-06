
create procedure xsp_sys_company_user_history_password_getrow
(
	@p_ucode nvarchar(15)
)
as
begin
	select	running_number
			,user_code
			,password_type
			,date_change_pass
			,oldpass
			,newpass
	from	sys_company_user_history_password
	where	user_code = @p_ucode ;
end ;
