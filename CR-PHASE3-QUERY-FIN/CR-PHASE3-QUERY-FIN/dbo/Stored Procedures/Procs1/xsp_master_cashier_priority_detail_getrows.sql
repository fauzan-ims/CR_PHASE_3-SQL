CREATE PROCEDURE dbo.xsp_master_cashier_priority_detail_getrows
(
	@p_keywords						nvarchar(50)
	,@p_pagenumber					int
	,@p_rowspage					int	
	,@p_order_by					int
	,@p_sort_by						nvarchar(5)
	,@p_cashier_priority_code		nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_cashier_priority_detail mcpd
			inner join dbo.master_transaction mt	on (mcpd.transaction_code = mt.code)
	where	mcpd.cashier_priority_code = @p_cashier_priority_code
	and		(
				mcpd.order_no					like '%' + @p_keywords + '%'
				or	mt.transaction_name			like '%' + @p_keywords + '%'
				or	case mcpd.is_partial
						when '1' then 'true'
						else 'false'
					end							like '%' + @p_keywords + '%'
			) ;

		select	mcpd.id
				,mcpd.order_no
				,mt.transaction_name
				,mcpd.is_partial
				,@rows_count 'rowcount'
		from	master_cashier_priority_detail mcpd
				inner join dbo.master_transaction mt		on (mcpd.transaction_code = mt.code)
		where	mcpd.cashier_priority_code = @p_cashier_priority_code
		and		(
					mcpd.order_no					like '%' + @p_keywords + '%'
					or	mt.transaction_name			like '%' + @p_keywords + '%'
					or	case mcpd.is_partial
							when '1' then 'true'
							else 'false'
						end							like '%' + @p_keywords + '%'
				) 
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then mt.transaction_name
														when 2 then cast(order_no as sql_variant) 
														when 3 then mcpd.is_partial
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then mt.transaction_name
														when 2 then cast(order_no as sql_variant) 
														when 3 then mcpd.is_partial
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
