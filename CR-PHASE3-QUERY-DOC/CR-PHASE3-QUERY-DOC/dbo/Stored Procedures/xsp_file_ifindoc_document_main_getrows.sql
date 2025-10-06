CREATE PROCEDURE dbo.xsp_file_ifindoc_document_main_getrows
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
	from	dbo.file_ifindoc_document_main	
	where	
		(
					module			like '%' + @p_keywords + '%'
				or	doc_type		like '%' + @p_keywords + '%'
				or	doc_no 			like '%' + @p_keywords + '%'
				or	doc_name		like '%' + @p_keywords + '%'
				or	doc_file		like '%' + @p_keywords + '%'
				or	convert(varchar(30), doc_date, 103)	like '%' + @p_keywords + '%' 
			) ;

	select		module	
				,doc_type
				,doc_no 
				,doc_name
				,doc_file
				,convert(varchar(30), doc_date,103) 'doc_date'
				,@rows_count 'rowcount'
	from		dbo.file_ifindoc_document_main	
	where		
				(
					module				like '%' + @p_keywords + '%'
					or	doc_type		like '%' + @p_keywords + '%'
					or	doc_no 			like '%' + @p_keywords + '%'
					or	doc_name		like '%' + @p_keywords + '%'
					or	doc_file		like '%' + @p_keywords + '%'
					or	convert(varchar(30), doc_date, 103)	like '%' + @p_keywords + '%' 
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then module	
													 when 2 then doc_type
													 when 3 then doc_no 	
													 when 4 then doc_name
													 when 5 then cast(doc_date as sql_variant)
												 end
				end asc 
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then module	
													 when 2 then doc_type
													 when 3 then doc_no 	
													 when 4 then doc_name
													 when 5 then cast(doc_date as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
