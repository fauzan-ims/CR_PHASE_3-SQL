--created by, Rian at 16/05/2023 

CREATE PROCEDURE dbo.xsp_area_blacklist_getrows
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
	from	area_blacklist ab
			inner join dbo.sys_general_subcode sgs on (sgs.code = ab.source)
	where	(
				ab.code							like '%' + @p_keywords + '%'
				or	sgs.description				like '%' + @p_keywords + '%'
				or	ab.province_code			like '%' + @p_keywords + '%'
				or	ab.city_code				like '%' + @p_keywords + '%'
				or	ab.province_name			like '%' + @p_keywords + '%'
				or	ab.city_name				like '%' + @p_keywords + '%'
				or	case ab.is_active
						when '1' then 'Yes'
						else 'No'
					end							like '%' + @p_keywords + '%'
			) ;

		select		ab.code
					,sgs.description 'source'
					,ab.province_code
					,ab.city_code
					,ab.province_name
					,ab.city_name
					,case ab.is_active
					 	when '1' then 'Yes'
					 	else 'No'
					 end 'is_active'					
					,@rows_count 'rowcount'
		from		area_blacklist ab
					inner join dbo.sys_general_subcode sgs on (sgs.code = ab.source)
		where		(
						ab.code							like '%' + @p_keywords + '%'
						or	sgs.description				like '%' + @p_keywords + '%'
						or	ab.province_code			like '%' + @p_keywords + '%'
						or	ab.city_code				like '%' + @p_keywords + '%'
						or	ab.province_name			like '%' + @p_keywords + '%'
						or	ab.city_name				like '%' + @p_keywords + '%'
						or	case ab.is_active
								when '1' then 'Yes'
								else 'No'
							end							like '%' + @p_keywords + '%'
					)


		order by 	case  
						when @p_sort_by = 'asc' then case @p_order_by
													when 1 then ab.province_name
													when 2 then ab.city_name
													when 3 then sgs.description
													when 4 then ab.is_active
													when 5 then cast(ab.mod_date as sql_variant) 
						  						end
					end asc 
					,case 
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then ab.province_name
														when 2 then ab.city_name
														when 3 then sgs.description
														when 4 then ab.is_active
														when 5 then cast(ab.mod_date as sql_variant) 
						  							end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
