CREATE procedure dbo.xsp_asset_vehicle_upload_getrows
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
	from	asset_vehicle_upload
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
				or	plat_no like '%' + @p_keywords + '%'
				or	chassis_no like '%' + @p_keywords + '%'
				or	engine_no like '%' + @p_keywords + '%'
				or	bpkb_no like '%' + @p_keywords + '%'
				or	colour like '%' + @p_keywords + '%'
				or	cylinder like '%' + @p_keywords + '%'
				or	stnk_no like '%' + @p_keywords + '%'
				or	stnk_expired_date like '%' + @p_keywords + '%'
				or	stnk_tax_date like '%' + @p_keywords + '%'
				or	stnk_renewal like '%' + @p_keywords + '%'
				or	built_year like '%' + @p_keywords + '%'
				or	last_miles like '%' + @p_keywords + '%'
				or	last_maintenance_date like '%' + @p_keywords + '%'
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
				,plat_no
				,chassis_no
				,engine_no
				,bpkb_no
				,colour
				,cylinder
				,stnk_no
				,stnk_expired_date
				,stnk_tax_date
				,stnk_renewal
				,built_year
				,last_miles
				,last_maintenance_date
				,purchase
				,remark
				,@rows_count 'rowcount'
	from		asset_vehicle_upload
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
					or	plat_no like '%' + @p_keywords + '%'
					or	chassis_no like '%' + @p_keywords + '%'
					or	engine_no like '%' + @p_keywords + '%'
					or	bpkb_no like '%' + @p_keywords + '%'
					or	colour like '%' + @p_keywords + '%'
					or	cylinder like '%' + @p_keywords + '%'
					or	stnk_no like '%' + @p_keywords + '%'
					or	stnk_expired_date like '%' + @p_keywords + '%'
					or	stnk_tax_date like '%' + @p_keywords + '%'
					or	stnk_renewal like '%' + @p_keywords + '%'
					or	built_year like '%' + @p_keywords + '%'
					or	last_miles like '%' + @p_keywords + '%'
					or	last_maintenance_date like '%' + @p_keywords + '%'
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
													 when 9 then plat_no
													 when 10 then chassis_no
													 when 11 then engine_no
													 when 12 then bpkb_no
													 when 13 then colour
													 when 14 then cylinder
													 when 15 then stnk_no
													 when 16 then stnk_renewal
													 when 17 then built_year
													 when 18 then last_miles
													 when 19 then purchase
													 when 20 then remark
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
													   when 9 then plat_no
													   when 10 then chassis_no
													   when 11 then engine_no
													   when 12 then bpkb_no
													   when 13 then colour
													   when 14 then cylinder
													   when 15 then stnk_no
													   when 16 then stnk_renewal
													   when 17 then built_year
													   when 18 then last_miles
													   when 19 then purchase
													   when 20 then remark
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
