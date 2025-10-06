CREATE PROCEDURE dbo.xsp_client_blacklist_transaction_detail_getrows
(
	@p_keywords					   nvarchar(50)
	,@p_pagenumber				   int
	,@p_rowspage				   int
	,@p_order_by				   int
	,@p_sort_by					   nvarchar(5)
	,@p_blacklist_transaction_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	client_blacklist_transaction_detail
	where	blacklist_transaction_code = @p_blacklist_transaction_code
			and (
					client_type					like '%' + @p_keywords + '%'
					or	blacklist_type			like '%' + @p_keywords + '%'
					or	corporate_name			like '%' + @p_keywords + '%'
					or	personal_name			like '%' + @p_keywords + '%'
					or	personal_id_no			like '%' + @p_keywords + '%'
					or	corporate_tax_file_no	like '%' + @p_keywords + '%'
				) ;
				 
		select		id
					,client_type
					,blacklist_type		
					,corporate_name		
					,personal_name		
					,personal_id_no		
					,corporate_tax_file_no
					,@rows_count 'rowcount'
		from		client_blacklist_transaction_detail
		where		blacklist_transaction_code = @p_blacklist_transaction_code
					and (
							client_type					like '%' + @p_keywords + '%'
							or	blacklist_type			like '%' + @p_keywords + '%'
							or	corporate_name			like '%' + @p_keywords + '%'
							or	personal_name			like '%' + @p_keywords + '%'
							or	personal_id_no			like '%' + @p_keywords + '%'
							or	corporate_tax_file_no	like '%' + @p_keywords + '%'
						) 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then corporate_name 
													when 1 then personal_name 	
													when 2 then personal_id_no		
													when 2 then corporate_tax_file_no
													when 3 then client_type
													when 4 then blacklist_type
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then corporate_name 
													when 1 then personal_name 	
													when 2 then personal_id_no		
													when 2 then corporate_tax_file_no
													when 3 then client_type
													when 4 then blacklist_type
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

