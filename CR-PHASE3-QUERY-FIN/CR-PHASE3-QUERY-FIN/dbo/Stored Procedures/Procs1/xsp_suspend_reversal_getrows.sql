CREATE PROCEDURE dbo.xsp_suspend_reversal_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	suspend_reversal
	where	(
				code							like '%' + @p_keywords + '%'
				or	branch_code					like '%' + @p_keywords + '%'
				or	branch_name					like '%' + @p_keywords + '%'
				or	reversal_status				like '%' + @p_keywords + '%'
				or	reversal_date				like '%' + @p_keywords + '%'
				or	reversal_amount				like '%' + @p_keywords + '%'
				or	reversal_remarks			like '%' + @p_keywords + '%'
				or	reversal_bank_name			like '%' + @p_keywords + '%'
				or	reversal_bank_account_no	like '%' + @p_keywords + '%'
				or	reversal_bank_account_name	like '%' + @p_keywords + '%'
				or	suspend_code				like '%' + @p_keywords + '%'
				or	suspend_currency_code		like '%' + @p_keywords + '%'
				or	suspend_amount				like '%' + @p_keywords + '%'
			) ;

		select		code
					,branch_code
					,branch_name
					,reversal_status
					,reversal_date
					,reversal_amount
					,reversal_remarks
					,reversal_bank_name
					,reversal_bank_account_no
					,reversal_bank_account_name
					,suspend_code
					,suspend_currency_code
					,suspend_amount
					,@rows_count 'rowcount'
		from		suspend_reversal
		where		(
						code							like '%' + @p_keywords + '%'
						or	branch_code					like '%' + @p_keywords + '%'
						or	branch_name					like '%' + @p_keywords + '%'
						or	reversal_status				like '%' + @p_keywords + '%'
						or	reversal_date				like '%' + @p_keywords + '%'
						or	reversal_amount				like '%' + @p_keywords + '%'
						or	reversal_remarks			like '%' + @p_keywords + '%'
						or	reversal_bank_name			like '%' + @p_keywords + '%'
						or	reversal_bank_account_no	like '%' + @p_keywords + '%'
						or	reversal_bank_account_name	like '%' + @p_keywords + '%'
						or	suspend_code				like '%' + @p_keywords + '%'
						or	suspend_currency_code		like '%' + @p_keywords + '%'
						or	suspend_amount				like '%' + @p_keywords + '%'
					)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then code
														when 2 then branch_code
														when 3 then branch_name
														when 4 then reversal_status
														when 5 then reversal_remarks
														when 6 then reversal_bank_name
														when 7 then reversal_bank_account_no
														when 8 then reversal_bank_account_name
														when 9 then suspend_code
														when 10 then suspend_currency_code
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then code
														when 2 then branch_code
														when 3 then branch_name
														when 4 then reversal_status
														when 5 then reversal_remarks
														when 6 then reversal_bank_name
														when 7 then reversal_bank_account_no
														when 8 then reversal_bank_account_name
														when 9 then suspend_code
														when 10 then suspend_currency_code
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
