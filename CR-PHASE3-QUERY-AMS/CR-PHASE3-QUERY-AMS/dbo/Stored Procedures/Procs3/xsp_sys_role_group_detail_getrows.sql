CREATE PROCEDURE dbo.xsp_sys_role_group_detail_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	--
	,@p_code				nvarchar(50) = ''
	,@p_module_code			nvarchar(50) = ''
	,@p_parent_menu_code	nvarchar(50) = ''
	,@p_role_group_code		nvarchar(100) 
	,@p_role_access			nvarchar(1)
)
as
begin
	declare @rows_count int = 0 ;

	select		@rows_count = count(1)
	from		sys_role_group_detail
	where		role_group_code =  @p_role_group_code 
	--and			menu.code =  case @p_code
	--							when '' then menu.code
	--							else @p_code
	--							end
	--and			menu.parent_menu_code =  case @p_parent_menu_code
	--							when '' then menu.parent_menu_code
	--							else @p_parent_menu_code
	--							end
	--and			menu.module_code =  case @p_module_code
	--							when '' then menu.module_code
	--							else @p_module_code
	--							end 
	and			(
					role_group_code		like '%' + @p_keywords + '%'
					or role_code		like '%' + @p_keywords + '%'
					or role_name		like '%' + @p_keywords + '%'
					or menu_code		like '%' + @p_keywords + '%'
					or menu_name		like '%' + @p_keywords + '%'
					or submenu_code		like '%' + @p_keywords + '%'
					or submenu_name		like '%' + @p_keywords + '%'
				) ;

	select		id 
				,role_group_code
				,role_code
				,role_name
				,menu_code	
				,menu_name 'menu_name'
				,submenu_code
				,submenu_name 'sub_name' 		
				,@rows_count as 'rowcount' 
	from		sys_role_group_detail
	where		role_group_code =  @p_role_group_code 
	--and			menu.code =  case @p_code
	--							when '' then menu.code
	--							else @p_code
	--							end
	--and			menu.parent_menu_code =  case @p_parent_menu_code
	--							when '' then menu.parent_menu_code
	--							else @p_parent_menu_code
	--							end
	--and			menu.module_code =  case @p_module_code
	--							when '' then menu.module_code
	--							else @p_module_code
	--							end 
	and			(
					role_group_code		like '%' + @p_keywords + '%'
					or role_code		like '%' + @p_keywords + '%'
					or role_name		like '%' + @p_keywords + '%'
					or menu_code		like '%' + @p_keywords + '%'
					or menu_name		like '%' + @p_keywords + '%'
					or submenu_code		like '%' + @p_keywords + '%'
					or submenu_name		like '%' + @p_keywords + '%'
				) 
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by	 
														when 1 then role_code 
														when 2 then role_name 
														when 3 then submenu_name 	 
														when 4 then menu_name
						 							end 
				end asc 
				,case
					when @p_sort_by = 'desc' then case @p_order_by		
														when 1 then role_code 
														when 2 then role_name 
														when 3 then submenu_name 	 
														when 4 then menu_name
						 							end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
