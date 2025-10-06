
-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_purchase_order_detail_getrows]
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_po_code	   nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	purchase_order_detail			   pod
			left join dbo.purchase_order	   po on (pod.po_code			   = po.code)
	where	pod.po_code = @p_po_code
			and (
						pod.item_name																							like '%' + @p_keywords + '%'
						or	pod.order_quantity																					like '%' + @p_keywords + '%'
						or	pod.price_amount																					like '%' + @p_keywords + '%'
						or	po.pph_amount																						like '%' + @p_keywords + '%'
						or	pod.ppn_amount																						like '%' + @p_keywords + '%'
						or	pod.order_remaining																					like '%' + @p_keywords + '%'
						or	pod.uom_name																						like '%' + @p_keywords + '%'
						or	pod.price_amount * pod.order_quantity																like '%' + @p_keywords + '%'
						or	pod.discount_amount																					like '%' + @p_keywords + '%'
						or	pod.spesification																					like '%' + @p_keywords + '%'
						or	(pod.price_amount - pod.discount_amount) * pod.order_quantity										like '%' + @p_keywords + '%'
						or	(pod.price_amount - pod.discount_amount) * pod.order_quantity + pod.ppn_amount - pod.pph_amount		like '%' + @p_keywords + '%'
						or	pod.bbn_name																						like '%' + @p_keywords + '%'
						or	pod.bbn_location																					like '%' + @p_keywords + '%'
						or	pod.bbn_address																						like '%' + @p_keywords + '%'
						or	pod.deliver_to_address																				like '%' + @p_keywords + '%'
				) ;

	select		pod.id
				,pod.po_code
				,pod.item_code
				,pod.item_name
				,pod.uom_code
				,pod.uom_name
				,pod.price_amount
				,pod.discount_amount
				,pod.order_quantity
				,pod.order_remaining
				,pod.description
				,pod.tax_code
				,pod.ppn_amount
				,pod.pph_amount
				,pod.invoice_no
				,pod.invoice_detail_id
				,(pod.price_amount - pod.discount_amount) * pod.order_quantity 'nett_amount'
				,(pod.price_amount - pod.discount_amount) * pod.order_quantity + pod.ppn_amount - pod.pph_amount 'total_amount'
				,pod.spesification
				,pod.bbn_name
				,pod.bbn_location
				,pod.bbn_address
				,pod.deliver_to_address
				,@rows_count	'rowcount'
	from		purchase_order_detail			   pod
				left join dbo.purchase_order	   po on (pod.po_code			   = po.code)
	where		pod.po_code = @p_po_code
				and (
						pod.item_name																							like '%' + @p_keywords + '%'
						or	pod.order_quantity																					like '%' + @p_keywords + '%'
						or	pod.price_amount																					like '%' + @p_keywords + '%'
						or	po.pph_amount																						like '%' + @p_keywords + '%'
						or	pod.ppn_amount																						like '%' + @p_keywords + '%'
						or	pod.order_remaining																					like '%' + @p_keywords + '%'
						or	pod.uom_name																						like '%' + @p_keywords + '%'
						or	pod.price_amount * pod.order_quantity																like '%' + @p_keywords + '%'
						or	pod.discount_amount																					like '%' + @p_keywords + '%'
						or	pod.spesification																					like '%' + @p_keywords + '%'
						or	(pod.price_amount - pod.discount_amount) * pod.order_quantity										like '%' + @p_keywords + '%'
						or	(pod.price_amount - pod.discount_amount) * pod.order_quantity + pod.ppn_amount - pod.pph_amount		like '%' + @p_keywords + '%'
						or	pod.bbn_name																						like '%' + @p_keywords + '%'
						or	pod.bbn_location																					like '%' + @p_keywords + '%'
						or	pod.bbn_address																						like '%' + @p_keywords + '%'
						or	pod.deliver_to_address																				like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then item_name
													 when 2 then cast(order_quantity as sql_variant)
													 when 3 then cast(pod.order_remaining as sql_variant)
													 when 4 then cast(price_amount as sql_variant)
													 when 5 then cast(pod.pph_amount as sql_variant)
													 when 6 then pod.spesification
													 when 7 then pod.bbn_name
													 when 8 then pod.deliver_to_address
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then item_name
													 when 2 then cast(order_quantity as sql_variant)
													 when 3 then cast(pod.order_remaining as sql_variant)
													 when 4 then cast(price_amount as sql_variant)
													 when 5 then cast(pod.pph_amount as sql_variant)
													 when 6 then pod.spesification
													 when 7 then pod.bbn_name
													 when 8 then pod.deliver_to_address
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
