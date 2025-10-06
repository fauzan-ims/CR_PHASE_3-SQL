CREATE PROCEDURE dbo.xsp_master_region_city_getrows
(
	@p_keywords	    nvarchar(50)
	,@p_pagenumber  int
	,@p_rowspage    int
	,@p_order_by    int
	,@p_sort_by	    nvarchar(5)
	,@p_region_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_region_city
	where	region_code = @p_region_code
			and (
					city_code		like '%' + @p_keywords + '%'
					or	city_name	like '%' + @p_keywords + '%'
				) ;

	select		id
				,city_code
				,city_name
				,@rows_count 'rowcount'
	from		master_region_city
	where		region_code = @p_region_code
				and (
						city_code		like '%' + @p_keywords + '%'
						or	city_name	like '%' + @p_keywords + '%'
					)
	order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then city_code
													when 2 then city_name

												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then city_code
													when 2 then city_name

												 end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;



