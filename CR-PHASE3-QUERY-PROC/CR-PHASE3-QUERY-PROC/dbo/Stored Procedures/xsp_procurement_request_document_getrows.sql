CREATE PROCEDURE dbo.xsp_procurement_request_document_getrows
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
	from	procurement_request_document
	where	procurement_request_code = @p_code
			and (
					procurement_request_code like '%' + @p_keywords + '%'
					or	file_path like '%' + @p_keywords + '%'
					or	file_name like '%' + @p_keywords + '%'
					or	remark like '%' + @p_keywords + '%'
				) ;

	select		id
				,procurement_request_code
				,file_path
				,file_name
				,remark
				,@rows_count 'rowcount'
	from		procurement_request_document
	where		procurement_request_code = @p_code
				and (
						procurement_request_code like '%' + @p_keywords + '%'
						or	file_path like '%' + @p_keywords + '%'
						or	file_name like '%' + @p_keywords + '%'
						or	remark like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then procurement_request_code
													 when 2 then file_name collate Latin1_General_CI_AS
													 when 3 then remark
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then procurement_request_code
													   when 2 then file_name collate Latin1_General_CI_AS
													   when 3 then remark
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
