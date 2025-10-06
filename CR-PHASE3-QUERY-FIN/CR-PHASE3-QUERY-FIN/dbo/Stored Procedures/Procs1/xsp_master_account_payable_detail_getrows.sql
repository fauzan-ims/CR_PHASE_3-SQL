CREATE procedure dbo.xsp_master_account_payable_detail_getrows
(
	@p_keywords					nvarchar(50)
	,@p_pagenumber				int
	,@p_rowspage				int
	,@p_order_by				int
	,@p_sort_by					nvarchar(5)
	,@p_account_payable_code	nvarchar(50)
)
as
begin
	declare 	@rows_count int = 0 ;

	select 	@rows_count = count(1)
	from	dbo.master_account_payable_detail 
	where	account_payable_code = @p_account_payable_code
			and (
					payment_source						like 	'%'+@p_keywords+'%'
			);

		select	id
				,account_payable_code		
				,payment_source	
				,@rows_count 'rowcount'
		from	master_account_payable_detail 
		where	account_payable_code = @p_account_payable_code
				and (
						payment_source						like 	'%'+@p_keywords+'%'
				)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1	then payment_source	
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1	then payment_source
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end

