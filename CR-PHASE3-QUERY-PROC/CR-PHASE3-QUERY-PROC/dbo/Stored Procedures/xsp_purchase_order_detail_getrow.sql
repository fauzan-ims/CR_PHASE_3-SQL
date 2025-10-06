
-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_purchase_order_detail_getrow]
(
	@p_id bigint
)
as
begin
	select	pod.id
			,pod.po_code
			,pod.item_code
			,pod.item_name
			,pod.type_asset_code
			,pod.item_category_code
			,pod.item_category_name
			,pod.item_merk_code
			,pod.item_merk_name
			,pod.item_model_code
			,pod.item_model_name
			,pod.item_type_code
			,pod.item_type_name
			,pod.uom_code
			,pod.uom_name
			,pod.price_amount
			,pod.discount_amount
			,pod.order_quantity
			,pod.order_remaining
			,pod.description
			,pod.tax_code
			,pod.tax_name
			,pod.ppn_amount
			,pod.pph_amount
			,pod.ppn_pct
			,pod.pph_pct
			,pod.invoice_no
			,pod.invoice_detail_id
			,pod.supplier_selection_detail_id
			,(pod.price_amount - pod.discount_amount) * pod.order_quantity + pod.ppn_amount - pod.pph_amount 'total_amount'
			,pod.eta_date
			,pod.initiation_eta_date
			,pod.spesification
			,pod.unit_available_status
			,pod.indent_days
			,pod.offering
			,pod.eta_date_remark
			,isnull(pr.procurement_type, pr2.procurement_type)												 'procurement_type'
			,isnull(pr.from_province_code, pr2.from_province_code)											 ' from_province_code'
			,isnull(pr.from_province_name, pr2.from_province_name)											 'from_province_name'
			,isnull(pr.from_city_code, pr2.from_city_code)													 'from_city_code'
			,isnull(pr.from_city_name, pr2.from_city_name)													 'from_city_name'
			,isnull(pr.from_area_phone_no, pr2.from_area_phone_no)											 'from_area_phone_no'
			,isnull(pr.from_phone_no, pr2.from_phone_no)													 'from_phone_no'
			,isnull(pr.from_address, pr2.from_address)														 'from_address'
			,isnull(pr.to_province_code, pr2.to_province_code)												 'to_province_code'
			,isnull(pr.to_province_name, pr2.to_province_name)												 'to_province_name'
			,isnull(pr.to_city_code, pr2.to_city_code)														 'to_city_code'
			,isnull(pr.to_city_name, pr2.to_city_name)														 'to_city_name'
			,isnull(pr.to_area_phone_no, pr2.to_area_phone_no)												 'to_area_phone_no'
			,isnull(pr.to_phone_no, pr2.to_phone_no)														 'to_phone_no'
			,isnull(pr.to_address, pr2.to_address)															 'to_address'
			,isnull(pri.category_type, pri2.category_type)													 'category_type'
			,pod.bbn_name
			,pod.bbn_location
			,pod.bbn_address
			,pod.deliver_to_address
	from	purchase_order_detail					pod
			left join dbo.purchase_order			po on (pod.po_code							  = po.code)
			left join dbo.supplier_selection_detail ssd on (ssd.id								  = pod.supplier_selection_detail_id)
			left join dbo.quotation_review_detail	qrd on (qrd.id								  = ssd.quotation_detail_id)
			left join dbo.procurement				prc on (prc.code collate Latin1_General_CI_AS = qrd.reff_no)
			left join dbo.procurement				prc2 on (prc2.code							  = ssd.reff_no)
			left join dbo.procurement_request		pr on (pr.code								  = prc.procurement_request_code)
			left join dbo.procurement_request		pr2 on (pr2.code							  = prc2.procurement_request_code)
			left join dbo.procurement_request_item	pri on (pr.code								  = pri.procurement_request_code)
			left join dbo.procurement_request_item	pri2 on (
																pri2.procurement_request_code	  = pr2.code
																and pri2.item_code				  = pod.item_code
															)
	where	pod.id = @p_id ;
end ;
