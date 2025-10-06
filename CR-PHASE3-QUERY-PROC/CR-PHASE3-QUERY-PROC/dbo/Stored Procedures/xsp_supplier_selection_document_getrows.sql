CREATE PROCEDURE [dbo].[xsp_supplier_selection_document_getrows]
(
	@p_keywords					nvarchar(50)
	,@p_pagenumber				int
	,@p_rowspage				int
	,@p_order_by				int
	,@p_sort_by					nvarchar(5)
	,@p_supplier_selection_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.supplier_selection_document
	where	supplier_selection_code = @p_supplier_selection_code
			and
			(
				id									like '%' + @p_keywords + '%'
				or	supplier_selection_code			like '%' + @p_keywords + '%'
				or	document_code					like '%' + @p_keywords + '%'
				or	file_path						like '%' + @p_keywords + '%'
				or	file_name						like '%' + @p_keywords + '%'
				or	remark							like '%' + @p_keywords + '%'
			) ;

	select		id
				,supplier_selection_code
				,document_code
				,file_path
				,file_name
				,remark
				,reff_no
				,@rows_count 'rowcount'
	from		dbo.supplier_selection_document
	where		supplier_selection_code = @p_supplier_selection_code
				and
				(
					id									like '%' + @p_keywords + '%'
					or	supplier_selection_code			like '%' + @p_keywords + '%'
					or	document_code					like '%' + @p_keywords + '%'
					or	file_path						like '%' + @p_keywords + '%'
					or	file_name						like '%' + @p_keywords + '%'
					or	remark							like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then supplier_selection_code collate latin1_general_ci_as
													 when 2 then document_code
													 when 3 then file_path
													 when 4 then file_name
													 when 5 then remark
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then supplier_selection_code collate latin1_general_ci_as
													   when 2 then document_code
													   when 3 then file_path
													   when 4 then file_name
													   when 5 then remark
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
