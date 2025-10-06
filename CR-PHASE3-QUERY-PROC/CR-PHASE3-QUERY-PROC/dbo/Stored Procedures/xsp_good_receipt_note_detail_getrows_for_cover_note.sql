CREATE PROCEDURE dbo.xsp_good_receipt_note_detail_getrows_for_cover_note
(
	 @p_keywords					nvarchar(50)
	,@p_pagenumber					int
	,@p_rowspage					int
	,@p_order_by					int
	,@p_sort_by						nvarchar(5)
	,@p_good_receipt_note_code		nvarchar(50)
)	
as	
begin
	declare 	@rows_count int = 0 ;

	select 	@rows_count = count(1)
	from	good_receipt_note_detail grnd
	inner join dbo.good_receipt_note grn on (grn.code = grnd.good_receipt_note_code)
	inner join dbo.purchase_order			 po on (po.code								   = grn.purchase_order_code)
	inner join dbo.purchase_order_detail	 pod on (
														pod.po_code						   = po.code
														and pod.id						   = grnd.purchase_order_detail_id
													)
	inner join dbo.supplier_selection_detail ssd on (ssd.id								   = pod.supplier_selection_detail_id)
	left join dbo.quotation_review_detail	 qrd on (qrd.id								   = ssd.quotation_detail_id)
	inner join dbo.procurement				 prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
	inner join dbo.procurement_request		 pr on (prc.procurement_request_code		   = pr.code)
	inner join dbo.procurement_request_item	 pri on (
														pr.code							   = pri.procurement_request_code
														and pri.item_code				   = grnd.item_code
													)
	where	grnd.good_receipt_note_code = @p_good_receipt_note_code
			and pri.category_type		= 'ASSET'
			and pr.procurement_type = 'PURCHASE'
			and grnd.RECEIVE_QUANTITY <> 0
			and (
					grnd.item_name						like 	'%'+@p_keywords+'%'
					or	grnd.po_quantity				like 	'%'+@p_keywords+'%'
					or	grnd.receive_quantity			like 	'%'+@p_keywords+'%'
					or	grnd.uom_name					like 	'%'+@p_keywords+'%'
					or	grnd.price_amount				like 	'%'+@p_keywords+'%'
					or	grnd.spesification				like 	'%'+@p_keywords+'%'
		);

	select	 grnd.id
			,grnd.good_receipt_note_code
			,grnd.item_code
			,grnd.item_name
			,grnd.uom_code
			,grnd.uom_name
			,grnd.price_amount
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
			,@rows_count	 'rowcount'
	from	good_receipt_note_detail grnd
	inner join dbo.good_receipt_note grn on (grn.code = grnd.good_receipt_note_code)
	inner join dbo.purchase_order			 po on (po.code								   = grn.purchase_order_code)
	inner join dbo.purchase_order_detail	 pod on (
														pod.po_code						   = po.code
														and pod.id						   = grnd.purchase_order_detail_id
													)
	inner join dbo.supplier_selection_detail ssd on (ssd.id								   = pod.supplier_selection_detail_id)
	left join dbo.quotation_review_detail	 qrd on (qrd.id								   = ssd.quotation_detail_id)
	inner join dbo.procurement				 prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
	inner join dbo.procurement_request		 pr on (prc.procurement_request_code		   = pr.code)
	inner join dbo.procurement_request_item	 pri on (
														pr.code							   = pri.procurement_request_code
														and pri.item_code				   = grnd.item_code
													)
	where	grnd.good_receipt_note_code = @p_good_receipt_note_code
			and pri.category_type		= 'ASSET'
			and pr.procurement_type = 'PURCHASE'
			and grnd.RECEIVE_QUANTITY <> 0
			and (
					grnd.item_name						like 	'%'+@p_keywords+'%'
					or	grnd.po_quantity				like 	'%'+@p_keywords+'%'
					or	grnd.receive_quantity			like 	'%'+@p_keywords+'%'
					or	grnd.uom_name					like 	'%'+@p_keywords+'%'
					or	grnd.price_amount				like 	'%'+@p_keywords+'%'
					or	grnd.spesification				like 	'%'+@p_keywords+'%'
		)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
						when 1	then grnd.item_name
						when 2	then cast(grnd.po_quantity as sql_variant)
						when 3	then cast(grnd.receive_quantity as sql_variant)
						when 4	then grnd.uom_name
						when 5	then cast(grnd.price_amount as sql_variant)
						when 6	then grnd.spesification
					end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
						when 1	then grnd.item_name
						when 2	then cast(grnd.po_quantity as sql_variant)
						when 3	then cast(grnd.receive_quantity as sql_variant)
						when 4	then grnd.uom_name
						when 5	then cast(grnd.price_amount as sql_variant)
						when 6	then grnd.spesification
					end
			 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
