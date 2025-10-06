CREATE PROCEDURE dbo.xsp_sys_menu_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	mm.code
			,mm.name
			,mm.url_menu
			,mm.abbreviation
			,mm.css_icon
			,mm.is_active is_active
			,mm2.name 'parent_name'
			,mm2.code 'parent_code'
			,mm.module_code
			,sm.module_name
			,mm.order_key
			,mm.type
	from	sys_menu mm
			left join sys_menu mm2 on (mm.parent_menu_code = mm2.code)
			left join dbo.sys_module sm on (sm.code = mm.module_code)
	where	mm.code = @p_code ;
end ;
