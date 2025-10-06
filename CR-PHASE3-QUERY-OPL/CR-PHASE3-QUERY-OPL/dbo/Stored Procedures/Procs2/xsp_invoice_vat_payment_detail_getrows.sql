CREATE PROCEDURE dbo.xsp_invoice_vat_payment_detail_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_tax_payment_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	invoice_vat_payment_detail ivpd
	inner join dbo.invoice inv on (inv.invoice_no = ivpd.invoice_no)
	where	tax_payment_code = @p_tax_payment_code
	and		(
				tax_payment_code											like '%' + @p_keywords + '%'
				or	ivpd.invoice_no											like '%' + @p_keywords + '%'
				or	inv.invoice_name										like '%' + @p_keywords + '%'
				or	convert(varchar(30),inv.invoice_date,103)				like '%' + @p_keywords + '%'
				or	convert(varchar(30),inv.invoice_due_date,103)			like '%' + @p_keywords + '%'
				or	inv.faktur_no											like '%' + @p_keywords + '%'
				or	inv.currency_code										like '%' + @p_keywords + '%'
				or	ppn_amount												like '%' + @p_keywords + '%'
				or	inv.total_billing_amount - inv.total_discount_amount	like '%' + @p_keywords + '%'
				or	inv.invoice_external_no									like '%' + @p_keywords + '%'
			) ;

	select		id
				,tax_payment_code
				,inv.invoice_external_no
				,ivpd.invoice_no
				,inv.invoice_name
				,convert(varchar(30),inv.invoice_date,103) 'invoice_date'
				,convert(varchar(30),inv.invoice_due_date,103) 'invoice_due_date'
				,inv.total_billing_amount - inv.total_discount_amount 'rental_amount'
				,inv.faktur_no
				,inv.currency_code
				,ppn_amount
				,@rows_count 'rowcount'
	from		invoice_vat_payment_detail ivpd
	inner join dbo.invoice inv on (inv.invoice_no = ivpd.invoice_no)
	where		tax_payment_code = @p_tax_payment_code
	and			(
					tax_payment_code											like '%' + @p_keywords + '%'
					or	ivpd.invoice_no											like '%' + @p_keywords + '%'
					or	inv.invoice_name										like '%' + @p_keywords + '%'
					or	convert(varchar(30),inv.invoice_date,103)				like '%' + @p_keywords + '%'
					or	convert(varchar(30),inv.invoice_due_date,103)			like '%' + @p_keywords + '%'
					or	inv.faktur_no											like '%' + @p_keywords + '%'
					or	inv.currency_code										like '%' + @p_keywords + '%'
					or	ppn_amount												like '%' + @p_keywords + '%'
					or	inv.total_billing_amount - inv.total_discount_amount	like '%' + @p_keywords + '%'
					or	inv.invoice_external_no									like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then inv.invoice_external_no
													 when 2 then inv.invoice_name
													 when 3 then cast(inv.invoice_date as sql_variant)
													 when 4 then cast(inv.invoice_due_date as sql_variant)
													 when 5 then cast(inv.total_billing_amount - inv.total_discount_amount as sql_variant)
													 when 6 then inv.faktur_no
													 when 7 then inv.currency_code
													 when 8 then ivpd.ppn_amount
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then inv.invoice_external_no
													 when 2 then inv.invoice_name
													 when 3 then cast(inv.invoice_date as sql_variant)
													 when 4 then cast(inv.invoice_due_date as sql_variant)
													 when 5 then cast(inv.total_billing_amount - inv.total_discount_amount as sql_variant)
													 when 6 then inv.faktur_no
													 when 7 then inv.currency_code
													 when 8 then ivpd.ppn_amount
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
