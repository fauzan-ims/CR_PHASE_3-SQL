
-- Stored Procedure

-- Stored Procedure

CREATE procedure [dbo].[xsp_procurement_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	p.code
			,procurement_request_item_id
			,procurement_request_code
			,procurement_request_date
			,p.branch_code
			,p.branch_name
			,p.item_code
			,p.item_name
			,p.item_type_code
			,p.item_type_name
			,p.quantity_request
			,p.approved_quantity
			,p.specification
			,p.remark
			,p.new_purchase
			,p.purchase_type_code
			,p.purchase_type_name
			,p.quantity_purchase
			,p.status
			,isnull(p.unit_from, 'BUY') 'unit_from'
			,p.item_group_code
			,p.requestor_code
			,p.requestor_name
			,pr.asset_no				'reff_no'
			,p.bbn_name
			,p.bbn_location
			,p.bbn_address
			,p.deliver_to_address
	from	procurement						   p
			inner join dbo.procurement_request pr on (pr.code = p.procurement_request_code)
	where	p.code = @p_code ;
end ;
