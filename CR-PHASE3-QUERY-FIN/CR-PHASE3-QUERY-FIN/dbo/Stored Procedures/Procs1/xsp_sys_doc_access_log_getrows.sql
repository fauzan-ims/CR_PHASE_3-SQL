CREATE PROCEDURE [dbo].[xsp_sys_doc_access_log_getrows]
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
	from	sys_doc_access_log
	where	(
				id												like '%' + @p_keywords + '%'
				or	module_name									like '%' + @p_keywords + '%'
				or	transaction_name							like '%' + @p_keywords + '%'
				or	transaction_no								like '%' + @p_keywords + '%'
				or	convert(varchar(30), access_date, 103)		like '%' + @p_keywords + '%'
				or	acess_type									like '%' + @p_keywords + '%'
				or	file_name									like '%' + @p_keywords + '%'
				or	print_by_code								like '%' + @p_keywords + '%'
				or	print_by_name								like '%' + @p_keywords + '%'
				or	print_by_ip									like '%' + @p_keywords + '%'
			) ;

	select		id
				,module_name
				,transaction_name
				,transaction_no
				,convert(varchar(30), access_date, 103) 'access_date'
				,acess_type
				,file_name
				,print_by_code
				,print_by_name
				,print_by_ip
				,@rows_count 'rowcount'
	from		sys_doc_access_log
	where		(
					id												like '%' + @p_keywords + '%'
					or	module_name									like '%' + @p_keywords + '%'
					or	transaction_name							like '%' + @p_keywords + '%'
					or	transaction_no								like '%' + @p_keywords + '%'
					or	convert(varchar(30), access_date, 103)		like '%' + @p_keywords + '%'
					or	acess_type									like '%' + @p_keywords + '%'
					or	file_name									like '%' + @p_keywords + '%'
					or	print_by_code								like '%' + @p_keywords + '%'
					or	print_by_name								like '%' + @p_keywords + '%'
					or	print_by_ip									like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then module_name
														when 2 then transaction_name + transaction_no
														when 3 then cast(access_date as sql_variant)
														when 4 then acess_type
														when 5 then print_by_code + print_by_name + print_by_ip
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then module_name
														when 2 then transaction_name + transaction_no
														when 3 then cast(access_date as sql_variant)
														when 4 then acess_type
														when 5 then print_by_code + print_by_name + print_by_ip
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;  
end ;
