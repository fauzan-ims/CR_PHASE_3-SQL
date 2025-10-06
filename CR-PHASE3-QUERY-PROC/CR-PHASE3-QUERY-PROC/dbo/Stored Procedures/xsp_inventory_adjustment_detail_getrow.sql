CREATE PROCEDURE dbo.xsp_inventory_adjustment_detail_getrow
(
	@p_id			bigint
) as
begin

	select	 iad.id
			,iad.inventory_adjustment_code
			,iad.item_code
			,iad.item_name
			,iad.plus_or_minus
			,iad.warehouse_code
			,mw.description 'warehouse_name'
			,iad.total_adjustment
			,iad.remark
	from	inventory_adjustment_detail iad
	left join dbo.master_warehouse mw on mw.code = iad.warehouse_code
	where	iad.id	= @p_id
end
