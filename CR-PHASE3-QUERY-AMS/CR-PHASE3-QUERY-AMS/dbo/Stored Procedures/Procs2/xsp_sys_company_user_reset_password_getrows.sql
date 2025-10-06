
create procedure xsp_sys_company_user_reset_password_getrows
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
	from	sys_company_user_reset_password
	where	(
				code				like '%' + @p_keywords + '%'
				or	request_date	like '%' + @p_keywords + '%'
				or	user_code		like '%' + @p_keywords + '%'
				or	password_type	like '%' + @p_keywords + '%'
				or	new_password	like '%' + @p_keywords + '%'
				or	remarks			like '%' + @p_keywords + '%'
				or	status			like '%' + @p_keywords + '%'
			) ;

	select		code
				,request_date
				,user_code
				,password_type
				,new_password
				,remarks
				,status
				,@rows_count 'rowcount'
	from		sys_company_user_reset_password
	where		(
					code				like '%' + @p_keywords + '%'
					or	request_date	like '%' + @p_keywords + '%'
					or	user_code		like '%' + @p_keywords + '%'
					or	password_type	like '%' + @p_keywords + '%'
					or	new_password	like '%' + @p_keywords + '%'
					or	remarks			like '%' + @p_keywords + '%'
					or	status			like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
					 									when 1 then code
														when 2 then user_code
														when 3 then password_type
														when 4 then new_password
														when 5 then remarks
														when 6 then status
					 								end
				end asc
				,case
					 	when @p_sort_by = 'desc' then case @p_order_by							
					 									when 1 then code
														when 2 then user_code
														when 3 then password_type
														when 4 then new_password
														when 5 then remarks
														when 6 then status
					 								end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;

end ;
