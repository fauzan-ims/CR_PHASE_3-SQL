CREATE PROCEDURE dbo.xsp_payment_transaction_detail_getrows
(
	@p_keywords						nvarchar(50)
	,@p_pagenumber					int
	,@p_rowspage					int
	,@p_order_by					int
	,@p_sort_by						nvarchar(5)
	,@p_payment_transaction_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	payment_transaction_detail ptd
			inner join dbo.payment_request pr on (pr.code = ptd.payment_request_code)
	where	ptd.payment_transaction_code = @p_payment_transaction_code
			and	(
					payment_request_code			like '%' + @p_keywords + '%'
					or	orig_curr_code				like '%' + @p_keywords + '%'
					or	ptd.orig_amount				like '%' + @p_keywords + '%'
					or	ptd.exch_rate				like '%' + @p_keywords + '%'
					or	base_amount					like '%' + @p_keywords + '%'
					or	pr.payment_branch_name		like '%' + @p_keywords + '%'
					or	pr.payment_remarks			like '%' + @p_keywords + '%'
				) ;

		select		id
					,ptd.payment_transaction_code
					,payment_request_code
					,orig_curr_code
					,base_amount
					,ptd.exch_rate
					,ptd.orig_amount
					,pr.payment_branch_name	
					,pr.payment_remarks		
					,@rows_count 'rowcount'
		from		payment_transaction_detail ptd
					inner join dbo.payment_request pr on (pr.code = ptd.payment_request_code)
		where		ptd.payment_transaction_code = @p_payment_transaction_code
					and	(
							payment_request_code			like '%' + @p_keywords + '%'
							or	orig_curr_code				like '%' + @p_keywords + '%'
							or	ptd.orig_amount				like '%' + @p_keywords + '%'
							or	ptd.exch_rate				like '%' + @p_keywords + '%'
							or	base_amount					like '%' + @p_keywords + '%'
							or	pr.payment_branch_name		like '%' + @p_keywords + '%'
							or	pr.payment_remarks			like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then payment_request_code
														when 2 then payment_branch_name
														when 3 then payment_remarks
														when 4 then orig_curr_code
														when 5 then cast(ptd.orig_amount as sql_variant)
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then payment_request_code
														when 2 then payment_branch_name
														when 3 then payment_remarks
														when 4 then orig_curr_code
														when 5 then cast(ptd.orig_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
