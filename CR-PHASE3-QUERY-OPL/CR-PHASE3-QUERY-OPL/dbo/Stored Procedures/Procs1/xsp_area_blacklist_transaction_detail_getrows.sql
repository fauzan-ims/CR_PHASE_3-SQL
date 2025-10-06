--created by, Rian at 16/05/2023 

CREATE PROCEDURE dbo.xsp_area_blacklist_transaction_detail_getrows
(
	@p_keywords							nvarchar(50)
	,@p_pagenumber						int
	,@p_rowspage						int
	,@p_order_by						int
	,@p_sort_by							nvarchar(5)
	,@p_area_blacklist_transaction_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	area_blacklist_transaction_detail
	where	area_blacklist_transaction_code = @p_area_blacklist_transaction_code
			and (
					province_name		like '%' + @p_keywords + '%'
					or	city_name		like '%' + @p_keywords + '%'
				) ;

		select		id
				   ,area_blacklist_transaction_code
				   ,province_code
				   ,city_code
				   ,province_name
				   ,city_name
					,@rows_count 'rowcount'
		from		area_blacklist_transaction_detail
		where		area_blacklist_transaction_code = @p_area_blacklist_transaction_code
					and (
							province_name		like '%' + @p_keywords + '%'
							or	city_name		like '%' + @p_keywords + '%'
						)

		order by 	case  
						when @p_sort_by = 'asc' then case @p_order_by
														when 1 then province_name
														when 2 then city_name
														when 3 then cast(mod_date as sql_variant) 
						  							end
					end asc 
					,case 
						when @p_sort_by = 'desc' then case @p_order_by
															when 1 then province_name
															when 2 then city_name
															when 3 then cast(mod_date as sql_variant) 
						  							end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
