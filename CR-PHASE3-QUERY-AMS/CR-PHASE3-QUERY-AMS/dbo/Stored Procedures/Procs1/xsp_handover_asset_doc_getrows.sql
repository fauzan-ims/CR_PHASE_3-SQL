CREATE PROCEDURE dbo.xsp_handover_asset_doc_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_handover_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	handover_asset_doc had
			left join dbo.sys_document_group_detail sdg on (had.document_code = sdg.DOCUMENT_CODE)
			left join dbo.sys_general_document sgd on (sdg.document_code = sgd.code)
	where	handover_code = @p_handover_code
	and		(
				sgd.document_name like '%' + @p_keywords + '%'
				or	had.file_name like '%' + @p_keywords + '%'
				or	had.file_path like '%' + @p_keywords + '%'
			) ;

	select		had.id
				,had.handover_code
				,sdg.document_code
				,sgd.document_name
				,had.file_name
				,had.file_path
				,@rows_count 'rowcount'
	from		handover_asset_doc had
				left join dbo.sys_document_group_detail sdg on (had.document_code = sdg.DOCUMENT_CODE)
				left join dbo.sys_general_document sgd on (sdg.document_code = sgd.code)
	where		handover_code = @p_handover_code
	and			(
					sgd.document_name like '%' + @p_keywords + '%'
					or	had.file_name like '%' + @p_keywords + '%'
					or	had.file_path like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then sgd.document_name
													 when 2 then had.file_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													  when 1 then sgd.document_name
													  when 2 then had.file_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
