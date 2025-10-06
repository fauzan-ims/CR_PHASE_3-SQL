CREATE PROCEDURE dbo.xsp_sys_menu_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	sys_menu mm
			left join sys_menu mm2 on (mm.parent_menu_code = mm2.code)
			left join dbo.sys_module sm on (sm.code = mm.module_code)
	where	(
				mm.code							like '%' + @p_keywords + '%'
				or	mm.name						like '%' + @p_keywords + '%'
				or	sm.module_name				like '%' + @p_keywords + '%'
				or	mm.parent_menu_code			like '%' + @p_keywords + '%'
				or	mm.url_menu					like '%' + @p_keywords + '%'
				or	case mm.is_active
						when '1' then 'Yes'
						else 'No'
					end							like '%' + @p_keywords + '%'
				or	mm2.name					like '%' + @p_keywords + '%'
			) ;

	if @p_sort_by = 'asc'
	begin
		select		mm.code
					,mm.name
					,sm.module_name
					,mm.parent_menu_code
					,mm.url_menu
					,mm.order_key
					,case mm.is_active
						 when '1' then 'Yes'
						 else 'No'
					 end as 'is_active'
					,mm2.name as 'parent_name'
					,mm.order_key
					,@rows_count 'rowcount'
		from	sys_menu mm
				left join sys_menu mm2 on (mm.parent_menu_code = mm2.code)
				left join dbo.sys_module sm on (sm.code = mm.module_code)
		where	(
					mm.code							like '%' + @p_keywords + '%'
					or	mm.name						like '%' + @p_keywords + '%'
					or	sm.module_name				like '%' + @p_keywords + '%'
					or	mm.parent_menu_code			like '%' + @p_keywords + '%'
					or	mm.url_menu					like '%' + @p_keywords + '%'
					or	case mm.is_active
							when '1' then 'Yes'
							else 'No'
						end							like '%' + @p_keywords + '%'
					or	mm2.name					like '%' + @p_keywords + '%'
				)
		order by	case @p_order_by
						when 1 then mm.name
						when 2 then sm.module_name
						when 3 then mm2.name
						when 4 then mm.is_active
					end asc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
	else
	begin
		select		mm.code
					,mm.name
					,mm.parent_menu_code
					,mm.url_menu
					,mm.order_key
					,case mm.is_active
						 when '1' then 'Yes'
						 else 'No'
					 end as 'is_active'
					,mm2.name as 'parent_name'
					,mm.order_key
					,@rows_count 'rowcount'
		from		sys_menu mm
					left join sys_menu mm2 on (mm.parent_menu_code = mm2.code)
		where		(
							mm.name						like '%' + @p_keywords + '%'
						or	mm.parent_menu_code			like '%' + @p_keywords + '%'
						or	mm.url_menu					like '%' + @p_keywords + '%'
						or	case mm.is_active
								when '1' then 'Yes'
								else 'No'
							end							like '%' + @p_keywords + '%'
						or	mm2.name					like '%' + @p_keywords + '%'
					)
		order by	case @p_order_by
						when 1 then mm.name
						when 2 then mm2.name
						when 3 then mm.is_active
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
end ;
