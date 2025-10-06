CREATE PROCEDURE [dbo].[xsp_final_good_receipt_note_detail_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,final_good_receipt_note_code
			,good_receipt_note_detail_id
			,item_code
			,item_name
			,type_asset_code
			,item_category_code
			,item_category_name
			,item_merk_code
			,item_merk_name
			,item_model_code
			,item_model_name
			,item_type_code
			,item_type_name
			,uom_code
			,uom_name
			,price_amount
			,fgrnd.specification
			,po_quantity
			,receive_quantity
			,location_code
			,location_name
			,warehouse_code
			,warehouse_name
			,shipper_code
			,no_resi
			,fgrn.total_item
			,fgrn.date
	from	final_good_receipt_note_detail fgrnd
			inner join dbo.final_good_receipt_note fgrn on (fgrn.code = fgrnd.final_good_receipt_note_code)
	where	id = @p_id ;
end ;
