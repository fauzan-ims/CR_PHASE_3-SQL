
-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_supplier_selection_detail_getrow]
(
	@p_id bigint
)
as
begin
	select	ssd.id
			,ssd.selection_code
			,ssd.item_code
			,ssd.item_name
			,ssd.type_asset_code
			,ssd.item_category_code
			,ssd.item_category_name
			,ssd.item_merk_code
			,ssd.item_merk_name
			,ssd.item_model_code
			,ssd.item_model_name
			,ssd.item_type_code
			,ssd.item_type_name
			,ssd.supplier_code
			,ssd.supplier_name
			,ssd.amount
			,ssd.quotation_amount
			,ssd.quantity
			,ssd.quotation_quantity
			,ssd.total_amount
			,ssd.spesification
			,ssd.remark
			,ssd.tax_code
			,ssd.tax_name
			,ssd.ppn_amount
			,ssd.pph_amount
			,ssd.quotation_detail_id
			,ssd.supplier_selection_detail_status
			,ssd.discount_amount
			,ssd.unit_from
			,isnull(ssd.unit_available_status, 'READY')											 'unit_available_status'
			,ssd.offering
			,ssd.indent_days
			,(ssd.amount - ssd.discount_amount) * ssd.quantity + ssd.ppn_amount - ssd.pph_amount 'total_amount_after_tax'
			,ssd.bbn_name
			,ssd.bbn_location
			,ssd.bbn_address
			,ssd.deliver_to_address
	from	supplier_selection_detail			  ssd
			left join dbo.supplier_selection	  ss on (ss.code = ssd.selection_code)
			left join dbo.quotation_review_detail qrd on (qrd.id = ssd.quotation_detail_id)
	where	ssd.id = @p_id ;
end ;
