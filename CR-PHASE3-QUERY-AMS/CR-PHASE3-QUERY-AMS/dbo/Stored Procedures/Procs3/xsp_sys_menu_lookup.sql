CREATE PROCEDURE dbo.xsp_sys_menu_lookup
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
	where	mm.is_active = '1'
			and (
					mm.code		like '%' + @p_keywords + '%'
					or	mm.name like '%' + @p_keywords + '%'
				) ;

	if @p_sort_by = 'asc'
	begin
		select		mm.code
					,mm.name
					,@rows_count 'rowcount'
		from		sys_menu mm
		where		mm.is_active = '1'
					and (
							mm.code		like '%' + @p_keywords + '%'
							or	mm.name like '%' + @p_keywords + '%'
						)
		order by	case @p_order_by
						when 1 then mm.code
						when 2 then mm.name
					end asc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
	else
	begin
		select		mm.code
					,mm.name
					,@rows_count 'rowcount'
		from		sys_menu mm
		where		mm.is_active = '1'
					and (
							mm.code		like '%' + @p_keywords + '%'
							or	mm.name like '%' + @p_keywords + '%'
						)
		order by	case @p_order_by
						when 1 then mm.code
						when 2 then mm.name
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
end ;
