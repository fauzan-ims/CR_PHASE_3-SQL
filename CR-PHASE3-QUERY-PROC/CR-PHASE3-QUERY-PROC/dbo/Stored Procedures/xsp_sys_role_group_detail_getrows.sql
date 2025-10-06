CREATE PROCEDURE dbo.xsp_sys_role_group_detail_getrows
(
	@p_keywords			 nvarchar(50)
	,@p_pagenumber		 int
	,@p_rowspage		 int
	,@p_order_by		 int
	,@p_sort_by			 nvarchar(5)
	--
	,@p_code			 nvarchar(50)	= ''
	,@p_module_code		 nvarchar(50)	= ''
	,@p_parent_menu_code nvarchar(50)	= ''
	,@p_role_group_code	 nvarchar(100)
	,@p_role_access		 nvarchar(50)	= ''
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from		dbo.sys_role_group_detail srg
	inner join ifinbam.dbo.sys_menu sm  on (srg.menu_code = sm.code)
	inner join dbo.sys_module ssm on (ssm.code = sm.module_code)
	where		role_group_code	 = @p_role_group_code
				and submenu_code = case @p_code
									   when '' then submenu_code
									   else @p_code
								   end
				and menu_code	 = case @p_parent_menu_code
									   when '' then menu_code
									   else @p_parent_menu_code
								   end
				and role_name	 = case @p_role_access
									   when 'ALL' then role_name
									   else @p_role_access
								   end
				and (
						role_group_code		like '%' + @p_keywords + '%'
						or	role_code		like '%' + @p_keywords + '%'
						or	role_name		like '%' + @p_keywords + '%'
						or	menu_code		like '%' + @p_keywords + '%'
						or	menu_name		like '%' + @p_keywords + '%'
						or	submenu_code	like '%' + @p_keywords + '%'
						or	submenu_name	like '%' + @p_keywords + '%'
						or	ssm.module_name	like '%' + @p_keywords + '%'
					)

	select		id
				,role_group_code
				,role_code
				,role_name
				,menu_code
				,menu_name 'menu_name'
				,submenu_code
				,submenu_name 'sub_name'
				,ssm.module_name
				,@rows_count as 'rowcount'
	from		dbo.sys_role_group_detail srg
	inner join ifinbam.dbo.sys_menu sm  on (srg.menu_code = sm.code)
	inner join dbo.sys_module ssm on (ssm.code = sm.module_code)
	where		role_group_code	 = @p_role_group_code
				and submenu_code = case @p_code
									   when '' then submenu_code
									   else @p_code
								   end
				and menu_code	 = case @p_parent_menu_code
									   when '' then menu_code
									   else @p_parent_menu_code
								   end
				and role_name	 = case @p_role_access
									   when 'ALL' then role_name
									   else @p_role_access
								   end
				and (
						role_group_code		like '%' + @p_keywords + '%'
						or	role_code		like '%' + @p_keywords + '%'
						or	role_name		like '%' + @p_keywords + '%'
						or	menu_code		like '%' + @p_keywords + '%'
						or	menu_name		like '%' + @p_keywords + '%'
						or	submenu_code	like '%' + @p_keywords + '%'
						or	submenu_name	like '%' + @p_keywords + '%'
						or	ssm.module_name	like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then role_code
													 when 2 then role_name
													 when 3 then ssm.module_name
													 when 4 then submenu_name
													 when 5 then menu_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then role_code
													 when 2 then role_name
													 when 3 then ssm.module_name
													 when 4 then submenu_name
													 when 5 then menu_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
