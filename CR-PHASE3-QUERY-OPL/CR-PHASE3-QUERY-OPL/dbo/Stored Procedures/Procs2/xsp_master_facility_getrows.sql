CREATE PROCEDURE dbo.xsp_master_facility_getrows
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
	from	master_facility
	where		(
					description					like '%' + @p_keywords + '%'
					or	deskcoll_min			like '%' + @p_keywords + '%'
					or	deskcoll_max			like '%' + @p_keywords + '%'
					or	sp1_days				like '%' + @p_keywords + '%'
					or	sp2_days				like '%' + @p_keywords + '%'
					or	somasi_days				like '%' + @p_keywords + '%'
					or	aging_days1				like '%' + @p_keywords + '%'
					or	aging_days2				like '%' + @p_keywords + '%'
					or	aging_days3				like '%' + @p_keywords + '%'
					or	aging_days4				like '%' + @p_keywords + '%'
					or	case is_active
							when '1' then 'Yes'
							else 'No'
						end						like '%' + @p_keywords + '%'
				)

	select		code
				,description
				,deskcoll_min
				,deskcoll_max
				,sp1_days
				,sp2_days
				,somasi_days
				,aging_days1
				,aging_days2
				,aging_days3
				,aging_days4
				,case is_active
					 when '1' then 'Yes'
					 else 'No'
				 end 'is_active'
				,@rows_count 'rowcount'
	from		master_facility
	where		(
					description					like '%' + @p_keywords + '%'
					or	deskcoll_min			like '%' + @p_keywords + '%'
					or	deskcoll_max			like '%' + @p_keywords + '%'
					or	sp1_days				like '%' + @p_keywords + '%'
					or	sp2_days				like '%' + @p_keywords + '%'
					or	somasi_days				like '%' + @p_keywords + '%'
					or	aging_days1				like '%' + @p_keywords + '%'
					or	aging_days2				like '%' + @p_keywords + '%'
					or	aging_days3				like '%' + @p_keywords + '%'
					or	aging_days4				like '%' + @p_keywords + '%'
					or	case is_active
							when '1' then 'Yes'
							else 'No'
						end						like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then description
													 when 2 then cast(deskcoll_min as sql_variant)
													 when 3 then cast(deskcoll_max as sql_variant)
													 when 4 then cast(sp1_days as sql_variant)
													 when 5 then cast(sp2_days as sql_variant)
													 when 6 then cast(somasi_days as sql_variant)
													 when 7 then cast(aging_days1 as sql_variant)
													 when 8 then cast(aging_days2 as sql_variant)
													 when 9 then cast(aging_days3 as sql_variant)
													 when 10 then cast(aging_days4 as sql_variant)
													 when 11 then is_active
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														 when 1 then description
														 when 2 then cast(deskcoll_min as sql_variant)
														 when 3 then cast(deskcoll_max as sql_variant)
														 when 4 then cast(sp1_days as sql_variant)
														 when 5 then cast(sp2_days as sql_variant)
														 when 6 then cast(somasi_days as sql_variant)
														 when 7 then cast(aging_days1 as sql_variant)
														 when 8 then cast(aging_days2 as sql_variant)
														 when 9 then cast(aging_days3 as sql_variant)
														 when 10 then cast(aging_days4 as sql_variant)
														 when 11 then is_active
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
