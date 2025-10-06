CREATE PROCEDURE dbo.XSP_DOCUMENT_DETAIL_GETROWS
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_code	   nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	document_detail
	where	document_code = @p_code
			and is_manual = 0
			and(
				id							like '%' + @p_keywords + '%'
				or	document_code			like '%' + @p_keywords + '%'
				or	document_name			like '%' + @p_keywords + '%'
				or	document_description	like '%' + @p_keywords + '%'
				or	doc_no					like '%' + @p_keywords + '%'
				or	doc_name				like '%' + @p_keywords + '%'
				or	file_name				like '%' + @p_keywords + '%'
				or	paths					like '%' + @p_keywords + '%'
				or	expired_date			like '%' + @p_keywords + '%'
			) ;

	select		id
				,document_code
				,document_name
				,document_description
				,upper(file_name) 'file_name'
				,paths
				,convert(varchar(30), expired_date, 103) 'expired_date'
				,paths
				,case when expired_date <= getdate() then '1' else '0' end 'is_expired_date'
				,doc_no
				,doc_name
				,@rows_count 'rowcount'
	from		document_detail
	where		document_code = @p_code
				and is_manual = 0
				and(
					id							like '%' + @p_keywords + '%'
					or	document_code			like '%' + @p_keywords + '%'
					or	document_name			like '%' + @p_keywords + '%'
					or	document_description	like '%' + @p_keywords + '%'
					or	doc_no					like '%' + @p_keywords + '%'
					or	doc_name				like '%' + @p_keywords + '%'
					or	file_name				like '%' + @p_keywords + '%'
					or	paths					like '%' + @p_keywords + '%'
					or	expired_date			like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then document_code
													 when 2 then document_name
													 when 3 then document_description
													 when 4 then doc_no
													 when 5 then doc_name
													 when 6 then file_name
													 when 7 then paths
												 end
				end asc 
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then document_code
													   when 2 then document_name
													   when 3 then document_description
													   when 4 then doc_no
													   when 5 then doc_name
													   when 6 then file_name
													   when 7 then paths
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
