CREATE PROCEDURE dbo.xsp_master_insurance_rate_non_life_detail_getrows
(
	@p_keywords			   nvarchar(50)
	,@p_pagenumber		   int
	,@p_rowspage		   int
	,@p_order_by		   int
	,@p_sort_by			   nvarchar(5)
	,@p_rate_non_life_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_insurance_rate_non_life_detail
	where	rate_non_life_code = @p_rate_non_life_code
			and (
					sum_insured_from			like '%' + @p_keywords + '%'
					or	sum_insured_to			like '%' + @p_keywords + '%'
					or	calculate_by			like '%' + @p_keywords + '%'
					or	buy_rate				like '%' + @p_keywords + '%'
					or	buy_amount				like '%' + @p_keywords + '%'
					or	sell_rate				like '%' + @p_keywords + '%'
					or	sell_amount				like '%' + @p_keywords + '%'
				) ;

		select		id
					,sum_insured_from
					,sum_insured_to
					,calculate_by
					,buy_rate
					,buy_amount
					,sell_rate	
					,sell_amount
					,@rows_count 'rowcount'
		from		master_insurance_rate_non_life_detail
		where		rate_non_life_code = @p_rate_non_life_code
					and (
							sum_insured_from			like '%' + @p_keywords + '%'
							or	sum_insured_to			like '%' + @p_keywords + '%'
							or	calculate_by			like '%' + @p_keywords + '%'
							or	buy_rate				like '%' + @p_keywords + '%'
							or	buy_amount				like '%' + @p_keywords + '%'
							or	sell_rate				like '%' + @p_keywords + '%'
							or	sell_amount				like '%' + @p_keywords + '%'
						)

		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then cast(sum_insured_from as sql_variant)
													when 2 then calculate_by 
													when 3 then cast(buy_amount as sql_variant)
													when 4 then cast(buy_rate as sql_variant) 
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then cast(sum_insured_from as sql_variant)
														when 2 then calculate_by 
														when 3 then cast(buy_amount as sql_variant)
														when 4 then cast(buy_rate as sql_variant) 
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;


