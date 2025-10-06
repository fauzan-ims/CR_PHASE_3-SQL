---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE dbo.xsp_master_vehicle_type_getrows
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
	from	master_vehicle_type mmt
			inner join dbo.master_vehicle_model mmm on (mmm.code = mmt.vehicle_model_code)
			inner join dbo.master_vehicle_merk mmr on (mmr.code = mmm.vehicle_merk_code)
			inner join dbo.master_vehicle_subcategory mms on (mms.code = mmm.vehicle_subcategory_code)
			inner join dbo.master_vehicle_category mmc on (mmc.code = mms.vehicle_category_code)
	where	(
				mmt.code					like '%' + @p_keywords + '%'
				or	mmt.description			like '%' + @p_keywords + '%'
				or	mmc.description			like '%' + @p_keywords + '%'
				or	mms.description			like '%' + @p_keywords + '%'
				or	mmr.description			like '%' + @p_keywords + '%'
				or	mmm.description			like '%' + @p_keywords + '%'
				or	case mmt.is_active
						when '1' then 'Yes'
						else 'No'
					end						like '%' + @p_keywords + '%'
			) ;

		select		mmt.code
					,mmt.description
					,mmc.description	'vehicle_category_name'
					,mms.description	'vehicle_subcategory_name'
					,mmr.description	'vehicle_merk_name'
					,mmm.description	'vehicle_model_name'
					,case mmt.is_active
						 when '1' then 'Yes'
						 else 'No'
					 end 'is_active'
					,@rows_count 'rowcount'
		from		master_vehicle_type mmt
					inner join dbo.master_vehicle_model mmm on (mmm.code		 = mmt.vehicle_model_code)
					inner join dbo.master_vehicle_merk mmr on (mmr.code		 = mmm.vehicle_merk_code)
					inner join dbo.master_vehicle_subcategory mms on (mms.code = mmm.vehicle_subcategory_code)
					inner join dbo.master_vehicle_category mmc on (mmc.code	 = mms.vehicle_category_code)
		where		(
						mmt.code					like '%' + @p_keywords + '%'
						or	mmt.description			like '%' + @p_keywords + '%'
						or	mmc.description			like '%' + @p_keywords + '%'
						or	mms.description			like '%' + @p_keywords + '%'
						or	mmr.description			like '%' + @p_keywords + '%'
						or	mmm.description			like '%' + @p_keywords + '%'
						or	case mmt.is_active
								when '1' then 'Yes'
								else 'No'
							end						like '%' + @p_keywords + '%'
					)

	order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then mmt.code
													when 2 then mmt.description
													when 3 then mmc.description
													when 4 then mms.description
													when 5 then mmr.description
													when 6 then mmm.description
													when 7 then mmt.is_active
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then mmt.code
														when 2 then mmt.description
														when 3 then mmc.description
														when 4 then mms.description
														when 5 then mmr.description
														when 6 then mmm.description
														when 7 then mmt.is_active
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;


