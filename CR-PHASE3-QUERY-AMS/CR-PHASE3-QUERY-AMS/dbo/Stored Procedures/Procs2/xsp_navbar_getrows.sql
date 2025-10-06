CREATE PROCEDURE dbo.xsp_navbar_getrows
(
	@p_module_code nvarchar(50)
)
as
begin
	select		 
				code 'idSubMenu'
				,isnull(url_menu, '') 'path'
				,name 'title'
				,'submenus' as 'type'
				,css_icon as 'icontype'
				,parent_menu_code
	from		ifinsys.dbo.sys_menu
	where		isnull(parent_menu_code,'') <> ''
				and is_active				= '1'
				and module_code				= @p_module_code
	order by	order_key
end ;
