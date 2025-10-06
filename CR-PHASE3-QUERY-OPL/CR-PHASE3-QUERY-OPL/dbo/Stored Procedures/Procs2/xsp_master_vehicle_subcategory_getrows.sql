---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE dbo.xsp_master_vehicle_subcategory_getrows
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
	from	master_vehicle_subcategory mfs
			inner join dbo.master_vehicle_category mfc on (mfc.code = mfs.vehicle_category_code)
	where	(
				mfs.code						like '%' + @p_keywords + '%'
				or	mfs.description				like '%' + @p_keywords + '%'
				or	mfc.description				like '%' + @p_keywords + '%'
				or	case mfs.is_active
						when '1' then 'Yes'
						else 'No'
					end							like '%' + @p_keywords + '%'
			) ;

		select		mfs.code
					,mfs.description
					,mfc.description 'vehicle_category_desc'
					,case mfs.is_active
						 when '1' then 'Yes'
						 else 'No'
					 end 'is_active'
					,@rows_count 'rowcount'
		from	master_vehicle_subcategory mfs
				inner join dbo.master_vehicle_category mfc on (mfc.code = mfs.vehicle_category_code)
		where	(
					mfs.code						like '%' + @p_keywords + '%'
					or	mfs.description				like '%' + @p_keywords + '%'
					or	mfc.description				like '%' + @p_keywords + '%'
					or	case mfs.is_active
							when '1' then 'Yes'
							else 'No'
						end							like '%' + @p_keywords + '%'
				)

	order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then mfs.code
													when 2 then mfs.description
													when 3 then mfc.description
													when 4 then mfs.is_active
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then mfs.code
														when 2 then mfs.description
														when 3 then mfc.description
														when 4 then mfs.is_active
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;


