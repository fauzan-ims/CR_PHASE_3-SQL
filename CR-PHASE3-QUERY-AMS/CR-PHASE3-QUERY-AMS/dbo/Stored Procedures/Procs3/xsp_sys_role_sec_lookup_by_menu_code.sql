CREATE PROCEDURE dbo.xsp_sys_role_sec_lookup_by_menu_code
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_menu_code  nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	sys_role_sec
	where	code not in
			(
				select	role_sec_code
				from	dbo.sys_menu_role
				where	role_sec_code = code
						and menu_code = @p_menu_code
			)
			and (
					code			like '%' + @p_keywords + '%'
					or	name		like '%' + @p_keywords + '%'
					or	access_type like '%' + @p_keywords + '%'
				) ;


	select		code
				,name
				,access_type
				,@rows_count 'rowcount'
	from		sys_role_sec
	where		code not in
				(
					select	role_sec_code
					from	dbo.sys_menu_role
					where	role_sec_code = code
							and menu_code = @p_menu_code
				)
	and		(
				code			like '%' + @p_keywords + '%'
				or	name		like '%' + @p_keywords + '%'
				or	access_type like '%' + @p_keywords + '%'
			)
	order by	case
			 		when @p_sort_by = 'asc' then case @p_order_by		
														when 1 then code
														when 2 then name
														when 3 then access_type
			 										end
			 	end asc
			 	,case
			 		when @p_sort_by = 'desc' then case @p_order_by			
														when 1 then code
														when 2 then name
														when 3 then access_type
			 										end
			 	end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	
end ;
