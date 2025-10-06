CREATE PROCEDURE dbo.xsp_sys_menu_role_getrows
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
	from	sys_menu_role 
	where	menu_code = @p_menu_code 
	and		(
					role_code			like '%' + @p_keywords + '%'
				or	role_name			like '%' + @p_keywords + '%'
				or	role_access			like '%' + @p_keywords + '%'
			) ;

		select		role_code
					,role_name	
					,case role_access
						 when 'A' then 'ACCESS'
						 when 'C' then 'CREATE/ADD'
						 when 'U' then 'UPDATE'
						 when 'D' then 'DELETE'
						 when 'O' then 'APPROVE'
						 when 'R' then 'REJECT'
					 else 'PRINT'
					 end 'role_access'
					,@rows_count 'rowcount'
		from		sys_menu_role
		where		menu_code = @p_menu_code 
		and			(
							role_code			like '%' + @p_keywords + '%'
						or	role_name			like '%' + @p_keywords + '%'
						or	role_access			like '%' + @p_keywords + '%'
					)

		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then role_code	
													when 2 then role_name	
													when 3 then role_access	
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then role_code	
														when 2 then role_name	
														when 3 then role_access	
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;
