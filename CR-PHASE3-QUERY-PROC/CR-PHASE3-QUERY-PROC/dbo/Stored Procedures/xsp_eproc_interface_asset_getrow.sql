CREATE PROCEDURE dbo.xsp_eproc_interface_asset_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	ass.code
			,ass.company_code
			,item_code
			,item_name
			,ass.condition
			,barcode
			,status
			,po_no
			,requestor_code
			,requestor_name
			,vendor_code
			,vendor_name
			,type_code
			,ass.type_name
			,sgs.description 'general_subcode_desc'
			,category_code
			,purchase_date
			,purchase_price
			,invoice_no
			,invoice_date
			,original_price
			,ass.branch_code
			,ass.branch_name
			,division_code
			,division_name
			,department_code
			,department_name
			,ass.category_name
	from	eproc_interface_asset ass
			left join dbo.sys_general_subcode sgs on ass.type_code			 = sgs.code
	where	ass.code = @p_code ;
end ;
