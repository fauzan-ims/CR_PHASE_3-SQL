CREATE PROCEDURE dbo.xsp_sys_module_menu_for_sidebar_getrows
(
	--@p_parent_menu_name nvarchar(50) = 'ALL'
	@p_parent_module_code nvarchar(50),
	@p_user_code nvarchar(15) = ''
)
as
begin
	-- jika module code lebih dari 1 kata dan menggunakan spasi
	-- maka collapse tidak akan berfungsi pada sidebar menu be carefull!!! (05/02/2020 louis handry)
	declare @tempTableParentMenu table
	(
		parentCode	nvarchar(50)
	)


	insert into @tempTableParentMenu
	(
		parentCode
	)
	select	distinct 
			sm.parent_menu_code
	from	sys_role_group srg
			inner join sys_role_group_detail srgd on srgd.role_group_code = srg.code
			inner join MOBIESYS.dbo.sys_menu_role smr on smr.role_code = srgd.role_code collate latin1_general_ci_as
			inner join MOBIESYS.dbo.sys_menu sm on sm.code = smr.menu_code
			inner join dbo.sys_company_user_main_group_sec sumgc on sumgc.role_group_code = srg.code collate SQL_Latin1_General_CP1_CI_AS
	where	sm.is_active	 = '1'
	and		sm.module_code  = @p_parent_module_code 
	and		sumgc.user_code = @p_user_code


	select 		code 'idModule'  
				,name
				,css_icon 'icontype'
				,order_key
				,url_menu
				,type
	from		MOBIESYS.dbo.sys_menu  
	where		code in (select parentCode collate latin1_general_ci_as from @tempTableParentMenu) 
	group by	code
				,name
				,css_icon
				,order_key
				,url_menu
				,type
	order by	order_key asc  ;
	
end ;

