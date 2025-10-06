CREATE PROCEDURE dbo.xsp_sys_menu_child_for_sidebar_getrows
(
	@p_code nvarchar(50)
)
as
begin
	select		isnull(url_menu, '') 'path'
				,name 'title'
				,abbreviation as 'ab'
				,'child' as 'type'
	from		eprocsys.dbo.sys_menu
	where		parent_menu_code = @p_code
				and is_active	 = '1' 
	order by	order_key
end ;
