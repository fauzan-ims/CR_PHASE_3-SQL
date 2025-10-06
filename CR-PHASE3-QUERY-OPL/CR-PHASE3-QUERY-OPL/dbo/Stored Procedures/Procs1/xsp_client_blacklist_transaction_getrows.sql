CREATE PROCEDURE dbo.xsp_client_blacklist_transaction_getrows
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
	from	client_blacklist_transaction
	where	transaction_status = @p_transaction_status
			and (
					code											like '%' + @p_keywords + '%'
					or	transaction_status							like '%' + @p_keywords + '%'
					or	transaction_type							like '%' + @p_keywords + '%'
					or	convert(varchar(30), transaction_date, 103)	like '%' + @p_keywords + '%'
					or	transaction_remarks							like '%' + @p_keywords + '%'
				) ; 
		select		code
					,transaction_status
					,transaction_type
					,convert(varchar(30), transaction_date, 103) 'transaction_date'
					,transaction_remarks
					,@rows_count 'rowcount'
		from		client_blacklist_transaction
		where		transaction_status = @p_transaction_status
					and (
							code											like '%' + @p_keywords + '%'
							or	transaction_status							like '%' + @p_keywords + '%'
							or	transaction_type							like '%' + @p_keywords + '%'
							or	convert(varchar(30), transaction_date, 103)	like '%' + @p_keywords + '%'
							or	transaction_remarks							like '%' + @p_keywords + '%'
						) 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then code
													when 2 then transaction_status	
													when 3 then transaction_type							
													when 4 then convert(varchar(30), transaction_date, 103)	
													when 5 then transaction_remarks	
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then code
													when 2 then transaction_status	
													when 3 then transaction_type							
													when 4 then convert(varchar(30), transaction_date, 103)	
													when 5 then transaction_remarks	
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

