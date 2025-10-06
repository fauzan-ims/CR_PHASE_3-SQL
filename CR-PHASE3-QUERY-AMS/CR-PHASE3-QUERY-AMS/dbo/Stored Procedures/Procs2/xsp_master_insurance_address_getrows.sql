CREATE PROCEDURE dbo.xsp_master_insurance_address_getrows
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	,@p_insurance_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_insurance_address
	where	insurance_code = @p_insurance_code
			and (
					id								like '%' + @p_keywords + '%'
					or	address						like '%' + @p_keywords + '%'
					or	province_name				like '%' + @p_keywords + '%'
					or	city_name					like '%' + @p_keywords + '%'
					or	zip_name					like '%' + @p_keywords + '%'
					or	case is_latest
							when '1' then 'Yes'
							else 'No'
						end							like '%' + @p_keywords + '%'
				) ;
		select		id
					,address
					,province_name
					,city_name
					,zip_name
					,case is_latest
						 when '1' then 'Yes'
						 else 'No'
					 end 'is_latest'
					,@rows_count 'rowcount'
		from		master_insurance_address
		where		insurance_code = @p_insurance_code
					and (
							id								like '%' + @p_keywords + '%'
							or	address						like '%' + @p_keywords + '%'
							or	province_name				like '%' + @p_keywords + '%'
							or	city_name					like '%' + @p_keywords + '%'
							or	zip_name					like '%' + @p_keywords + '%'
							or	case is_latest
									when '1' then 'Yes'
									else 'No'
								end							like '%' + @p_keywords + '%'
						)
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then address
													when 2 then province_name
													when 3 then city_name
													when 4 then zip_name
													when 5 then is_latest
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then address
													when 2 then province_name
													when 3 then city_name
													when 4 then zip_name
													when 5 then is_latest
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;


