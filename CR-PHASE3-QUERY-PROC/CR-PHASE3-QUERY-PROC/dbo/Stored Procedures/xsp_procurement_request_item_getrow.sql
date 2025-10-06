CREATE PROCEDURE [dbo].[xsp_procurement_request_item_getrow]
(
	@p_id bigint
)
as
begin
	select	pri.id
			,pri.procurement_request_code
			,pri.item_code
			,pri.item_name
			,pri.quantity_request
			,pri.approved_quantity
			,pri.specification
			,pri.remark
			,pri.uom_code
			,pri.uom_name
			,pri.type_asset_code
			,pri.item_category_code
			,pri.item_category_name
			,pri.item_merk_code
			,pri.item_merk_name
			,pri.item_model_code
			,pri.item_model_name
			,pri.item_type_code
			,pri.item_type_name
			,pri.fa_code
			,pri.fa_name
			,avh.engine_no
			,avh.plat_no
			,avh.chassis_no
			,pri.category_type
			,pri.is_bbn
			,pri.bbn_name
			,pri.bbn_address
			,pri.subvention_amount
			,pri.is_recom
			,pri.bbn_location
			,pri.condition
	from	procurement_request_item pri
	left join ifinams.dbo.asset_vehicle avh on (avh.asset_code = pri.fa_code)
	where	id = @p_id ;
end ;
