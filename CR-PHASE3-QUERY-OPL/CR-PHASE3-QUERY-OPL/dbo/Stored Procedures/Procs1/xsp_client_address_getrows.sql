CREATE PROCEDURE [dbo].[xsp_client_address_getrows]
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_client_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	client_address
	where	client_code = @p_client_code
			and (
					province_name					like '%' + @p_keywords + '%'
					or	city_name					like '%' + @p_keywords + '%'
					or	address						like '%' + @p_keywords + '%'
					or	zip_code_code				like '%' + @p_keywords + '%'
					or	case is_legal
							when '1' then 'Yes'
							else 'No'
						end							like '%' + @p_keywords + '%'
					or	case is_collection
							when '1' then 'Yes'
							else 'No'
						end							like '%' + @p_keywords + '%'
				) ;

	select		code
				,province_name
				,city_name
				,address
				,zip_code_code 'zip_code'
				,case is_legal
					when '1' then 'Yes'
					else 'No'
					end 'is_legal'					
				,case is_collection
					when '1' then 'Yes'
					else 'No'
					end 'is_collection'									
				,@rows_count 'rowcount'
	from		client_address
	where		client_code = @p_client_code
				and (
					province_name					like '%' + @p_keywords + '%'
					or	city_name					like '%' + @p_keywords + '%'
					or	address						like '%' + @p_keywords + '%'
					or	zip_code_code				like '%' + @p_keywords + '%'
					or	case is_legal
							when '1' then 'Yes'
							else 'No'
						end							like '%' + @p_keywords + '%'
					or	case is_collection
							when '1' then 'Yes'
							else 'No'
						end							like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then address
														when 2 then province_code
														when 3 then city_name
														when 4 then zip_code_code
														when 5 then is_legal
														when 6 then is_collection
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then address
														when 2 then province_code
														when 3 then city_name
														when 4 then zip_code_code
														when 5 then is_legal
														when 6 then is_collection
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;


