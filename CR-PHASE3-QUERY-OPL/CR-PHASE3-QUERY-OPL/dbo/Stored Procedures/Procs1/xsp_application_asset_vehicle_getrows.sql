CREATE PROCEDURE dbo.xsp_application_asset_vehicle_getrows
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
	from	application_asset_vehicle
	where	(
				asset_no						like '%' + @p_keywords + '%'
				or	vehicle_category_code		like '%' + @p_keywords + '%'
				or	vehicle_subcategory_code	like '%' + @p_keywords + '%'
				or	vehicle_merk_code			like '%' + @p_keywords + '%'
				or	vehicle_model_code			like '%' + @p_keywords + '%'
				or	vehicle_type_code			like '%' + @p_keywords + '%'
				or	vehicle_unit_code			like '%' + @p_keywords + '%' 
				or	colour						like '%' + @p_keywords + '%' 
				or	transmisi					like '%' + @p_keywords + '%'
				or	remarks						like '%' + @p_keywords + '%'
			) ;
		select		asset_no
					,vehicle_category_code
					,vehicle_subcategory_code
					,vehicle_merk_code
					,vehicle_model_code
					,vehicle_type_code
					,vehicle_unit_code 
					,colour 
					,transmisi
					,remarks
					,@rows_count 'rowcount'
		from		application_asset_vehicle
		where		(
						asset_no						like '%' + @p_keywords + '%'
						or	vehicle_category_code		like '%' + @p_keywords + '%'
						or	vehicle_subcategory_code	like '%' + @p_keywords + '%'
						or	vehicle_merk_code			like '%' + @p_keywords + '%'
						or	vehicle_model_code			like '%' + @p_keywords + '%'
						or	vehicle_type_code			like '%' + @p_keywords + '%'
						or	vehicle_unit_code			like '%' + @p_keywords + '%' 
						or	colour						like '%' + @p_keywords + '%' 
						or	transmisi					like '%' + @p_keywords + '%'
						or	remarks						like '%' + @p_keywords + '%'
					)
	
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then asset_no
													when 2 then vehicle_category_code
													when 3 then vehicle_subcategory_code
													when 4 then vehicle_merk_code
													when 5 then vehicle_model_code
													when 6 then vehicle_type_code
													when 7 then vehicle_unit_code 
													when 8 then colour 
													when 9 then transmisi
													when 10 then remarks
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then asset_no
													when 2 then vehicle_category_code
													when 3 then vehicle_subcategory_code
													when 4 then vehicle_merk_code
													when 5 then vehicle_model_code
													when 6 then vehicle_type_code
													when 7 then vehicle_unit_code 
													when 8 then colour 
													when 9 then transmisi
													when 10 then remarks
												 end
											
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

