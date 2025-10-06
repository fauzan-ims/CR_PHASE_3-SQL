CREATE PROCEDURE [dbo].[xsp_asset_document_getrows]
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_asset_code		nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	asset_document ad
			left join dbo.sys_general_document sgd on (sgd.code = ad.document_code)
	where	asset_code = @p_asset_code
	and		(
				asset_code											like '%' + @p_keywords + '%'
				or	document_code									like '%' + @p_keywords + '%'
				or	document_no										like '%' + @p_keywords + '%'
				or	ad.description									like '%' + @p_keywords + '%'
				or	sgd.document_name								like '%' + @p_keywords + '%'
				or	file_name										like '%' + @p_keywords + '%'
				or	ad.file_path									like '%' + @p_keywords + '%'
				or	ad.doc_no										like '%' + @p_keywords + '%'
				or	convert(nvarchar(30), ad.doc_date, 112)			like '%' + @p_keywords + '%'
				or	convert(nvarchar(30), ad.doc_exp_date, 112)		like '%' + @p_keywords + '%'
			) ;

	select		id
				,asset_code
				,document_code
				,document_no
				,ad.description
				,sgd.document_name 'description_code'
				,file_name
				,ad.file_path 'path'
				,ad.doc_no
				,convert(nvarchar(30), ad.doc_date, 112) 'doc_date'
				,convert(nvarchar(30), ad.doc_exp_date, 112) 'doc_exp_date'
				,@rows_count 'rowcount'
	from		asset_document ad
				left join dbo.sys_general_document sgd on (sgd.code = ad.document_code)
	where		asset_code = @p_asset_code
	and			(
					asset_code											like '%' + @p_keywords + '%'
					or	document_code									like '%' + @p_keywords + '%'
					or	document_no										like '%' + @p_keywords + '%'
					or	ad.description									like '%' + @p_keywords + '%'
					or	sgd.document_name								like '%' + @p_keywords + '%'
					or	file_name										like '%' + @p_keywords + '%'
					or	ad.file_path									like '%' + @p_keywords + '%'
					or	ad.doc_no										like '%' + @p_keywords + '%'
					or	convert(nvarchar(30), ad.doc_date, 112)			like '%' + @p_keywords + '%'
					or	convert(nvarchar(30), ad.doc_exp_date, 112)		like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then sgd.document_name
													 when 2 then ad.doc_no
													 when 3 then cast(ad.doc_date as sql_variant)
													 when 4 then file_name
													 when 5 then ad.file_path
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then sgd.document_name
													 when 2 then ad.doc_no
													 when 3 then cast(ad.doc_date as sql_variant)
													 when 4 then file_name
													 when 5 then ad.file_path
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
