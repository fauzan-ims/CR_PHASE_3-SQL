CREATE PROCEDURE [dbo].[xsp_agreement_asset_getrow]
(
	@p_asset_no nvarchar(50)
)
as
begin
	declare @monthly_total_budget decimal(18, 2)
			,@asset_type		  nvarchar(20)
			,@transmisi			  nvarchar(50)
			,@color				  nvarchar(50)
			,@remarks			  nvarchar(4000)
			,@category_code		  nvarchar(50)
			,@category_desc		  nvarchar(250)
			,@sub_category_code	  nvarchar(50)
			,@sub_category_desc	  nvarchar(250)
			,@merk_code			  nvarchar(50)
			,@merk_desc			  nvarchar(250)
			,@model_code		  nvarchar(50)
			,@model_desc		  nvarchar(250)
			,@type_code			  nvarchar(50)
			,@type_desc			  nvarchar(250)
			,@unit_code			  nvarchar(50)
			,@unit_desc			  nvarchar(250)
			,@usefull_life		  int ;

	--select type asset
	select	@asset_type = asset_type_code
	from	dbo.agreement_asset
	where	asset_no = @p_asset_no ;

	if (@asset_type = 'VHCL') --jika asset type nya vehicle
	begin
		select	@transmisi = aav.transmisi
				,@color = aav.colour
				,@remarks = aav.remarks
				,@category_code = mvc.code
				,@category_desc = mvc.description
				,@sub_category_code = mvs.code
				,@sub_category_desc = mvs.description
				,@merk_code = mvm.code
				,@merk_desc = mvm.description
				,@model_code = mvmo.code
				,@model_desc = mvmo.description
				,@type_code = mvt.code
				,@type_desc = mvt.description
				,@unit_code = mvu.code
				,@unit_desc = mvu.description
				,@usefull_life = mvu.usefull_life
		from	dbo.application_asset_vehicle aav
				left join dbo.master_vehicle_category mvc on (mvc.code	  = aav.vehicle_category_code)
				left join dbo.master_vehicle_subcategory mvs on (mvs.code = aav.vehicle_subcategory_code)
				left join dbo.master_vehicle_merk mvm on (mvm.code		  = aav.vehicle_merk_code)
				left join dbo.master_vehicle_model mvmo on (mvmo.code	  = aav.vehicle_model_code)
				left join dbo.master_vehicle_type mvt on (mvt.code		  = aav.vehicle_type_code)
				left join dbo.master_vehicle_unit mvu on (mvu.code		  = aav.vehicle_unit_code)
		where	aav.asset_no = @p_asset_no ;
	end ;
	else if (@asset_type = 'ELEC') --jika type asset nya electric
	begin
		select	@color = aae.colour
				,@remarks = aae.remarks
				,@category_code = mec.code
				,@category_desc = mec.description
				,@sub_category_code = mes.code
				,@sub_category_desc = mes.description
				,@merk_code = mem.code
				,@merk_desc = mem.description
				,@model_code = memo.code
				,@model_desc = memo.description
				,@unit_code = meu.code
				,@unit_desc = meu.description
				,@usefull_life = meu.usefull_life
		from	application_asset_electronic aae
				left join dbo.master_electronic_category mec on (mec.code	 = aae.electronic_category_code)
				left join dbo.master_electronic_subcategory mes on (mes.code = aae.electronic_subcategory_code)
				left join dbo.master_electronic_merk mem on (mem.code		 = aae.electronic_merk_code)
				left join dbo.master_electronic_model memo on (memo.code	 = aae.electronic_model_code)
				left join dbo.master_electronic_unit meu on (meu.code		 = aae.electronic_unit_code)
		where	aae.asset_no = @p_asset_no ;
	end ;
	else if (@asset_type = 'HE') --jika type asset nya heavy equipment
	begin
		select	@color = aah.colour
				,@remarks = aah.remarks
				,@category_code = mhc.code
				,@category_desc = mhc.description
				,@sub_category_code = mhs.code
				,@sub_category_desc = mhs.description
				,@merk_code = mhr.code
				,@merk_desc = mhr.description
				,@model_code = mhl.code
				,@model_desc = mhl.description
				,@type_code = mht.code
				,@type_desc = mht.description
				,@unit_code = mhu.code
				,@unit_desc = mhu.description
				,@usefull_life = mhu.usefull_life
		from	dbo.application_asset_he aah
				left join master_he_category mhc on (mhc.code	 = aah.he_category_code)
				left join master_he_subcategory mhs on (mhs.code = aah.he_subcategory_code)
				left join master_he_merk mhr on (mhr.code		 = aah.he_merk_code)
				left join master_he_model mhl on (mhl.code		 = aah.he_model_code)
				left join master_he_type mht on (mht.code		 = aah.he_type_code)
				left join master_he_unit mhu on (mhu.code		 = aah.he_unit_code)
		where	aah.asset_no = @p_asset_no ;
	end ;
	else if (@asset_type = 'MCHN') --jika type asset nya machine
	begin
		select	@color = aam.colour
				,@remarks = aam.remarks
				,@category_code = mmc.code
				,@category_desc = mmc.description
				,@sub_category_code = mms.code
				,@sub_category_desc = mms.description
				,@merk_code = mmr.code
				,@merk_desc = mmr.description
				,@model_code = mml.code
				,@model_desc = mml.description
				,@type_code = mmt.code
				,@type_desc = mmt.description
				,@unit_code = mmu.code
				,@unit_desc = mmu.description
				,@usefull_life = mmu.usefull_life
		from	dbo.application_asset_machine aam
				left join master_machinery_category mmc on (mmc.code	= aam.machinery_category_code)
				left join master_machinery_subcategory mms on (mms.code = aam.machinery_subcategory_code)
				left join master_machinery_merk mmr on (mmr.code		= aam.machinery_merk_code)
				left join master_machinery_model mml on (mml.code		= aam.machinery_model_code)
				left join master_machinery_type mmt on (mmt.code		= aam.machinery_type_code)
				left join master_machinery_unit mmu on (mmu.code		= aam.machinery_unit_code)
		where	aam.asset_no = @p_asset_no ;
	end ;

	select	aa.asset_no
			,aa.agreement_no
			,aa.asset_type_code
			,case
				 when aa.asset_type_code = 'VHCL' then 'Vehicle'
				 when aa.asset_type_code = 'MCHN' then 'Machinery'
				 when aa.asset_type_code = 'HE' then 'He'
				 when aa.asset_type_code = 'ELEC' then 'Electronic'
			 end 'asset_type_for_api'
			,sgs.description 'asset_type_name'
			,aa.asset_name
			,aa.asset_year
			,aa.asset_condition
			,aa.billing_to
			,aa.billing_to_name
			,aa.billing_to_area_no
			,aa.billing_to_phone_no
			,aa.billing_to_address
			,aa.billing_type
			,aa.billing_mode
			,aa.billing_mode_date
			,aa.is_purchase_requirement_after_lease
			,aa.deliver_to
			,aa.deliver_to_name
			,aa.deliver_to_area_no
			,aa.deliver_to_phone_no
			,aa.deliver_to_address
			,aa.market_value
			,aa.asset_amount
			,aa.asset_interest_rate
			,aa.asset_interest_amount
			,aa.asset_rv_pct
			,aa.asset_rv_amount
			,aa.periode
			,aa.lease_option
			,aa.cogs_amount
			,aa.basic_lease_amount
			,aa.margin_by
			,aa.margin_rate
			,aa.margin_amount
			,aa.additional_charge_rate
			,aa.additional_charge_amount
			,aa.lease_amount
			,aa.lease_round_type
			,aa.lease_round_amount
			,aa.lease_rounded_amount
			,aa.net_margin_amount
			,aa.replacement_fa_code
			,aa.replacement_fa_name
			,aa.replacement_end_date
			,aa.return_date
			,aa.return_status
			,aa.return_remark
			--,mvu.description 'unit_desc'
			,mbt.description 'billing_type_desc'
			,sgs2.description 'billing_to_faktur_type_desc'
			,convert(varchar(30), handover_bast_date, 103) 'handover_bast_date'
			,aa.billing_to_npwp
			,aa.first_payment_type
			,aa.npwp_name
			,aa.npwp_address
			,aa.is_auto_email
			,aa.email
			,aa.pickup_phone_area_no
			,aa.pickup_phone_no
			,aa.pickup_name
			,aa.pickup_address
			,aa.is_otr
			,aa.bbn_location_code
			,aa.bbn_location_description
			,aa.usage
			,aa.start_miles
			,aa.monthly_miles
			,aa.is_use_registration
			,aa.is_use_replacement
			,aa.is_use_maintenance
			,aa.fa_code + ' - ' + aa.fa_name + ' - ' + aa.fa_reff_no_01 'fa_name'
			,aa.fa_code
			,aa.fa_reff_no_01 'plat_no'
			,aa.fa_reff_no_02 'chassis_no'
			,aa.fa_reff_no_03 'engine_no'
			,aa.is_bbn_client
			,aa.client_bbn_name
			,aa.client_bbn_address
			,aa.pmt_amount
			,isnull(aa.total_budget_amount, 0) 'monthly_total_budget'
			,isnull(@transmisi, '') 'transmisi'
			,isnull(@color, '') 'colour'
			,isnull(@remarks, '') 'remarks'
			,isnull(@category_code, '') 'category_code'
			,isnull(@category_desc, '') 'category_desc'
			,isnull(@sub_category_code, '') 'subcategory_code'
			,isnull(@sub_category_desc, '') 'subcategory_desc'
			,isnull(@merk_code, '') 'merk_code'
			,isnull(@merk_desc, '') 'merk_desc'
			,isnull(@model_code, '') 'model_code'
			,isnull(@model_desc, '') 'model_desc'
			,isnull(@type_code, '') 'type_code'
			,isnull(@type_desc, '') 'type_desc'
			,isnull(@unit_code, '') 'unit_code'
			,isnull(@unit_desc, '') 'unit_desc'
			,isnull(@usefull_life, '') 'usefull_life'
			,aa.karoseri_amount
			,aa.discount_karoseri_amount
			,aa.accessories_amount
			,aa.discount_accessories_amount
			,aa.mobilization_amount
			,aa.borrowing_interest_amount
			,aa.borrowing_interest_rate
			,aa.billing_to_faktur_type
			,aa.discount_amount 'discount_amount'
			,aa.budget_maintenance_amount
			,aa.budget_insurance_amount
			,aa.budget_replacement_amount
			,aa.insurance_commission_amount
			,aa.budget_registration_amount
			,aa.spaf_amount 'spaf_amount'
			,aa.subvention_amount 'subvention_amount'
			,aa.average_asset_amount 'average_asset_amount'
			,aa.yearly_profit_amount 'yearly_profit_amount'
			,aa.roa_pct 'roa_pct'
			,aa.is_invoice_deduct_pph
			,aa.is_receipt_deduct_pph
			,aa.otr_amount
			-- fauzan 12-02-25 nambahin nitku
			,aa.client_nitku
			-- Louis Senin, 07 Juli 2025 16.35.54 --
			,unit_source
			,start_due_date
			,aa.PRORATE
			,is_change_billing_date
			,due_date_change_code
			-- Louis Senin, 07 Juli 2025 16.35.54 --
	from	agreement_asset aa
			inner join dbo.agreement_main am on (am.AGREEMENT_NO		= aa.AGREEMENT_NO)
			left join dbo.client_main cm on (cm.code					= am.client_no)
			left join dbo.client_personal_info cpi on (cpi.client_code	= cm.code)
			left join dbo.client_corporate_info cci on (cci.client_code = cm.code)
			left join dbo.client_address ca on (
												   ca.client_code		= cm.code
												   and ca.is_legal		= '1'
											   )
			left join dbo.client_doc cd on (
											   cd.client_code			= cm.code
											   and cd.doc_type_code		= 'TAXID'
										   )
			left join dbo.sys_general_subcode sgs on (sgs.code			= aa.asset_type_code)
			left join dbo.sys_general_subcode sgs2 on (sgs2.code		= aa.billing_to_faktur_type)
			left join dbo.master_billing_type mbt on (mbt.code			= aa.billing_type)
			LEFT JOIN dbo.DUE_DATE_CHANGE_DETAIL ON DUE_DATE_CHANGE_DETAIL.ASSET_NO = aa.ASSET_NO
	where	aa.asset_no = @p_asset_no ;
end ;
