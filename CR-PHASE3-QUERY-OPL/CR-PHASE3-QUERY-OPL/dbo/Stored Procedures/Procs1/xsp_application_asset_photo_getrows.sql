CREATE PROCEDURE dbo.xsp_application_asset_photo_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_asset_no   nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	application_asset_photo
	where	asset_no = @p_asset_no
			and (
					remarks			like '%' + @p_keywords + '%'
					or	geo_address like '%' + @p_keywords + '%'
					or	file_name	like '%' + @p_keywords + '%'
				) ;
				 
		select		id
					,remarks
					,geo_address
					,file_name
					,paths
					,@rows_count 'rowcount'
		from		application_asset_photo
		where		asset_no = @p_asset_no
					and (
							remarks			like '%' + @p_keywords + '%'
							or	geo_address like '%' + @p_keywords + '%'
							or	file_name	like '%' + @p_keywords + '%'
						) 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then remarks
													when 2 then geo_address
													when 3 then file_name
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then remarks
													when 2 then geo_address
													when 3 then file_name
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

