CREATE PROCEDURE dbo.xsp_quotation_review_document_getrows
(
	 @p_keywords				nvarchar(50)
	,@p_pagenumber				int
	,@p_rowspage				int
	,@p_order_by				int
	,@p_sort_by					nvarchar(5)
	,@p_quotation_review_code   nvarchar(50)
)
as
begin
	declare 	@rows_count int = 0 ;

	select 	@rows_count = count(1)
	from	quotation_review_document
	where	quotation_review_code = @p_quotation_review_code
			and (
						id						like 	'%'+@p_keywords+'%'
					or	quotation_review_code	like 	'%'+@p_keywords+'%'
					or	document_code			like 	'%'+@p_keywords+'%'
					or	file_path				like 	'%'+@p_keywords+'%'
					or	file_name				like 	'%'+@p_keywords+'%'
					or	remark					like 	'%'+@p_keywords+'%'
			);

	select	 id
			,quotation_review_code
			,document_code
			,file_path
			,file_name
			,remark
			,@rows_count	 'rowcount'
	from	quotation_review_document
	where	quotation_review_code = @p_quotation_review_code
			and (
						id						like 	'%'+@p_keywords+'%'
					or	quotation_review_code	like 	'%'+@p_keywords+'%'
					or	document_code			like 	'%'+@p_keywords+'%'
					or	file_path				like 	'%'+@p_keywords+'%'
					or	file_name				like 	'%'+@p_keywords+'%'
					or	remark					like 	'%'+@p_keywords+'%'
			)
		order by	case
						when @p_sort_by = 'asc' then case @p_order_by
							when 1	then quotation_review_code collate latin1_general_ci_as
							when 2	then document_code
							when 3	then file_path
							when 4	then file_name
							when 5	then remark
						end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
						when 1	then quotation_review_code collate latin1_general_ci_as
						when 2	then document_code
						when 3	then file_path
						when 4	then file_name
						when 5	then remark
					 end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
