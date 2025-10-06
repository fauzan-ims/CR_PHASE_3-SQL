CREATE PROCEDURE dbo.xsp_sys_menu_lookup_for_parent
(
	@p_keywords	    nvarchar(50)
	,@p_pagenumber  int
	,@p_rowspage    int
	,@p_order_by    int
	,@p_sort_by	    nvarchar(5)
	,@p_module_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	sys_menu
	where	is_active = '1'
			and module_code = @p_module_code
			and type = 'sub'
			and (
					code	like '%' + @p_keywords + '%'
					or		name like '%' + @p_keywords + '%'
				) ;

	select		code
				,name
				,@rows_count 'rowcount'
	from		sys_menu
	where		is_active = '1'
				and module_code = @p_module_code
				and type = 'sub'
				and (
						code		like '%' + @p_keywords + '%'
						or	name	like '%' + @p_keywords + '%'
					)
	order by case		
				when @p_sort_by = 'asc' then case @p_order_by
												when 1 then code
												when 2 then name
												end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then code
														when 2 then name
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
