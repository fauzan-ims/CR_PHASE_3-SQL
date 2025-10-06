create procedure xsp_sys_role_sec_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,name
			,access_type
	from	sys_role_sec
	where	code = @p_code ;
end ;
