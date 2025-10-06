CREATE procedure dbo.xsp_asset_electronic_upload_getrows
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
	from	asset_electronic_upload
	where	(
				fa_upload_id like '%' + @p_keywords + '%'
				or	file_name like '%' + @p_keywords + '%'
				or	upload_no like '%' + @p_keywords + '%'
				or	asset_code like '%' + @p_keywords + '%'
				or	merk_code like '%' + @p_keywords + '%'
				or	merk_name like '%' + @p_keywords + '%'
				or	type_code like '%' + @p_keywords + '%'
				or	type_name like '%' + @p_keywords + '%'
				or	model_code like '%' + @p_keywords + '%'
				or	model_name like '%' + @p_keywords + '%'
				or	serial_no like '%' + @p_keywords + '%'
				or	dimension like '%' + @p_keywords + '%'
				or	hdd like '%' + @p_keywords + '%'
				or	processor like '%' + @p_keywords + '%'
				or	ram_size like '%' + @p_keywords + '%'
				or	domain like '%' + @p_keywords + '%'
				or	imei like '%' + @p_keywords + '%'
				or	purchase like '%' + @p_keywords + '%'
				or	remark like '%' + @p_keywords + '%'
			) ;

	select		fa_upload_id
				,file_name
				,upload_no
				,asset_code
				,merk_code
				,merk_name
				,type_code
				,type_name
				,model_code
				,model_name
				,serial_no
				,dimension
				,hdd
				,processor
				,ram_size
				,domain
				,imei
				,purchase
				,remark
				,@rows_count 'rowcount'
	from		asset_electronic_upload
	where		(
					fa_upload_id like '%' + @p_keywords + '%'
					or	file_name like '%' + @p_keywords + '%'
					or	upload_no like '%' + @p_keywords + '%'
					or	asset_code like '%' + @p_keywords + '%'
					or	merk_code like '%' + @p_keywords + '%'
					or	merk_name like '%' + @p_keywords + '%'
					or	type_code like '%' + @p_keywords + '%'
					or	type_name like '%' + @p_keywords + '%'
					or	model_code like '%' + @p_keywords + '%'
					or	model_name like '%' + @p_keywords + '%'
					or	serial_no like '%' + @p_keywords + '%'
					or	dimension like '%' + @p_keywords + '%'
					or	hdd like '%' + @p_keywords + '%'
					or	processor like '%' + @p_keywords + '%'
					or	ram_size like '%' + @p_keywords + '%'
					or	domain like '%' + @p_keywords + '%'
					or	imei like '%' + @p_keywords + '%'
					or	purchase like '%' + @p_keywords + '%'
					or	remark like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then file_name
													 when 2 then upload_no
													 when 3 then asset_code
													 when 4 then merk_code
													 when 5 then merk_name
													 when 6 then type_code
													 when 7 then type_name
													 when 8 then model_code
													 when 9 then model_name
													 when 10 then serial_no
													 when 11 then dimension
													 when 12 then hdd
													 when 13 then processor
													 when 14 then ram_size
													 when 15 then domain
													 when 16 then imei
													 when 17 then purchase
													 when 18 then remark
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then file_name
													   when 2 then upload_no
													   when 3 then asset_code
													   when 4 then merk_code
													   when 5 then merk_name
													   when 6 then type_code
													   when 7 then type_name
													   when 8 then model_code
													   when 9 then model_name
													   when 10 then serial_no
													   when 11 then dimension
													   when 12 then hdd
													   when 13 then processor
													   when 14 then ram_size
													   when 15 then domain
													   when 16 then imei
													   when 17 then purchase
													   when 18 then remark
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
