
create procedure xsp_sys_company_user_history_password_getrows
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
	from	sys_company_user_history_password
	where	(
				running_number			like '%' + @p_keywords + '%'
				or	user_code			like '%' + @p_keywords + '%'
				or	password_type		like '%' + @p_keywords + '%'
				or	date_change_pass	like '%' + @p_keywords + '%'
				or	oldpass				like '%' + @p_keywords + '%'
				or	newpass				like '%' + @p_keywords + '%'
			) ;

	select		running_number
				,user_code
				,password_type
				,date_change_pass
				,oldpass
				,newpass
				,@rows_count 'rowcount'
	from		sys_company_user_history_password
	where		(
					running_number			like '%' + @p_keywords + '%'
					or	user_code			like '%' + @p_keywords + '%'
					or	password_type		like '%' + @p_keywords + '%'
					or	date_change_pass	like '%' + @p_keywords + '%'
					or	oldpass				like '%' + @p_keywords + '%'
					or	newpass				like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
					 									when 1 then user_code
														when 2 then password_type
														when 3 then oldpass
														when 4 then newpass
					 								end
				end asc
				,case
					when @p_sort_by = 'desc' then case @p_order_by							
					 									when 1 then user_code
														when 2 then password_type
														when 3 then oldpass
														when 4 then newpass
					 								end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
		
end ;
