--created by, Rian at 16/05/2023 

--created by, Rian at 16/05/2023 

CREATE PROCEDURE dbo.xsp_area_blacklist_transaction_getrows
(
	@p_keywords			   nvarchar(50)
	,@p_pagenumber		   int
	,@p_rowspage		   int
	,@p_order_by		   int
	,@p_sort_by			   nvarchar(5)
	,@p_transaction_status nvarchar(10)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	area_blacklist_transaction
	where	transaction_status = case @p_transaction_status
									   when 'ALL' then transaction_status
									   else @p_transaction_status
								  end
			and (
					code											like '%' + @p_keywords + '%'
					or	transaction_type							like '%' + @p_keywords + '%'
					or	convert(varchar(30), transaction_date, 103)	like '%' + @p_keywords + '%'
					or	transaction_remarks							like '%' + @p_keywords + '%'
				) ;

		select		code
					,transaction_type
					,convert(varchar(30), transaction_date, 103) 'transaction_date'
					,transaction_remarks
					,transaction_status
					,@rows_count 'rowcount'
		from		area_blacklist_transaction
		where		transaction_status = case @p_transaction_status
									   when 'ALL' then transaction_status
									   else @p_transaction_status
								  end
					and (
							code											like '%' + @p_keywords + '%'
							or	transaction_type							like '%' + @p_keywords + '%'
							or	convert(varchar(30), transaction_date, 103)	like '%' + @p_keywords + '%'
							or	transaction_remarks							like '%' + @p_keywords + '%'
							or	transaction_status							like '%' + @p_keywords + '%'
						)

		order by 	case  
						when @p_sort_by = 'asc' then case @p_order_by
														when 1 then code
														when 2 then transaction_type							
														when 3 then cast(transaction_date as sql_variant)	
														when 4 then transaction_remarks	
														when 5 then transaction_status	
														when 6 then cast(mod_date as sql_variant) 
						  							end
					end asc 
					,case 
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then code
														when 2 then transaction_type							
														when 3 then cast(transaction_date as sql_variant)	
														when 4 then transaction_remarks	
														when 5 then transaction_status	
														when 6 then cast(mod_date as sql_variant) 
						  							end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

