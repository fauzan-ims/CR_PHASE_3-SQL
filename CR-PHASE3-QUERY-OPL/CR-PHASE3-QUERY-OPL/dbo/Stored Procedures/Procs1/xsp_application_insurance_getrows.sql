CREATE PROCEDURE dbo.xsp_application_insurance_getrows
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	,@p_application_no nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	application_insurance ai
	where	application_no = @p_application_no
			and (
					ai.coverage_name			like '%' + @p_keywords + '%'
					or	ai.tenor				like '%' + @p_keywords + '%'
					or	ai.total_buy_amount		like '%' + @p_keywords + '%'
					or	ai.total_sell_amount	like '%' + @p_keywords + '%'
					or	ai.currency_code		like '%' + @p_keywords + '%'
				) ;

	 select		ai.id
					,ai.coverage_name
					,ai.tenor
					,ai.total_buy_amount
					,ai.total_sell_amount
					,ai.currency_code
					,@rows_count 'rowcount'
		from		application_insurance ai
		where		application_no = @p_application_no
					and (
							ai.coverage_name			like '%' + @p_keywords + '%'
							or	ai.tenor				like '%' + @p_keywords + '%'
							or	ai.total_buy_amount		like '%' + @p_keywords + '%'
							or	ai.total_sell_amount	like '%' + @p_keywords + '%'
							or	ai.currency_code		like '%' + @p_keywords + '%'
						) 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then ai.id
													when 2 then ai.coverage_name
													when 3 then ai.currency_code
													when 4 then cast(ai.tenor as sql_variant)
													when 5 then cast(ai.total_buy_amount as sql_variant)
													when 6 then cast(ai.total_sell_amount as sql_variant)
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then ai.id
													when 2 then ai.coverage_name
													when 3 then ai.currency_code
													when 4 then cast(ai.tenor as sql_variant)
													when 5 then cast(ai.total_buy_amount as sql_variant)
													when 6 then cast(ai.total_sell_amount as sql_variant)
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;


