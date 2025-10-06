CREATE PROCEDURE  [dbo].[xsp_asset_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	declare @msg		 nvarchar(max)
			,@type		 nvarchar(50)
			,@merk_code	 nvarchar(50)
			,@model_code nvarchar(50)
			,@table_name nvarchar(250)
			,@sp_name	 nvarchar(250) ;

	select	@table_name = table_name
			,@sp_name	= sp_name
	from	dbo.sys_report
	where	table_name = 'rpt_pengembalian_asset' ;

	select	@type = type_code
	from	dbo.asset
	where	code = @p_code ;

	if (@type = 'VHCL')
	begin
		select	@merk_code	 = merk_code
				,@model_code = model_code
		from	dbo.asset_vehicle
		where	asset_code = @p_code ;
	end ;
	else if (@type = 'ELCT')
	begin
		select	@merk_code	 = merk_code
				,@model_code = model_code
		from	dbo.asset_electronic
		where	asset_code = @p_code ;
	end ;
	else if (@type = 'FNTR')
	begin
		select	@merk_code	 = merk_code
				,@model_code = model_code
		from	dbo.asset_furniture
		where	asset_code = @p_code ;
	end ;
	else if (@type = 'MCHN')
	begin
		select	@merk_code	 = merk_code
				,@model_code = model_code
		from	dbo.asset_machine
		where	asset_code = @p_code ;
	end ;

	select	ass.code
			,ass.company_code
			,item_code
			,item_name
			,ass.condition
			,ass.barcode
			,case ass.status
				 when 'AVAILABLEONREPAIR' then 'AVAILABLE - ON REPAIR'
				 when 'INVALIDEXPENSE' then 'INVALID - EXPENSE'
				 when 'INVALIDINVENTORY' then 'INVALID - INVENTORY'
				 else ass.status
			 end												 'status'
			,po_no
			,ass.po_date
			,requestor_code
			,requestor_name
			,vendor_code
			,vendor_name
			,ass.type_code
			,sgs.description									 'type_asset_description'
			,category_code
			,ass.category_name									 'description_category'
			,purchase_date
			,purchase_price
			,ass.invoice_no
			,ass.invoice_date
			,original_price
			,sale_amount
			,sale_date
			,disposal_date
			,ass.branch_code
			,ass.branch_name
			,ass.division_code
			,ass.division_name
			,ass.department_code
			,ass.department_name
			,pic_code
			--,scum.name 'name'
			,ass.residual_value
			,ass.is_depre
			,depre_category_comm_code
			,mdcc.description									 'description_commercial'
			,total_depre_comm
			,depre_period_comm
			,net_book_value_comm
			,depre_category_fiscal_code
			,mdcf.description									 'description_fiscal'
			,total_depre_fiscal
			,depre_period_fiscal
			,net_book_value_fiscal
			,ass.is_rental
			,contractor_name
			,ass.last_location_name								 'description_last_location'
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
			,ass.use_life
			,ass.last_meter
			,ass.last_service_date
			,ass.pph
			,ass.ppn
			,remarks
			,ass.last_so_date
			,ass.last_so_condition
			,@table_name										 'table_name'
			,@sp_name											 'sp_name'
			--(+) Saparudin : 03-10-2022
			,category_name
			,pic_name
			,last_used_by_code
			,last_used_by_name
			,last_location_code
			,last_location_name
			,ass.last_meter
			--(end) Saparudin : 03-10-2022
			,ass.is_lock
			,ass.is_permit_to_sell
			,ass.permit_sell_remark
			,ass.sell_request_amount
			,ass.asset_from
			,ass.asset_purpose
			,ass.merk_code
			,ass.merk_name
			,ass.model_code
			,ass.model_name
			,ass.type_code_asset
			,ass.type_name_asset
			,ass.item_group_code
			,ass.unit_province_code
			,ass.unit_province_name
			,ass.unit_city_code
			,ass.unit_city_name
			,ass.parking_location
			,ass.remark_update_location
			,ass.update_location_date
			,ass.reserved_by
			,ass.reserved_date
			,ass.process_status
			,ass.spaf_amount
			,ass.subvention_amount
			,ass.claim_spaf
			,ass.claim_spaf_date
			,ass.rental_status
			,case ass.activity_status
				 when '' then ''
				 else ass.ACTIVITY_STATUS + ' ON PROCESS'
			 end												 'activity_status'
			,ass.fisical_status
			,ass.agreement_external_no + ' - ' + ass.client_name 'agreement_client_name'
			,ass.wo_no
			,ass.wo_status
			,ipm.insured_name
			,policy.policy_no
			,policy.policy_eff_date
			,policy.policy_exp_date
			,ass.posting_date
			,ass.last_km_service
			,case ass.re_rent_status
				 when '' then 'NOT'
				 else ass.re_rent_status
			 end												 're_rent_status'
			,ass.old_purchase_price
			,ass.old_original_price
			,ass.old_net_book_value_commercial
			,ass.old_net_book_value_fiscal
			,ass.invoice_post_date
			,ass.invoice_return_date
			,ass.is_update_location
	from	asset										   ass
			left join dbo.sys_general_subcode			   sgs on (ass.type_code = sgs.code)
																  and	(sgs.company_code = ass.company_code)
			left join dbo.master_depre_category_commercial mdcc on (mdcc.code = ass.depre_category_comm_code)
																   and (mdcc.company_code = ass.company_code)
			left join dbo.master_depre_category_fiscal	   mdcf on (mdcf.code = ass.depre_category_fiscal_code)
																   and (mdcf.company_code = ass.company_code)
			left join dbo.insurance_policy_asset		   ipa on ipa.fa_code = ass.code
			left join dbo.insurance_policy_main			   ipm on ipm.code = ipa.policy_code
			outer apply
	(
		select	max(ipm.policy_exp_date)  'policy_exp_date'
				,max(ipm.policy_eff_date) 'policy_eff_date'
				,max(ipm.policy_no)		  'policy_no'
		from	dbo.insurance_policy_asset			 ipa
				inner join dbo.insurance_policy_main ipm on ipm.code = ipa.policy_code
		where	ipa.fa_code = ass.code
	)													   policy
	--left join dbo.insurance_policy_main ipm on (ass.code = ipm.fa_code)
	where	ass.code = @p_code ;
end ;
