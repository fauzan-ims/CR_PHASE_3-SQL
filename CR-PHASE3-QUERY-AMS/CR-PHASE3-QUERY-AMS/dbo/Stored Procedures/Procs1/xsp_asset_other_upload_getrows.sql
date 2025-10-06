CREATE procedure dbo.xsp_asset_other_upload_getrows
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
	from	asset_other_upload
	where	(
				fa_upload_id like '%' + @p_keywords + '%'
				or	file_name like '%' + @p_keywords + '%'
				or	upload_no like '%' + @p_keywords + '%'
				or	asset_code like '%' + @p_keywords + '%'
				or	remark like '%' + @p_keywords + '%'
			) ;

	select		fa_upload_id
				,file_name
				,upload_no
				,asset_code
				,remark
				,@rows_count 'rowcount'
	from		asset_other_upload
	where		(
					fa_upload_id like '%' + @p_keywords + '%'
					or	file_name like '%' + @p_keywords + '%'
					or	upload_no like '%' + @p_keywords + '%'
					or	asset_code like '%' + @p_keywords + '%'
					or	remark like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then file_name
													 when 2 then upload_no
													 when 3 then asset_code
													 when 4 then remark
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then file_name
													   when 2 then upload_no
													   when 3 then asset_code
													   when 4 then remark
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
