
create procedure xsp_sys_company_user_main_group_sec_getrow
(
	@p_role_group_code nvarchar(50)
)
as
begin
	select	role_group_code
			,user_code
	from	sys_company_user_main_group_sec
	where	role_group_code = @p_role_group_code ;
end ;
