
-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_quotation_review_detail_getrow]
(
	@p_id bigint
)
as
begin
	select	pqrd.id
			,pqrd.quotation_review_code
			,pqrd.quotation_review_date
			,pqrd.reff_no
			,pqrd.branch_code
			,pqrd.branch_name
			,pqrd.currency_code
			,pqrd.currency_name
			,pqrd.payment_methode_code
			,pqrd.item_code
			,pqrd.item_name
			,pqrd.type_asset_code
			,pqrd.item_category_code
			,pqrd.item_category_name
			,pqrd.item_merk_code
			,pqrd.item_merk_name
			,pqrd.item_model_code
			,pqrd.item_model_name
			,pqrd.item_type_code
			,pqrd.item_type_name
			,pqrd.supplier_code
			,pqrd.supplier_name
			,pqrd.supplier_address
			,pqrd.tax_code
			,pqrd.tax_name
			,pqrd.ppn_pct
			,pqrd.pph_pct
			,pqrd.warranty_month
			,pqrd.warranty_part_month
			,pqrd.quantity
			,pqrd.approved_quantity
			,pqrd.uom_code
			,pqrd.uom_name
			,pqrd.price_amount
			,pqrd.discount_amount
			,pqrd.requestor_code
			,pqrd.requestor_name
			,pqrd.spesification
			,pqrd.remark
			,pqrd.unit_from
			,pqrd.unit_available_status
			,pqrd.indent_days
			,pqrd.offering
			,pqrd.expired_date
			,pqrd.total_amount
			,pqrd.nett_price
			,pqrd.supplier_npwp
			,pqrd.bbn_name
			,pqrd.bbn_location
			,pqrd.bbn_address
			,pqrd.deliver_to_address
	from	quotation_review_detail pqrd
	where	pqrd.id = @p_id ;
end ;
