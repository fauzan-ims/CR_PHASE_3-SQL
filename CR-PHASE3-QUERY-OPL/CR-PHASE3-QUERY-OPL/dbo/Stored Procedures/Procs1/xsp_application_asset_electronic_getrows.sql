CREATE PROCEDURE dbo.xsp_application_asset_electronic_getrows
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
	from	application_asset_electronic
	where	(
				asset_no					like '%' + @p_keywords + '%'
				or	electronic_category_code	like '%' + @p_keywords + '%'
				or	electronic_subcategory_code like '%' + @p_keywords + '%'
				or	electronic_merk_code		like '%' + @p_keywords + '%'
				or	electronic_model_code		like '%' + @p_keywords + '%'
				or	electronic_unit_code		like '%' + @p_keywords + '%' 
				or	colour						like '%' + @p_keywords + '%' 
				or	remarks						like '%' + @p_keywords + '%'
			) ;
 
		select		asset_no
					,electronic_category_code
					,electronic_subcategory_code
					,electronic_merk_code
					,electronic_model_code
					,electronic_unit_code 
					,colour 
					,remarks
					,@rows_count 'rowcount'
		from		application_asset_electronic
		where		(
						asset_no					like '%' + @p_keywords + '%'
						or	electronic_category_code	like '%' + @p_keywords + '%'
						or	electronic_subcategory_code like '%' + @p_keywords + '%'
						or	electronic_merk_code		like '%' + @p_keywords + '%'
						or	electronic_model_code		like '%' + @p_keywords + '%'
						or	electronic_unit_code		like '%' + @p_keywords + '%' 
						or	colour						like '%' + @p_keywords + '%' 
						or	remarks						like '%' + @p_keywords + '%'
					) 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then asset_no
													when 2 then electronic_category_code
													when 3 then electronic_subcategory_code
													when 4 then electronic_merk_code
													when 5 then electronic_model_code
													when 6 then electronic_unit_code 
													when 7 then colour 
													when 8 then remarks
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then asset_no
													when 2 then electronic_category_code
													when 3 then electronic_subcategory_code
													when 4 then electronic_merk_code
													when 5 then electronic_model_code
													when 6 then electronic_unit_code 
													when 7 then colour 
													when 8 then remarks
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

