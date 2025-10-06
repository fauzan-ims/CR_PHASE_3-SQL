CREATE procedure dbo.xsp_efam_interface_asset_getrow
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
			,sgs.description 'general_subcode_desc'
			,category_code
			,mc.description 'description_category'
			,purchase_date
			,purchase_price
			,invoice_no
			,invoice_date
			,original_price
			,sale_amount
			,sale_date
			,disposal_date
			,ass.branch_code
			,ass.branch_name
			,location_code
			,division_code
			,division_name
			,department_code
			,department_name
			,sub_department_code
			,sub_department_name
			,units_code
			,units_name
			,pic_code
			,scum.name 'name'
			,residual_value
			,depre_category_comm_code
			,total_depre_comm
			,depre_period_comm
			,net_book_value_comm
			,depre_category_fiscal_code
			,total_depre_fiscal
			,depre_period_fiscal
			,net_book_value_fiscal
			,contractor_name
			,contractor_address
			,contractor_email
			,contractor_pic
			,contractor_pic_phone
			,contractor_start_date
			,contractor_end_date
			,warranty
			,warranty_start_date
			,warranty_end_date
			,remarks_warranty
			,is_maintenance
			,maintenance_time
			,maintenance_type
			,maintenance_cycle_time
			,maintenance_start_date
			,remarks
	from	efam_interface_asset ass
			left join dbo.sys_general_subcode sgs on ass.type_code			 = sgs.code
			left join dbo.master_category mc on (ass.category_code			 = mc.code)
			left join dbo.sys_company_user_main scum on (ass.pic_code		 = scum.code)
	where	ass.code = @p_code ;
end ;
