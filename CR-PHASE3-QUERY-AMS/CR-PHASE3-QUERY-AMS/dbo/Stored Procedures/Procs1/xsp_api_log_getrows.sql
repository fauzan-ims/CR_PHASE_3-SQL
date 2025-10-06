
create procedure xsp_api_log_getrows
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
	from	api_log
	where	(
				transaction_no like '%' + @p_keywords + '%'
				or	log_date like '%' + @p_keywords + '%'
				or	url_request like '%' + @p_keywords + '%'
				or	json_content like '%' + @p_keywords + '%'
				or	response_code like '%' + @p_keywords + '%'
				or	response_message like '%' + @p_keywords + '%'
				or	response_json like '%' + @p_keywords + '%'
			) ;

	if @p_sort_by = 'asc'
	begin
		select		transaction_no
					,log_date
					,url_request
					,json_content
					,response_code
					,response_message
					,response_json
					,@rows_count 'rowcount'
		from		api_log
		where		(
						transaction_no like '%' + @p_keywords + '%'
						or	log_date like '%' + @p_keywords + '%'
						or	url_request like '%' + @p_keywords + '%'
						or	json_content like '%' + @p_keywords + '%'
						or	response_code like '%' + @p_keywords + '%'
						or	response_message like '%' + @p_keywords + '%'
						or	response_json like '%' + @p_keywords + '%'
					)
		order by	case @p_order_by
						when 1 then transaction_no
						when 2 then url_request
						when 3 then json_content
						when 4 then response_code
						when 5 then response_message
						when 6 then response_json
					end asc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
	else
	begin
		select		transaction_no
					,log_date
					,url_request
					,json_content
					,response_code
					,response_message
					,response_json
					,@rows_count 'rowcount'
		from		api_log
		where		(
						transaction_no like '%' + @p_keywords + '%'
						or	log_date like '%' + @p_keywords + '%'
						or	url_request like '%' + @p_keywords + '%'
						or	json_content like '%' + @p_keywords + '%'
						or	response_code like '%' + @p_keywords + '%'
						or	response_message like '%' + @p_keywords + '%'
						or	response_json like '%' + @p_keywords + '%'
					)
		order by	case @p_order_by
						when 1 then transaction_no
						when 2 then url_request
						when 3 then json_content
						when 4 then response_code
						when 5 then response_message
						when 6 then response_json
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
end ;
