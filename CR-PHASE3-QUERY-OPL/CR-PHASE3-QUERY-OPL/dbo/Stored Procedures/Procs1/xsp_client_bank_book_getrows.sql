CREATE PROCEDURE dbo.xsp_client_bank_book_getrows
(
	@p_keywords			 nvarchar(50)
	,@p_pagenumber		 int
	,@p_rowspage		 int
	,@p_order_by		 int
	,@p_sort_by			 nvarchar(5)
	,@p_client_bank_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	client_bank_book
	where	client_bank_code = @p_client_bank_code
			and (
					periode_year				like '%' + @p_keywords + '%'
					or	periode_month			like '%' + @p_keywords + '%'
					or	opening_balance_amount	like '%' + @p_keywords + '%'
					or	ending_balance_amount	like '%' + @p_keywords + '%'
				) ;

 
		select		id
					,periode_year
					,periode_month			
					,opening_balance_amount	
					,ending_balance_amount	
					,@rows_count 'rowcount'
		from		client_bank_book
		where		client_bank_code = @p_client_bank_code
					and (
							periode_year				like '%' + @p_keywords + '%'
							or	periode_month			like '%' + @p_keywords + '%'
							or	opening_balance_amount	like '%' + @p_keywords + '%'
							or	ending_balance_amount	like '%' + @p_keywords + '%'
						) 

		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then periode_year
													when 2 then periode_month
													when 3 then cast(opening_balance_amount as sql_variant)	
													when 4 then cast(ending_balance_amount as sql_variant)
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then periode_year
													when 2 then periode_month
													when 3 then cast(opening_balance_amount as sql_variant)	
													when 4 then cast(ending_balance_amount as sql_variant)
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

