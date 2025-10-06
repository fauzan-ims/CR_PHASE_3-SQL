
-- Stored Procedure

-- Stored Procedure

CREATE procedure [dbo].[xsp_good_receipt_note_detail_getrow]
(
	@p_id bigint
)
as
begin
	select	grnd.id
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
			,grnd.purchase_order_detail_id
			,grn.status
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
			,grn.purchase_order_code
			,grn.cover_note_status
			,isnull(grnd.discount_amount, 0) 'discount_amount'
			,isnull(grnd.ppn_amount, 0)		 'ppn_amount'
			,isnull(grnd.pph_amount, 0)		 'pph_amount'
			--,(grnd.price_amount - grnd.discount_amount) * grnd.receive_quantity + grnd.ppn_amount - grnd.pph_amount 'total_amount'
			--,isnull(grnd.total_amount,((grnd.price_amount - grnd.discount_amount) * grnd.receive_quantity + grnd.ppn_amount - grnd.pph_amount)) 'total_amount' -- (+) Ari 2024-03-22 ket : add total amount
			,isnull(grnd.total_amount, 0)	 'total_amount'
			-- (+) Ari 2024-01-10 ket : add tax
			,grnd.master_tax_code			 'tax_code'
			,grnd.master_tax_description	 'tax_name'
			,grnd.master_tax_ppn_pct		 'ppn_pct'
			,grnd.master_tax_pph_pct		 'pph_pct'
			,pod.bbn_name
			,pod.bbn_location
			,pod.bbn_address
			,pod.deliver_to_address
	from	good_receipt_note_detail			 grnd
			inner join dbo.good_receipt_note	 grn on (grn.code = grnd.good_receipt_note_code)
			inner join dbo.purchase_order_detail pod on pod.id	  = grnd.purchase_order_detail_id
	where	grnd.id = @p_id ;
end ;
