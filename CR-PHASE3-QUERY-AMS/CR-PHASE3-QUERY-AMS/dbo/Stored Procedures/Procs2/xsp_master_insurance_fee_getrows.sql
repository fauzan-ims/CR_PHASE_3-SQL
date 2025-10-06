CREATE PROCEDURE dbo.xsp_master_insurance_fee_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_insurance_code  nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_insurance_fee
	where	insurance_code = @p_insurance_code
			and (
					id										like '%' + @p_keywords + '%'
					or	insurance_code						like '%' + @p_keywords + '%'
					or	convert(varchar(30), eff_date, 103)	like '%' + @p_keywords + '%'
					or	admin_fee_buy_amount				like '%' + @p_keywords + '%'
					or	admin_fee_sell_amount				like '%' + @p_keywords + '%'
					or	stamp_fee_amount					like '%' + @p_keywords + '%'
				) ;

		select		id
					,insurance_code						
					,convert(varchar(30), eff_date, 103) 'eff_date'	
					,admin_fee_buy_amount				
					,admin_fee_sell_amount				
					,stamp_fee_amount					
					,@rows_count 'rowcount'
		from		master_insurance_fee
		where		insurance_code = @p_insurance_code
					and (
							id										like '%' + @p_keywords + '%'
							or	insurance_code						like '%' + @p_keywords + '%'
							or	convert(varchar(30), eff_date, 103)	like '%' + @p_keywords + '%'
							or	admin_fee_buy_amount				like '%' + @p_keywords + '%'
							or	admin_fee_sell_amount				like '%' + @p_keywords + '%'
							or	stamp_fee_amount					like '%' + @p_keywords + '%'
						) 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then cast(eff_date as sql_variant)						
													when 2 then	cast(admin_fee_buy_amount as sql_variant)	
													when 3 then	cast(admin_fee_sell_amount as sql_variant)						
													when 4 then	cast(stamp_fee_amount as sql_variant)	
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then cast(eff_date as sql_variant)						
													when 2 then	cast(admin_fee_buy_amount as sql_variant)	
													when 3 then	cast(admin_fee_sell_amount as sql_variant)						
													when 4 then	cast(stamp_fee_amount as sql_variant)	
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;


