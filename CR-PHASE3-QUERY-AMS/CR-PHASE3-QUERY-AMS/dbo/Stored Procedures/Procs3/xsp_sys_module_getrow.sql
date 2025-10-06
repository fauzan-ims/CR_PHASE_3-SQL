create PROCEDURE dbo.xsp_sys_module_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,module_name
			,module_ip
			,is_active 
	from	sys_module		
	where	code = @p_code ;
end ;
