CREATE PROCEDURE dbo.xsp_sys_menu_for_sidebar_getrows
(
	@p_module_code nvarchar(50) = '',
	@p_parent_menu_name nvarchar(50),
	@p_user_code nvarchar(50) = ''
)
as
begin
	-- Trisna 27-Oct-2022 ket : for wom(+) ==
	update	dbo.sys_company_user_main 
	set		last_fail_count = 0
			,last_login_date = getdate() 
	where code = @p_user_code ;
	
						
	declare @tempTableSubMenu table
	(
		subCode	nvarchar(50)
	)
			
	-- Arga 18-Oct-2022 ket : temporary for wom impact to loading (+) ==
	insert into @tempTableSubMenu
	(
		subCode
	)
	select distinct 
			sm.code
	from dbo.sys_menu_role smr
	inner join dbo.sys_menu sm	on (sm.code = smr.menu_code)
	where	sm.is_active	 = '1'
			and sm.module_code  = @p_module_code
			and smr.role_access = 'A'
					
								
	select		code 'idSubMenu'
				,isnull(url_menu, '') 'path'
				,name 'title'
				,'submenus' as 'type'
				,css_icon as 'icontype'
	from		dbo.sys_menu
	where		parent_menu_code	= @p_parent_menu_name
				and code in (select subCode collate latin1_general_ci_as from @tempTableSubMenu) 
				and is_active		 = '1' 
	order by	order_key
					
			
end		
