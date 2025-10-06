CREATE PROCEDURE dbo.xsp_sys_menu_role_getrow
(
	@p_role_code nvarchar(50)
)
as
begin
	select	role_code
			,menu_code
			,role_name
			,role_access
	from	sys_menu_role
	where	role_code = @p_role_code ;
end ;
