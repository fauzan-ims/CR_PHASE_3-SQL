CREATE procedure dbo.xsp_asset_machine_upload_getrows
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
	from	asset_machine_upload
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
				or	built_year like '%' + @p_keywords + '%'
				or	chassis_no like '%' + @p_keywords + '%'
				or	engine_no like '%' + @p_keywords + '%'
				or	colour like '%' + @p_keywords + '%'
				or	serial_no like '%' + @p_keywords + '%'
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
				,built_year
				,chassis_no
				,engine_no
				,colour
				,serial_no
				,purchase
				,remark
				,@rows_count 'rowcount'
	from		asset_machine_upload
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
					or	built_year like '%' + @p_keywords + '%'
					or	chassis_no like '%' + @p_keywords + '%'
					or	engine_no like '%' + @p_keywords + '%'
					or	colour like '%' + @p_keywords + '%'
					or	serial_no like '%' + @p_keywords + '%'
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
													 when 9 then built_year
													 when 10 then chassis_no
													 when 11 then engine_no
													 when 12 then colour
													 when 13 then serial_no
													 when 14 then purchase
													 when 15 then remark
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
													   when 9 then built_year
													   when 10 then chassis_no
													   when 11 then engine_no
													   when 12 then colour
													   when 13 then serial_no
													   when 14 then purchase
													   when 15 then remark
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
