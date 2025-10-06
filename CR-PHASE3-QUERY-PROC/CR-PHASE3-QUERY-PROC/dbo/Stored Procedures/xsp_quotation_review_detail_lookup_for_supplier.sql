CREATE PROCEDURE [dbo].[xsp_quotation_review_detail_lookup_for_supplier]
(
	@p_keywords						nvarchar(50)
	,@p_pagenumber					int
	,@p_rowspage					int
	,@p_order_by					int
	,@p_sort_by						nvarchar(5)
	,@p_reff_no						nvarchar(50)
	,@p_procurement_code			nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.quotation_review_detail qrd
	inner join dbo.quotation_review qr on (qr.code collate latin1_general_ci_as = qrd.quotation_review_code)
	where	qr.code = @p_reff_no
	and		qrd.reff_no = @p_procurement_code
	and qrd.type = 'EXISTING'
	and		(
					qrd.supplier_name		like '%' + @p_keywords + '%'
					or	qrd.price_amount	like '%' + @p_keywords + '%'
					or	qrd.discount_amount	like '%' + @p_keywords + '%'
					or	qrd.quantity		like '%' + @p_keywords + '%'
					or	qrd.offering		like '%' + @p_keywords + '%'
					or	qrd.nett_price		like '%' + @p_keywords + '%'
			) ;

	select		qr.code
				,qrd.item_name
				,qrd.supplier_code
				,qrd.supplier_name
				,qrd.supplier_address
				,qrd.supplier_npwp
				,qrd.price_amount
				,qrd.quantity
				,qrd.reff_no
				,qrd.tax_code
				,qrd.tax_name
				,qrd.discount_amount
				,qrd.ppn_pct
				,qrd.pph_pct
				,qrd.unit_available_status
				,qrd.indent_days
				,qrd.offering
				,qrd.discount_amount
				,qrd.nett_price
				,@rows_count	'rowcount'
	from	dbo.quotation_review_detail qrd
	inner join dbo.quotation_review qr on (qr.code collate latin1_general_ci_as = qrd.quotation_review_code)
	where	qr.code = @p_reff_no
	and		qrd.reff_no = @p_procurement_code
	and qrd.type = 'EXISTING'
	and		(
					qrd.supplier_name		like '%' + @p_keywords + '%'
					or	qrd.price_amount	like '%' + @p_keywords + '%'
					or	qrd.discount_amount	like '%' + @p_keywords + '%'
					or	qrd.quantity		like '%' + @p_keywords + '%'
					or	qrd.offering		like '%' + @p_keywords + '%'
					or	qrd.nett_price		like '%' + @p_keywords + '%'
			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then qrd.supplier_name
													 when 2 then cast(qrd.price_amount as sql_variant)
													 when 3 then cast(qrd.discount_amount as sql_variant)
													 when 4 then cast(qrd.quantity as sql_variant)
													 when 5 then qrd.offering
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then qrd.supplier_name
													 when 2 then cast(qrd.price_amount as sql_variant)
													 when 3 then cast(qrd.discount_amount as sql_variant)
													 when 4 then cast(qrd.quantity as sql_variant)
													 when 5 then qrd.offering
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
