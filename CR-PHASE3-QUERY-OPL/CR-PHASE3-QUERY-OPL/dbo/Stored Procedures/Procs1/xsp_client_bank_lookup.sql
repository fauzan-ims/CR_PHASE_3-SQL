CREATE PROCEDURE dbo.xsp_client_bank_lookup
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
	from	client_bank
	where	client_code		  = case @p_client_code
									when 'ALL' then client_code
									else @p_client_code
								end
			and (
					bank_name				like '%' + @p_keywords + '%'
					or	bank_account_no		like '%' + @p_keywords + '%'
					or	bank_account_name	like '%' + @p_keywords + '%'
				) ;
 
		select		code
					,bank_name
					,bank_account_no	
					,bank_account_name
					,@rows_count 'rowcount'
		from		client_bank
		where		client_code		  = case @p_client_code
											when 'ALL' then client_code
											else @p_client_code
										end
					and (
							bank_name				like '%' + @p_keywords + '%'
							or	bank_account_no		like '%' + @p_keywords + '%'
							or	bank_account_name	like '%' + @p_keywords + '%'
						) 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then bank_name
													when 2 then bank_account_no	
													when 3 then bank_account_name
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then bank_name
													when 2 then bank_account_no	
													when 3 then bank_account_name
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

