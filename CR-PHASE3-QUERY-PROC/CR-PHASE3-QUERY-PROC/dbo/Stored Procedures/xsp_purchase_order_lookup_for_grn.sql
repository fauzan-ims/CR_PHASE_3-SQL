CREATE PROCEDURE dbo.xsp_purchase_order_lookup_for_grn
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
	from	purchase_order po
			left join dbo.purchase_order_detail pod on (pod.po_code = po.code)
	where	po.status = 'APPROVE'
			and pod.order_remaining <> 0
			and po.code not in
				(
					select	grn.purchase_order_code
					from	dbo.good_receipt_note grn
					where	grn.status		= 'HOLD' 
							or grn.status	= 'ON PROCESS'
				)
			and (
					po.code						like '%' + @p_keywords + '%'
					or	po.remark				like '%' + @p_keywords + '%'
					or	pod.price_amount		like '%' + @p_keywords + '%'
					or	po.supplier_name		like '%' + @p_keywords + '%'
					or	pod.order_quantity		like '%' + @p_keywords + '%'
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
				,po.remark
				,pod.price_amount
				,pod.order_quantity
				,po.unit_from
				,@rows_count							  'rowcount'
	from		purchase_order po
				left join dbo.purchase_order_detail pod on (pod.po_code = po.code)
	where		po.status = 'APPROVE'
				and pod.order_remaining <> 0
				and po.code not in
					(
						select	grn.purchase_order_code
						from	dbo.good_receipt_note grn
						where	grn.status		= 'HOLD' 
								or grn.status	= 'ON PROCESS'
					)
				and (
						po.code						like '%' + @p_keywords + '%'
						or	po.remark				like '%' + @p_keywords + '%'
						or	pod.price_amount		like '%' + @p_keywords + '%'
						or	po.supplier_name		like '%' + @p_keywords + '%'
						or	pod.order_quantity		like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then po.code collate sql_latin1_general_cp1_ci_as
													 when 2 then pod.order_quantity
													 when 3 then cast(pod.price_amount as sql_variant)
													 when 4 then po.supplier_name
													 when 5 then po.remark
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													    when 1 then po.code collate sql_latin1_general_cp1_ci_as
														when 2 then pod.order_quantity
														when 3 then cast(pod.price_amount as sql_variant)
														when 4 then po.supplier_name
														when 5 then po.remark
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
