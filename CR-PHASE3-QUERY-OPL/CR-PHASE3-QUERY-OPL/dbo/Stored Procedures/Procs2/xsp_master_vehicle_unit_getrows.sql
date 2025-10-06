---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE dbo.xsp_master_vehicle_unit_getrows
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
	from	master_vehicle_unit
	where	(
				vehicle_name				like '%' + @p_keywords + '%'
				or	description					like '%' + @p_keywords + '%'
				or	case is_cbu
						when '1' then 'Yes'
						else 'No'
					end							like '%' + @p_keywords + '%'
				or	case is_karoseri
						when '1' then 'Yes'
						else 'No'
					end							like '%' + @p_keywords + '%'
				or	case is_active
						when '1' then 'Yes'
						else 'No'
					end							like '%' + @p_keywords + '%'
			) ;

		select		code
					,vehicle_name
					,description
					,case is_cbu
						 when '1' then 'Yes'
						 else 'No'
					 end 'is_cbu'
					,case is_karoseri
						 when '1' then 'Yes'
						 else 'No'
					 end 'is_karoseri'
					,case is_active
						 when '1' then 'Yes'
						 else 'No'
					 end 'is_active'
					,@rows_count 'rowcount'
		from		master_vehicle_unit
		where		(
						vehicle_name				like '%' + @p_keywords + '%'
						or	description					like '%' + @p_keywords + '%'
						or	case is_cbu
								when '1' then 'Yes'
								else 'No'
							end							like '%' + @p_keywords + '%'
						or	case is_karoseri
								when '1' then 'Yes'
								else 'No'
							end							like '%' + @p_keywords + '%'
						or	case is_active
								when '1' then 'Yes'
								else 'No'
							end							like '%' + @p_keywords + '%'
					)

	Order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1	then vehicle_name
													when 2	then description
													when 3	then is_cbu
													when 4	then is_karoseri
													when 5	then is_active
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1	then vehicle_name
														when 2	then description
														when 3	then is_cbu
														when 4	then is_karoseri
														when 5	then is_active
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;


