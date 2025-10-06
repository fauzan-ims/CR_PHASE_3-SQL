CREATE PROCEDURE dbo.xsp_asset_he_getrows
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
	from	asset_he
	where	(
				asset_code like '%' + @p_keywords + '%'
				or	merk_code like '%' + @p_keywords + '%'
				or	merk_name like '%' + @p_keywords + '%'
				or	type_item_code like '%' + @p_keywords + '%'
				or	type_item_name like '%' + @p_keywords + '%'
				or	model_code like '%' + @p_keywords + '%'
				or	built_year like '%' + @p_keywords + '%'
				or	invoice_no like '%' + @p_keywords + '%'
				or	chassis_no like '%' + @p_keywords + '%'
				or	engine_no like '%' + @p_keywords + '%'
				or	colour like '%' + @p_keywords + '%'
				or	serial_no like '%' + @p_keywords + '%'
				or	remark like '%' + @p_keywords + '%'
				or	model_name like '%' + @p_keywords + '%'
			) ;

	select		asset_code
				,merk_code
				,merk_name
				,type_item_code
				,type_item_name
				,model_code
				,built_year
				,invoice_no
				,chassis_no
				,engine_no
				,colour
				,serial_no
				,remark
				,model_name
				,@rows_count 'rowcount'
	from		asset_he
	where		(
					asset_code like '%' + @p_keywords + '%'
					or	merk_code like '%' + @p_keywords + '%'
					or	merk_name like '%' + @p_keywords + '%'
					or	type_item_code like '%' + @p_keywords + '%'
					or	type_item_name like '%' + @p_keywords + '%'
					or	model_code like '%' + @p_keywords + '%'
					or	built_year like '%' + @p_keywords + '%'
					or	invoice_no like '%' + @p_keywords + '%'
					or	chassis_no like '%' + @p_keywords + '%'
					or	engine_no like '%' + @p_keywords + '%'
					or	colour like '%' + @p_keywords + '%'
					or	serial_no like '%' + @p_keywords + '%'
					or	remark like '%' + @p_keywords + '%'
					or	model_name like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then asset_code
													 when 2 then merk_code
													 when 3 then merk_name
													 when 4 then type_item_code
													 when 5 then type_item_name
													 when 6 then model_code
													 when 7 then built_year
													 when 8 then invoice_no
													 when 9 then chassis_no
													 when 10 then engine_no
													 when 11 then colour
													 when 12 then serial_no
													 when 13 then remark
													 when 14 then model_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then asset_code
													 when 2 then merk_code
													 when 3 then merk_name
													 when 4 then type_item_code
													 when 5 then type_item_name
													 when 6 then model_code
													 when 7 then built_year
													 when 8 then invoice_no
													 when 9 then chassis_no
													 when 10 then engine_no
													 when 11 then colour
													 when 12 then serial_no
													 when 13 then remark
													 when 14 then model_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
