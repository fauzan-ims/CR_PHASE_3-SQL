CREATE procedure dbo.xsp_sys_role_group_lookup_for_user_main_group_sec_getrows
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
	from	sys_role_group
	where	code not in
			(
				select	role_group_code
				from	dbo.sys_user_main_group_sec
				where	role_group_code = code
						and user_code	= @p_ucode
			)
			and (
					code					like '%' + @p_keywords + '%'
					or	name				like '%' + @p_keywords + '%'
					or	application_code	like '%' + @p_keywords + '%'
				) ;

	select		code
				,name
				,application_code
				,@rows_count as 'rowcount'
	from		sys_role_group
	where		code not in
				(
					select	role_group_code
					from	dbo.sys_user_main_group_sec
					where	role_group_code = code
							and user_code	= @p_ucode
				)
				and (
						code					like '%' + @p_keywords + '%'
						or	name				like '%' + @p_keywords + '%'
						or	application_code	like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then code
													 when 2 then name
													 when 3 then application_code
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then code
													   when 2 then name
													   when 3 then application_code
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
