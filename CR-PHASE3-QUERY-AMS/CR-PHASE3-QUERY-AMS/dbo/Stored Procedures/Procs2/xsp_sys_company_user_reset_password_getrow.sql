
create procedure xsp_sys_company_user_reset_password_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,request_date
			,user_code
			,password_type
			,new_password
			,remarks
			,status
	from	sys_company_user_reset_password
	where	code = @p_code ;
end ;
