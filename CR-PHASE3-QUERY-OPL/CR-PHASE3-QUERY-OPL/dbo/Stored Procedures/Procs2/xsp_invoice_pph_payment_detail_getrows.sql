CREATE PROCEDURE dbo.xsp_invoice_pph_payment_detail_getrows
(
	@p_tax_payment_code	nvarchar(50)
	--
	,@p_keywords		nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	invoice_pph_payment_detail ipd
	inner join dbo.invoice ivc on (ivc.invoice_no = ipd.invoice_no)
	where	ipd.tax_payment_code = @p_tax_payment_code
	and		(
				ipd.invoice_no												like '%' + @p_keywords + '%'
				or	ivc.invoice_external_no									like '%' + @p_keywords + '%'
				or	ivc.invoice_name										like '%' + @p_keywords + '%'
				or	ivc.invoice_date										like '%' + @p_keywords + '%'
				or	ivc.invoice_due_date									like '%' + @p_keywords + '%'
				or	ivc.faktur_no											like '%' + @p_keywords + '%'
				or	ivc.currency_code										like '%' + @p_keywords + '%'
				or	ipd.pph_amount											like '%' + @p_keywords + '%'
				or	ivc.total_billing_amount - ivc.total_discount_amount	like '%' + @p_keywords + '%'
			) ;

	select		ipd.id
				,ipd.tax_payment_code
				,ipd.invoice_no
				,ivc.invoice_external_no
				,ivc.invoice_name
				,ipd.pph_amount
				,convert(varchar(30), ivc.invoice_date, 103) 'invoice_date'
				,convert(varchar(30), ivc.invoice_due_date, 103) 'invoice_due_date'
				,ivc.total_billing_amount - ivc.total_discount_amount 'rental_amount'
				,ivc.faktur_no
				,ivc.currency_code
				,@rows_count 'rowcount'
	from		invoice_pph_payment_detail ipd
	inner join dbo.invoice ivc on (ivc.invoice_no = ipd.invoice_no)
	where	ipd.tax_payment_code = @p_tax_payment_code
	and			(
					ipd.invoice_no												like '%' + @p_keywords + '%'
					or	ivc.invoice_external_no									like '%' + @p_keywords + '%'
					or	ivc.invoice_name										like '%' + @p_keywords + '%'
					or	ivc.invoice_date										like '%' + @p_keywords + '%'
					or	ivc.invoice_due_date									like '%' + @p_keywords + '%'
					or	ivc.faktur_no											like '%' + @p_keywords + '%'
					or	ivc.currency_code										like '%' + @p_keywords + '%'
					or	ipd.pph_amount											like '%' + @p_keywords + '%'
					or	ivc.total_billing_amount - ivc.total_discount_amount	like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ivc.invoice_external_no
													 when 2 then ivc.invoice_name
													 when 3 then cast(ivc.invoice_date as sql_variant)
													 when 4 then cast(ivc.invoice_due_date as sql_variant)
													 when 5 then cast(ivc.total_billing_amount - ivc.total_discount_amount as sql_variant)
													 when 6 then ivc.faktur_no
													 when 7 then ivc.currency_code
													 when 8 then ipd.pph_amount
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then ivc.invoice_external_no
													 when 2 then ivc.invoice_name
													 when 3 then cast(ivc.invoice_date as sql_variant)
													 when 4 then cast(ivc.invoice_due_date as sql_variant)
													 when 5 then cast(ivc.total_billing_amount - ivc.total_discount_amount as sql_variant)
													 when 6 then ivc.faktur_no
													 when 7 then ivc.currency_code
													 when 8 then ipd.pph_amount
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
