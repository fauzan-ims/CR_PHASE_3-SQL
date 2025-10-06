CREATE PROCEDURE dbo.xsp_faktur_allocation_detail_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_allocation_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	faktur_allocation_detail fad
	inner join dbo.invoice inv on (inv.invoice_no = fad.invoice_no)
	where	allocation_code = @p_allocation_code
	and		(
				fad.invoice_no												like '%' + @p_keywords + '%'
				or	fad.faktur_no											like '%' + @p_keywords + '%'
				or	inv.client_name											like '%' + @p_keywords + '%'
				or	inv.invoice_date										like '%' + @p_keywords + '%'
				or	inv.invoice_due_date									like '%' + @p_keywords + '%'
				or	inv.invoice_name										like '%' + @p_keywords + '%'
				or	inv.total_billing_amount - inv.total_discount_amount	like '%' + @p_keywords + '%'
				or	inv.invoice_external_no									like '%' + @p_keywords + '%'
			) ;

	select		id
				,allocation_code
				,inv.invoice_external_no
				,fad.invoice_no
				,fad.faktur_no
				,inv.client_name
				,convert(varchar(30), inv.invoice_date, 103) 'invoice_date'
				,convert(varchar(30), inv.invoice_due_date, 103) 'invoice_due_date'
				,inv.invoice_name
				,inv.total_billing_amount - inv.total_discount_amount 'total_billing_amount'
				,@rows_count 'rowcount'
	from		faktur_allocation_detail fad
	inner join dbo.invoice inv on (inv.invoice_no = fad.invoice_no)
	where	allocation_code = @p_allocation_code
	and		(
				fad.invoice_no												like '%' + @p_keywords + '%'
				or	fad.faktur_no											like '%' + @p_keywords + '%'
				or	inv.client_name											like '%' + @p_keywords + '%'
				or	inv.invoice_date										like '%' + @p_keywords + '%'
				or	inv.invoice_due_date									like '%' + @p_keywords + '%'
				or	inv.invoice_name										like '%' + @p_keywords + '%'
				or	inv.total_billing_amount - inv.total_discount_amount	like '%' + @p_keywords + '%'
				or	inv.invoice_external_no									like '%' + @p_keywords + '%'
			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then inv.invoice_external_no
													 when 2 then fad.faktur_no
													 when 3 then inv.client_name
													 when 4 then cast(inv.invoice_date as sql_variant)
													 when 5 then cast(inv.total_billing_amount - inv.total_discount_amount as sql_variant)

												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then inv.invoice_external_no
													 when 2 then fad.faktur_no
													 when 3 then inv.client_name
													 when 4 then cast(inv.invoice_date as sql_variant)
													 when 5 then cast(inv.total_billing_amount - inv.total_discount_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
