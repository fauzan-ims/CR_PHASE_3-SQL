CREATE PROCEDURE dbo.xsp_sys_menu_role_lookup_by_uid
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_ucode	   nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.sys_menu_role smr
			inner join dbo.sys_menu sm on sm.code = smr.menu_code
			inner join dbo.sys_module smd on smd.code = sm.module_code
	where	role_code not in
			(
				select	role_code
				from	dbo.sys_user_main_role_sec
				where	role_code = role_code
						and user_code = @p_ucode
			)
			and (
					role_code			like '%' + @p_keywords + '%'
					or	role_name		like '%' + @p_keywords + '%'
					or	name			like '%' + @p_keywords + '%'
					or	module_name		like '%' + @p_keywords + '%'
				) ;

	select	role_code
			,role_name
			,sm.name 'menu_name'
			,smd.module_name
			,@rows_count 'rowcount'
	from	sys_menu_role smr
			inner join dbo.sys_menu sm on sm.code = smr.menu_code
			inner join dbo.sys_module smd on smd.code = sm.module_code
	where	role_code not in
			(
				select	role_code
				from	dbo.sys_user_main_role_sec
				where	role_code = role_code
						and user_code = @p_ucode
			)
	and		(
				role_code			like '%' + @p_keywords + '%'
				or	role_name		like '%' + @p_keywords + '%'
				or	name			like '%' + @p_keywords + '%'
				or	module_name		like '%' + @p_keywords + '%'
			)
	order by	case
				 	when @p_sort_by = 'asc' then case @p_order_by
				 										when 1 then role_code
														when 2 then role_name
														when 3 then sm.name
				 									end
				end asc
				,case
				 	when @p_sort_by = 'desc' then case @p_order_by		
				 										when 1 then role_code
														when 2 then role_name
														when 3 then sm.name
				 									end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	
end ;
