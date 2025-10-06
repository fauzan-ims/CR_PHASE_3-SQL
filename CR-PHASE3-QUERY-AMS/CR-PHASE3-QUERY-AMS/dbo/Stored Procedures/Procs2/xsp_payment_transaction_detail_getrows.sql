CREATE PROCEDURE dbo.xsp_payment_transaction_detail_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_code	   nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;
	select	@rows_count = count(1)
	from	payment_transaction_detail ptd
			left join dbo.payment_transaction pt on (pt.code = ptd.payment_transaction_code)
			left join dbo.payment_request pr on (pr.code	 = ptd.payment_request_code)
	where	ptd.payment_transaction_code = @p_code
			and
			(
				ptd.payment_request_code	like '%' + @p_keywords + '%'
				or	ptd.orig_amount			like '%' + @p_keywords + '%'
				or	ptd.exch_rate			like '%' + @p_keywords + '%'
				or	ptd.tax_amount			like '%' + @p_keywords + '%'
				or	pr.payment_source_no	like '%' + @p_keywords + '%'
				or	pr.payment_source		like '%' + @p_keywords + '%'
				or	pr.payment_remarks		like '%' + @p_keywords + '%'
			) ;

	select		id
				,pr.code
				,pr.branch_name
				,pr.payment_remarks
				,ptd.orig_amount
				,ptd.payment_request_code
				,pr.payment_source_no
				,pr.payment_source
				,pr.payment_remarks
				,ptd.exch_rate
				,ptd.tax_amount
				,@rows_count 'rowcount'
	from		payment_transaction_detail ptd
				left join dbo.payment_transaction pt on (pt.code = ptd.payment_transaction_code)
				left join dbo.payment_request pr on (pr.code	 = ptd.payment_request_code)
	where		ptd.payment_transaction_code = @p_code
				and
				(
					ptd.payment_request_code	like '%' + @p_keywords + '%'
					or	ptd.orig_amount			like '%' + @p_keywords + '%'
					or	ptd.exch_rate			like '%' + @p_keywords + '%'
					or	ptd.tax_amount			like '%' + @p_keywords + '%'
					or	pr.payment_source_no	like '%' + @p_keywords + '%'
					or	pr.payment_source		like '%' + @p_keywords + '%'
					or	pr.payment_remarks		like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ptd.payment_request_code
													 when 2 then pr.payment_source_no
													 when 3 then pr.payment_source
													 when 4 then pr.payment_remarks
													 when 5 then cast(ptd.orig_amount as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													    when 1 then ptd.payment_request_code
														when 2 then pr.payment_source_no
														when 3 then pr.payment_source
														when 4 then pr.payment_remarks
														when 5 then cast(ptd.orig_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
