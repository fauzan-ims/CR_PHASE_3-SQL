CREATE PROCEDURE [dbo].[xsp_sale_attachement_group_getrows]
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_sale_code		nvarchar(50)
	,@p_asset_code		NVARCHAR(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.sale_attachement_group sag
			left join dbo.sys_general_document sgd on (sgd.code = sag.document_code)
	where	sag.sale_code = @p_sale_code
	AND			sag.ASSET_CODE = @p_asset_code
	and		(
				sgd.document_name									like '%' + @p_keywords + '%'
				or	file_name										like '%' + @p_keywords + '%'
				or	sag.file_path									like '%' + @p_keywords + '%'
			) ;

	select		id
				,sgd.document_name 'description_code'
				,file_name
				,sag.file_path 'path'
				,sag.value
				,case when 
						sag.is_required = '1' then '*'
						else ''
				end 'is_required'
				,@rows_count 'rowcount'
	from		dbo.sale_attachement_group sag
				left join dbo.sys_general_document sgd on (sgd.code = sag.document_code)
	where		sag.sale_code = @p_sale_code
	AND			sag.ASSET_CODE = @p_asset_code
	and			(
					sgd.document_name									like '%' + @p_keywords + '%'
					or	file_name										like '%' + @p_keywords + '%'
					or	sag.file_path									like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then sgd.document_name
													 when 2 then file_name
													 when 3 then sag.file_path
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then sgd.document_name
													 when 2 then file_name
													 when 3 then sag.file_path
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
