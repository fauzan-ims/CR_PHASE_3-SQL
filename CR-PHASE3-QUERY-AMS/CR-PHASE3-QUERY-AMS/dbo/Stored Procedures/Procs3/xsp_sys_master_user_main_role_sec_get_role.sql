CREATE procedure dbo.xsp_sys_master_user_main_role_sec_get_role
(
	@p_user_code nvarchar(50)
)
as
begin
	select	user_code
			,role_sec_code
	from	sys_user_main_role_sec
	where	user_code = @p_user_code ;
end ;
