CREATE PROCEDURE dbo.xsp_reconcile_transaction_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_reconcile_code	nvarchar(50)
	,@p_is_system		nvarchar(1)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	reconcile_transaction
	where	reconcile_code = @p_reconcile_code
			and is_system  = @p_is_system
			and (
				case is_reconcile
					when '1' then 'true'
					else 'false'
				end							like '%' + @p_keywords + '%'
				or	convert(varchar(30), transaction_value_date, 103)	like '%' + @p_keywords + '%'
				or	transaction_source		like '%' + @p_keywords + '%'
				or	transaction_no			like '%' + @p_keywords + '%'
				or	transaction_reff_no		like '%' + @p_keywords + '%'
				or	transaction_amount		like '%' + @p_keywords + '%'
			) ;

		select		id
					,is_reconcile
					,convert(varchar(30), transaction_value_date, 103) 'transaction_value_date'	
					,transaction_source									
					,transaction_no										
					,transaction_reff_no									
					,transaction_amount		
					,remark
					,@rows_count 'rowcount'
		from		reconcile_transaction
		where		reconcile_code = @p_reconcile_code
					and is_system  = @p_is_system
					and (
						case is_reconcile
							when '1' then 'true'
							else 'false'
						end														like '%' + @p_keywords + '%'
						or	convert(varchar(30), transaction_value_date, 103)	like '%' + @p_keywords + '%'
						or	transaction_source									like '%' + @p_keywords + '%'
						or	transaction_no										like '%' + @p_keywords + '%'
						or	transaction_reff_no									like '%' + @p_keywords + '%'
						or	transaction_amount									like '%' + @p_keywords + '%'
					)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then is_reconcile
														when 2 then cast(transaction_value_date as sql_variant)	
														when 3 then transaction_source										
														when 4 then cast(transaction_amount as sql_variant)
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then is_reconcile
														when 2 then cast(transaction_value_date as sql_variant)	
														when 3 then transaction_source										
														when 4 then cast(transaction_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
