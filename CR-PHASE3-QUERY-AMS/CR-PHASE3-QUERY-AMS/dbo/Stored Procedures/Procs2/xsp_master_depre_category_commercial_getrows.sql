

CREATE PROCEDURE dbo.xsp_master_depre_category_commercial_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_company_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_depre_category_commercial
	where	company_code = @p_company_code
	and		(
				code				 like '%' + @p_keywords + '%'
				or	company_code	 like '%' + @p_keywords + '%'
				or	description		 like '%' + @p_keywords + '%'
				or	case method_type
							when 'SL' then 'Straight Line'
							else 'Double Declining'
					end				 like '%' + @p_keywords + '%'
				or	usefull			 like '%' + @p_keywords + '%'
				or	rate			 like '%' + @p_keywords + '%'
				or	case is_active
						when '1' then 'Yes'
						else 'No'
					end				 like '%' + @p_keywords + '%'
			) ;

	select		code
				,company_code
				,description
				,case method_type
							when 'SL' then 'Straight Line'
							else 'Double Declining'
				end 'method_type'
				,usefull
				,rate
				,case is_active
					 when '1' then 'Yes'
					 else 'No'
				 end 'is_active'
				,@rows_count 'rowcount'
	from		master_depre_category_commercial
	where		company_code = @p_company_code
	and			(
					code				 like '%' + @p_keywords + '%'
					or	company_code	 like '%' + @p_keywords + '%'
					or	description		 like '%' + @p_keywords + '%'
					or	case method_type
							when 'SL' then 'Straight Line'
							else 'Double Declining'
						end				 like '%' + @p_keywords + '%'
					or	usefull			 like '%' + @p_keywords + '%'
					or	rate			 like '%' + @p_keywords + '%'
					or	case is_active
							when '1' then 'Yes'
							else 'No'
						END				 like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then code
													 when 2 then description
													 when 3 then method_type
													 when 4 then cast(usefull as sql_variant)
													 when 5 then cast(rate as sql_variant)
													 when 6 then is_active
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then code
													 when 2 then description
													 when 3 then method_type
													 when 4 then cast(usefull as sql_variant)
													 when 5 then cast(rate as sql_variant)
													 when 6 then is_active
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
