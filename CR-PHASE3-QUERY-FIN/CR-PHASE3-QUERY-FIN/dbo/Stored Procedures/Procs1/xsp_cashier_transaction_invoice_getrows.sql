CREATE PROCEDURE dbo.xsp_cashier_transaction_invoice_getrows
(
	@p_keywords					 nvarchar(50)
	,@p_pagenumber				 int
	,@p_rowspage				 int
	,@p_order_by				 int
	,@p_sort_by					 nvarchar(5)
	,@p_cashier_transaction_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.cashier_transaction_invoice
	where	cashier_transaction_code = @p_cashier_transaction_code
			and (
					invoice_no										like '%' + @p_keywords + '%'
					or	customer_name								like '%' + @p_keywords + '%'					
					or	convert(varchar(30), invoice_date, 103)		like '%' + @p_keywords + '%'
					or	convert(varchar(30), invoice_due_date, 103)	like '%' + @p_keywords + '%'
					or	invoice_net_amount							like '%' + @p_keywords + '%'
					or	invoice_balance_amount						like '%' + @p_keywords + '%'
					or	allocation_amount							like '%' + @p_keywords + '%'
				) ;

	select		id
				,asset_no
				,customer_name
				,cashier_transaction_code
				,invoice_no
				,convert(varchar(30), invoice_date, 103) 'invoice_date'
				,convert(varchar(30), invoice_due_date, 103) 'invoice_due_date'
				,invoice_net_amount
				,invoice_balance_amount
				,allocation_amount
				,@rows_count 'rowcount'
	from		cashier_transaction_invoice
	where		cashier_transaction_code = @p_cashier_transaction_code
				and (
						invoice_no										like '%' + @p_keywords + '%'
						or	customer_name								like '%' + @p_keywords + '%'					
						or	convert(varchar(30), invoice_date, 103)		like '%' + @p_keywords + '%'
						or	convert(varchar(30), invoice_due_date, 103)	like '%' + @p_keywords + '%'
						or	invoice_net_amount							like '%' + @p_keywords + '%'
						or	invoice_balance_amount						like '%' + @p_keywords + '%'
						or	allocation_amount							like '%' + @p_keywords + '%'
					) 
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then invoice_no + customer_name
														when 2 then cast(invoice_date as sql_variant)
														when 3 then cast(invoice_due_date as sql_variant)
														when 4 then cast(invoice_net_amount as sql_variant)
														when 5 then cast(invoice_balance_amount as sql_variant)
														when 6 then cast(allocation_amount as sql_variant)
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then invoice_no + customer_name
														when 2 then cast(invoice_date as sql_variant)
														when 3 then cast(invoice_due_date as sql_variant)
														when 4 then cast(invoice_net_amount as sql_variant)
														when 5 then cast(invoice_balance_amount as sql_variant)
														when 6 then cast(allocation_amount as sql_variant)
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
