CREATE PROCEDURE dbo.xsp_sys_role_sec_getrows
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
	from	sys_role_sec
	where	(
				code			like '%' + @p_keywords + '%'
				or	name		like '%' + @p_keywords + '%'
				or	access_type like '%' + @p_keywords + '%'
			) ;

		select		code
					,name
					,case access_type
						 when 'A' then 'ACCESS'
						 when 'C' then 'CREATE/ADD'
						 when 'U' then 'UPDATE'
						 when 'D' then 'DELETE'
						 when 'O' then 'APPROVE'
						 when 'R' then 'REJECT'
					 else 'PRINT'
					 end 'access_type'
					,@rows_count 'rowcount'
		from		sys_role_sec
		where		(
						code			like '%' + @p_keywords + '%'
						or	name		like '%' + @p_keywords + '%'
						or	access_type like '%' + @p_keywords + '%'
					)

		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then code
													when 2 then name
													when 3 then access_type
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then code
														when 2 then name
														when 3 then access_type
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;
