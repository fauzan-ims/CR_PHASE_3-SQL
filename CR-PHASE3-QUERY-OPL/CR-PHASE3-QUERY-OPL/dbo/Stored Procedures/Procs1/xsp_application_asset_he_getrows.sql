CREATE PROCEDURE dbo.xsp_application_asset_he_getrows
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
	from	application_asset_he
	where	(
				asset_no					like '%' + @p_keywords + '%'
				or	he_category_code		like '%' + @p_keywords + '%'
				or	he_subcategory_code		like '%' + @p_keywords + '%'
				or	he_merk_code			like '%' + @p_keywords + '%'
				or	he_model_code			like '%' + @p_keywords + '%'
				or	he_type_code			like '%' + @p_keywords + '%'
				or	he_unit_code			like '%' + @p_keywords + '%'  
				or	remarks					like '%' + @p_keywords + '%'
			) ; 
		select		asset_no
					,he_category_code
					,he_subcategory_code
					,he_merk_code
					,he_model_code
					,he_type_code
					,he_unit_code  
					,remarks
					,@rows_count 'rowcount'
		from		application_asset_he
		where		(
						asset_no					like '%' + @p_keywords + '%'
						or	he_category_code		like '%' + @p_keywords + '%'
						or	he_subcategory_code		like '%' + @p_keywords + '%'
						or	he_merk_code			like '%' + @p_keywords + '%'
						or	he_model_code			like '%' + @p_keywords + '%'
						or	he_type_code			like '%' + @p_keywords + '%'
						or	he_unit_code			like '%' + @p_keywords + '%' 
						or	remarks					like '%' + @p_keywords + '%'
					) 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then asset_no
													when 2 then he_category_code
													when 3 then he_subcategory_code
													when 4 then he_merk_code
													when 5 then he_model_code
													when 6 then he_type_code
													when 7 then he_unit_code 
													when 19 then remarks
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then asset_no
													when 2 then he_category_code
													when 3 then he_subcategory_code
													when 4 then he_merk_code
													when 5 then he_model_code
													when 6 then he_type_code
													when 7 then he_unit_code 
													when 19 then remarks
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

