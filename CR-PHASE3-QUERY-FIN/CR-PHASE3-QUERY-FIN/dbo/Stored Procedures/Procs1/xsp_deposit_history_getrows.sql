CREATE PROCEDURE dbo.xsp_deposit_history_getrows
(
	@p_keywords	     nvarchar(50)
	,@p_pagenumber   int
	,@p_rowspage     int
	,@p_order_by     int
	,@p_sort_by	     nvarchar(5)
	,@p_deposit_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	deposit_history
	where	deposit_code = @p_deposit_code
			and (
					Format(cast(transaction_date as datetime),'dd/MM/yyyy HH:mm:ss','en-us')	like '%' + @p_keywords + '%'
					or orig_amount																like '%' + @p_keywords + '%'
					or orig_currency_code														like '%' + @p_keywords + '%'
					or exch_rate																like '%' + @p_keywords + '%'
					or base_amount																like '%' + @p_keywords + '%'
					or source_reff_code															like '%' + @p_keywords + '%'
					or source_reff_name															like '%' + @p_keywords + '%'
				) ;

		select		id
					,Format(cast(transaction_date as datetime),'dd/MM/yyyy HH:mm:ss','en-us') 'transaction_date'
					,orig_amount			
					,orig_currency_code	
					,exch_rate				
					,base_amount			
					,source_reff_code		
					,source_reff_name		
					,@rows_count 'rowcount'
		from		deposit_history
		where		deposit_code = @p_deposit_code
					and (
							Format(cast(transaction_date as datetime),'dd/MM/yyyy HH:mm:ss','en-us')	like '%' + @p_keywords + '%'
							or orig_amount																like '%' + @p_keywords + '%'
							or orig_currency_code														like '%' + @p_keywords + '%'
							or exch_rate																like '%' + @p_keywords + '%'
							or base_amount																like '%' + @p_keywords + '%'
							or source_reff_code															like '%' + @p_keywords + '%'
							or source_reff_name															like '%' + @p_keywords + '%'
						) 
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then cast(transaction_date as sql_variant)
														when 2 then source_reff_code 
														when 3 then cast(orig_amount as sql_variant)					
														when 4 then orig_currency_code	
														when 5 then cast(base_amount as sql_variant)
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then cast(transaction_date as sql_variant)
														when 2 then source_reff_code 
														when 3 then cast(orig_amount as sql_variant)					
														when 4 then orig_currency_code	
														when 5 then cast(base_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
