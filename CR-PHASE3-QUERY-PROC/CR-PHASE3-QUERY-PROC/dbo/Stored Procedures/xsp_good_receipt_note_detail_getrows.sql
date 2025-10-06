
-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_good_receipt_note_detail_getrows]
(
	@p_keywords				   nvarchar(50)
	,@p_pagenumber			   int
	,@p_rowspage			   int
	,@p_order_by			   int
	,@p_sort_by				   nvarchar(5)
	,@p_good_receipt_note_code nvarchar(50)
)
as
begin
	declare @rows_count			  int = 0
			,@purchase_order_code nvarchar(50) ;

	select	@purchase_order_code = grn.purchase_order_code
	from	dbo.good_receipt_note_detail	grnd
			left join dbo.good_receipt_note grn on (grn.code = grnd.good_receipt_note_code)
	where	grnd.good_receipt_note_code = @p_good_receipt_note_code ;

	select	@rows_count = count(1)
	from	good_receipt_note_detail			 grnd
			left join dbo.good_receipt_note		 grn on (grn.code = grnd.good_receipt_note_code)
			inner join dbo.purchase_order_detail pod on pod.id	  = grnd.purchase_order_detail_id
	where	grnd.good_receipt_note_code = @p_good_receipt_note_code
			and
			(
				grnd.item_name				like '%' + @p_keywords + '%'
				or	grnd.po_quantity		like '%' + @p_keywords + '%'
				or	grnd.receive_quantity	like '%' + @p_keywords + '%'
				or	grnd.uom_name			like '%' + @p_keywords + '%'
				or	grnd.price_amount		like '%' + @p_keywords + '%'
				or	grnd.pph_amount			like '%' + @p_keywords + '%'
				or	grnd.ppn_amount			like '%' + @p_keywords + '%'
				or	grnd.spesification		like '%' + @p_keywords + '%'
				or	pod.bbn_name			like '%' + @p_keywords + '%'
				or	pod.bbn_location		like '%' + @p_keywords + '%'
				or	pod.bbn_address			like '%' + @p_keywords + '%'
				or	pod.deliver_to_address	like '%' + @p_keywords + '%'
			) ;

	select		grnd.id
				,grnd.good_receipt_note_code
				,grnd.item_code
				,grnd.item_name
				,grnd.uom_code
				,grnd.uom_name
				,grnd.price_amount
				,grnd.ppn_amount
				,grnd.pph_amount
				,grnd.po_quantity
				,grnd.receive_quantity
				,grnd.shipper_code
				,grnd.no_resi
				,grnd.type_asset_code
				,grnd.item_category_code
				,grnd.item_category_name
				,grnd.item_merk_code
				,grnd.item_merk_name
				,grnd.item_model_code
				,grnd.item_model_name
				,grnd.item_type_code
				,grnd.item_type_name
				,grnd.spesification
				,pod.bbn_name
				,pod.bbn_location
				,pod.bbn_address
				,pod.deliver_to_address
				,@rows_count 'rowcount'
	from		good_receipt_note_detail			 grnd
				left join dbo.good_receipt_note		 grn on (grn.code = grnd.good_receipt_note_code)
				inner join dbo.purchase_order_detail pod on pod.id	  = grnd.purchase_order_detail_id
	where		grnd.good_receipt_note_code = @p_good_receipt_note_code
				and
				(
					grnd.item_name				like '%' + @p_keywords + '%'
					or	grnd.po_quantity		like '%' + @p_keywords + '%'
					or	grnd.receive_quantity	like '%' + @p_keywords + '%'
					or	grnd.uom_name			like '%' + @p_keywords + '%'
					or	grnd.price_amount		like '%' + @p_keywords + '%'
					or	grnd.pph_amount			like '%' + @p_keywords + '%'
					or	grnd.ppn_amount			like '%' + @p_keywords + '%'
					or	grnd.spesification		like '%' + @p_keywords + '%'
					or	pod.bbn_name			like '%' + @p_keywords + '%'
					or	pod.bbn_location		like '%' + @p_keywords + '%'
					or	pod.bbn_address			like '%' + @p_keywords + '%'
					or	pod.deliver_to_address	like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 --when 1 then grnd.item_name
													 when 1 then cast(grnd.po_quantity as sql_variant)
													 --when 3 then cast(grnd.receive_quantity as sql_variant)
													 --when 4 then cast(grnd.price_amount as sql_variant)
													 --when 5 then cast(grnd.pph_amount as sql_variant)
													 --when 6 then cast(grnd.ppn_amount as sql_variant)
													 --when 7 then grnd.spesification
													 --when 8 then pod.bbn_name
													 --when 9 then pod.deliver_to_address
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													    --when 1 then grnd.item_name
														when 1 then cast(grnd.po_quantity as sql_variant)
														--when 3 then cast(grnd.receive_quantity as sql_variant)
														--when 4 then cast(grnd.price_amount as sql_variant)
														--when 5 then cast(grnd.pph_amount as sql_variant)
														--when 6 then cast(grnd.ppn_amount as sql_variant)
														--when 7 then grnd.spesification
														--when 8 then pod.bbn_name
														--when 9 then pod.deliver_to_address
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
