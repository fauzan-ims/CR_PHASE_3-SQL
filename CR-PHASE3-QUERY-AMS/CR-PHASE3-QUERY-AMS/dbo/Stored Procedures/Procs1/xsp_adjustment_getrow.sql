CREATE PROCEDURE dbo.xsp_adjustment_getrow
(
	@p_code			nvarchar(50)
) as
begin

	select	adj.code
			,adj.company_code
			,adj.branch_code
			,adj.branch_name
			,dbo.xfn_get_system_date()
			,adj.adjustment_type
			,adj.new_purchase_date
			,adj.description
			,adj.asset_code
			,adj.old_netbook_value_fiscal
			,adj.old_netbook_value_comm
			,adj.new_netbook_value_fiscal
			,adj.new_netbook_value_comm
			,adj.total_adjustment
			,adj.payment_by
			,adj.vendor_code
			,adj.vendor_name
			,adj.remark
			,adj.status
			,ast.barcode
			,ast.item_code
			,ast.item_name 'item_name'
			,ast.item_name 'asset_name'
			,ast.branch_code
			,ast.branch_name
			,ast.division_code
			,ast.division_name
			,ast.department_code
			,ast.department_name
			,ast.company_code
			,ast.net_book_value_comm
			,ast.net_book_value_fiscal
			,ast.original_price
			,ast.purchase_price 'purchase_price'
			,avh.plat_no
	from	adjustment adj
			inner join dbo.asset ast on (adj.asset_code = ast.code)
			left join dbo.asset_vehicle avh on (avh.asset_code = ast.code)
	where	adj.code = @p_code
end
