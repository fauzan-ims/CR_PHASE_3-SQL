CREATE PROCEDURE dbo.xsp_purchase_order_lookup_for_invoice
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
	from dbo.purchase_order po
	left join dbo.good_receipt_note grn on (grn.purchase_order_code = po.code)
	where	grn.reff_no is null
	and		(
					po.code					like '%' + @p_keywords + '%'
					or	po.order_date		like '%' + @p_keywords + '%'
					or	grn.branch_name		like '%' + @p_keywords + '%'
					or	po.supplier_name	like '%' + @p_keywords + '%'
			) ;

	select		po.code
				,convert(varchar(30), po.order_date, 103) 'order_date'
				,po.branch_code
				,po.branch_name
				,po.division_code
				,po.division_name
				,po.department_code
				,po.department_name
				,po.payment_by
				,po.total_amount
				,po.ppn_amount
				,po.pph_amount
				,po.currency_code
				,po.currency_name
				,po.supplier_code
				,po.supplier_name
				,po.unit_from
			--	,pod.discount_amount 'discount'
				,@rows_count 'rowcount'
	from dbo.purchase_order po
	left join dbo.good_receipt_note grn on (grn.purchase_order_code = po.code)
	--left join dbo.PURCHASE_ORDER_DETAIL pod on (po.CODE = pod.PO_CODE)
	where	grn.reff_no is null
	and		(
				po.code					like '%' + @p_keywords + '%'
				or	po.order_date		like '%' + @p_keywords + '%'
				or	grn.branch_name		like '%' + @p_keywords + '%'
				or	po.supplier_name	like '%' + @p_keywords + '%'
			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then po.code 
													 when 2 then convert(nvarchar(50), po.order_date, 103)
													 when 3 then po.supplier_name
													 when 4 then po.unit_from
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then po.code 
													   when 2 then convert(nvarchar(50), po.order_date, 103)
													   when 3 then po.supplier_name
													   when 4 then po.unit_from
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
