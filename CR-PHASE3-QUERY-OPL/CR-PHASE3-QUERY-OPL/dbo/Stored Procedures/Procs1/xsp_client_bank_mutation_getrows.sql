CREATE PROCEDURE [dbo].[xsp_client_bank_mutation_getrows]
(
	@p_keywords							nvarchar(50)
	,@p_pagenumber						int
	,@p_rowspage						int
	,@p_order_by						int
	,@p_sort_by							nvarchar(5)
)
as
begin
	
	declare 	@rows_count int = 0 ;

	select 		@rows_count = count(1)
	from		dbo.client_bank_mutation
	where		(
						id									like '%' + @p_keywords + '%'
						or	client_code						like '%' + @p_keywords + '%'
						or	client_bank_code				like '%' + @p_keywords + '%'
						or	month							like '%' + @p_keywords + '%'
						or	year							like '%' + @p_keywords + '%'
						or	debit_transaction_count			like '%' + @p_keywords + '%'
						or	debit_amount					like '%' + @p_keywords + '%'
						or	credit_transaction_count		like '%' + @p_keywords + '%'
						or	credit_amount					like '%' + @p_keywords + '%'
						or	balance_amount					like '%' + @p_keywords + '%'
				);

	select		id
				,client_code
				,client_bank_code
				,month
				,year
				,debit_transaction_count
				,debit_amount
				,credit_transaction_count
				,credit_amount
				,balance_amount
				,@rows_count
	from		dbo.client_bank_mutation
	where		(
					id									like '%' + @p_keywords + '%'
					or	client_code						like '%' + @p_keywords + '%'
					or	client_bank_code				like '%' + @p_keywords + '%'
					or	month							like '%' + @p_keywords + '%'
					or	year							like '%' + @p_keywords + '%'
					or	debit_transaction_count			like '%' + @p_keywords + '%'
					or	debit_amount					like '%' + @p_keywords + '%'
					or	credit_transaction_count		like '%' + @p_keywords + '%'
					or	credit_amount					like '%' + @p_keywords + '%'
					or	balance_amount					like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then id
														when 2 then client_code
														when 3 then client_bank_code
														when 4 then month
														when 5 then year
														when 6 then debit_transaction_count
														when 7 then debit_amount
														when 8 then credit_transaction_count
														when 9 then credit_amount
														when 10 then balance_amount
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then id
														when 2 then client_code
														when 3 then client_bank_code
														when 4 then month
														when 5 then year
														when 6 then debit_transaction_count
														when 7 then debit_amount
														when 8 then credit_transaction_count
														when 9 then credit_amount
														when 10 then balance_amount
													end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end
