CREATE PROCEDURE [dbo].[xsp_ap_invoice_registration_detail_getrows]
(
	@p_keywords				  nvarchar(50)
	,@p_pagenumber			  int
	,@p_rowspage			  int
	,@p_order_by			  int
	,@p_sort_by				  nvarchar(5)
	,@p_invoice_register_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select		@rows_count = count(1)
	from		ap_invoice_registration_detail ird
				inner join dbo.purchase_order_detail pod on (pod.id = ird.purchase_order_id)
	where		ird.invoice_register_code = @p_invoice_register_code
				and		ird.quantity <> 0
			and (
					ird.grn_code																like 	'%'+@p_keywords+'%'
					or	pod.po_code																like 	'%'+@p_keywords+'%'
					or	ird.item_name															like 	'%'+@p_keywords+'%'
					or	ird.quantity															like 	'%'+@p_keywords+'%'
					or	ird.qty_post															like 	'%'+@p_keywords+'%'
					or	ird.qty_grn - ird.qty_post												like 	'%'+@p_keywords+'%'
					or	ird.qty_invoice															like 	'%'+@p_keywords+'%'
					or	ird.uom_name															like 	'%'+@p_keywords+'%'
					or	ird.info_detail															like 	'%'+@p_keywords+'%'
					or	ird.purchase_amount														like 	'%'+@p_keywords+'%'
					or	ird.discount															like 	'%'+@p_keywords+'%'
					or	ird.purchase_amount - ird.discount										like 	'%'+@p_keywords+'%'
					or	ird.ppn																	like 	'%'+@p_keywords+'%'
					or	ird.pph																	like 	'%'+@p_keywords+'%'
					or	ird.total_amount														like 	'%'+@p_keywords+'%'
					or	ird.spesification														like 	'%'+@p_keywords+'%'
				);

	select		ird.id
				,ird.invoice_register_code
				,ird.grn_code
				,ird.currency_code
				,ird.item_code
				,ird.item_name
				,ird.purchase_amount 'purchase_amount'
				,ird.total_amount
				,ird.tax_code
				,ird.ppn
				,ird.pph 'pph'
				,ird.shipping_fee
				,ird.discount  'discount'
				,ird.branch_code
				,ird.branch_name
				,ird.division_code
				,ird.division_name
				,ird.department_code
				,ird.department_name 
				,ird.purchase_order_id
				,pod.po_code
				,ird.uom_code
				,ird.uom_name
				,ird.quantity 'quantity'
				,ird.quantity * ird.purchase_amount 'amount'
				,(ird.purchase_amount - ird.discount) * ird.quantity 'nett_amount'
				,ird.spesification
				,ird.info_detail
				,ird.qty_post
				,ird.qty_grn - ird.qty_post 'qty_outstanding' --qty_outstanding
				,ird.qty_invoice
				,ird.qty_grn
				,@rows_count 'rowcount'
	from		ap_invoice_registration_detail ird
				inner join dbo.purchase_order_detail pod on (pod.id = ird.purchase_order_id)
	where		ird.invoice_register_code = @p_invoice_register_code
				and (
					ird.grn_code																like 	'%'+@p_keywords+'%'
					or	pod.po_code																like 	'%'+@p_keywords+'%'
					or	ird.item_name															like 	'%'+@p_keywords+'%'
					or	ird.quantity															like 	'%'+@p_keywords+'%'
					or	ird.qty_post															like 	'%'+@p_keywords+'%'
					or	ird.qty_grn - ird.qty_post												like 	'%'+@p_keywords+'%'
					or	ird.qty_invoice															like 	'%'+@p_keywords+'%'
					or	ird.uom_name															like 	'%'+@p_keywords+'%'
					or	ird.info_detail															like 	'%'+@p_keywords+'%'
					or	ird.purchase_amount														like 	'%'+@p_keywords+'%'
					or	ird.discount															like 	'%'+@p_keywords+'%'
					or	ird.purchase_amount - ird.discount										like 	'%'+@p_keywords+'%'
					or	ird.ppn																	like 	'%'+@p_keywords+'%'
					or	ird.pph																	like 	'%'+@p_keywords+'%'
					or	ird.total_amount														like 	'%'+@p_keywords+'%'
					or	ird.spesification														like 	'%'+@p_keywords+'%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ird.grn_code
													 when 2 then pod.po_code
													 when 3 then ird.quantity
													 when 4 then ird.info_detail
													 when 5 then cast(purchase_amount as sql_variant)
													 when 6 then cast(ird.ppn as sql_variant)
													 when 7 then ird.spesification
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													    when 1 then ird.grn_code
														when 2 then pod.po_code
														when 3 then ird.quantity
														when 4 then ird.info_detail
														when 5 then cast(purchase_amount as sql_variant)
														when 6 then cast(ird.ppn as sql_variant)
														when 7 then ird.spesification
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
