CREATE PROCEDURE dbo.xsp_asset_upload_post_for_temp
(
	@p_upload_no		nvarchar(50)
	,@p_company_code	nvarchar(50)
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg							nvarchar(max)
			,@date							datetime = getdate()
			,@status						nvarchar(20)
			,@asset_code					nvarchar(50) = ''
			,@item_code						nvarchar(50)
			,@item_name						nvarchar(250)
			,@condition						nvarchar(50)
			,@cost_center_code				nvarchar(50)
			,@cost_center_name				nvarchar(250)
			,@barcode						nvarchar(50)
			,@po_no							nvarchar(50)
			,@requestor_code				nvarchar(50)
			,@requestor_name				nvarchar(250)
			,@vendor_code					nvarchar(50)
			,@vendor_name					nvarchar(250)
			,@type_code						nvarchar(50)
			,@category_code					nvarchar(50)
			,@category_name					nvarchar(250)
			,@purchase_date					datetime
			,@purchase_price				decimal(18,2)
			,@invoice_no					nvarchar(50)
			,@invocie_date					datetime
			,@original_price				decimal(18,2)
			,@sale_amount					decimal(18,2)
			,@sale_date						datetime
			,@disposal_date					datetime
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@loaction_code					nvarchar(50)
			,@location_name					nvarchar(250)
			,@division_code					nvarchar(50)
			,@division_name					nvarchar(250)
			,@departement_code				nvarchar(50)
			,@departement_name				nvarchar(250)
			,@sub_departement_code			nvarchar(50)
			,@sub_departement_name			nvarchar(250)
			,@unit_code						nvarchar(50)
			,@unit_name						nvarchar(250)
			,@pic_code						nvarchar(50)
			,@pic_name						nvarchar(250)
			,@residual_value				decimal(18,2)
			,@depre_category_comm_code		nvarchar(50)
			,@total_depre_comm				decimal(18,2)
			,@depre_period_comm				nvarchar(6)
			,@net_book_value_comm			decimal(18,2)
			,@depre_category_fiscal_code	nvarchar(50)
			,@total_depre_fiscal			decimal(18,2)
			,@depre_period_fiscal			nvarchar(6)
			,@net_book_value_fiscal			decimal(18,2)
			,@is_rental						nvarchar(1)
			,@opl_code						nvarchar(50)
			,@rental_date					datetime
			,@contractor_name				nvarchar(250)
			,@contractor_address			nvarchar(4000)
			,@contractor_email				nvarchar(50)
			,@contractor_pic				nvarchar(250)
			,@contractor_pic_phone			nvarchar(25)
			,@contractor_start_date			datetime
			,@contractor_end_date			datetime
			,@warranty						int				
			,@warranty_start_date			datetime
			,@warranty_end_date				datetime
			,@remarks_warranty				nvarchar(4000)
			,@is_maintenance				nvarchar(1)
			,@maintenance_time				int
			,@maintenance_type				nvarchar(50)
			,@maintenance_cycle_time		int		
			,@maintenance_start_date		datetime
			,@use_life						nvarchar(15)
			,@last_meter					nvarchar(15)
			,@last_used_by_code				nvarchar(50)
			,@last_used_by_name				nvarchar(250)
			,@last_location_code			nvarchar(50)
			,@last_location_name			nvarchar(250)
			,@last_service_date				datetime
			,@pph							decimal(18,2)
			,@ppn							decimal(18,2)
			,@remarks						nvarchar(4000)
			,@merk_code_vhcl				nvarchar(50)
			,@merk_name_vhcl				nvarchar(250)
			,@type_code_vhcl				nvarchar(50)
			,@type_name_vhcl				nvarchar(250)
			,@model_code_vhcl				nvarchar(50)
			,@model_name_vhcl				nvarchar(250)
			,@plat_no_vhcl					nvarchar(20)
			,@chasis_no_vhcl				nvarchar(50)
			,@engine_no_vhcl				nvarchar(50)
			,@bpkb_no_vhcl					nvarchar(50)
			,@colour_vhcl					nvarchar(50)
			,@cylynder_vhcl					nvarchar(50)
			,@stnk_no_vhcl					nvarchar(50)
			,@stnk_expired_date_vhcl		datetime
			,@stnk_tax_date_vhcl			datetime
			,@stnk_renewal_vhcl				nvarchar(15)
			,@built_year_vhcl				nvarchar(4)
			,@last_miles_vhcl				nvarchar(15)
			,@last_maintenance_date_vhcl	datetime
			,@purchase_vhcl					nvarchar(50)
			,@remark_vhcl					nvarchar(4000)
			,@merk_code_elct				nvarchar(50)
			,@merk_name_elct				nvarchar(250)
			,@type_code_elct				nvarchar(50)
			,@type_name_elct				nvarchar(250)
			,@model_code_elct				nvarchar(50)
			,@model_name_elct				nvarchar(250)
			,@serial_no_elct				nvarchar(50)
			,@dimension_elct				nvarchar(50)
			,@hdd_elct						nvarchar(10)
			,@processor_elct				nvarchar(10)
			,@ram_size_elct					nvarchar(8)
			,@domain_elct					nvarchar(100)
			,@imei_elct						nvarchar(100)
			,@purchase_elct					nvarchar(50)
			,@remark_elct					nvarchar(4000)
			,@merk_code_fntr				nvarchar(50)
			,@merk_name_fntr				nvarchar(250)
			,@type_code_fntr				nvarchar(50)
			,@type_name_fntr				nvarchar(250)
			,@model_code_fntr				nvarchar(50)
			,@model_name_fntr				nvarchar(250)
			,@purchase_fntr					nvarchar(50)
			,@remark_fntr					nvarchar(4000)
			,@merk_code_mchn				nvarchar(50)
		    ,@merk_name_mchn				nvarchar(250)
		    ,@type_code_mchn				nvarchar(50)
		    ,@type_name_mchn				nvarchar(250)
		    ,@model_code_mchn				nvarchar(50)
		    ,@model_name_mchn				nvarchar(50)
		    ,@built_year_mchn				nvarchar(4)
		    ,@chassis_no_mchn				nvarchar(50)
		    ,@engine_no_mchn				nvarchar(50)
		    ,@colour_mchn					nvarchar(50)
		    ,@serial_no_mchn				nvarchar(50)
		    ,@purchase_mchn					nvarchar(50)
		    ,@remark_mchn					nvarchar(4000)
			,@remark_othrs					nvarchar(4000)
			,@license_no_othrs				nvarchar(50)
			,@start_date_license_othrs		datetime
			,@end_date_license_othrs		datetime
			,@nominal_othrs					decimal
			,@imb_no_prty					nvarchar(50)
			,@certificate_no_prty			nvarchar(50)
			,@land_size_prty				decimal(18,2)
			,@building_size_prty			decimal(18,2)
			,@status_of_ruko_prty			nvarchar(50)
			,@number_of_ruko_and_floor_prty	nvarchar(50)
			,@total_square_prty				nvarchar(10)
			,@vat_prty						decimal(18,2)
			,@no_lease_agreement_prty		nvarchar(50)
			,@date_of_lease_agreement_prty	datetime
			,@land_and_building_tax_prty	nvarchar(50)
			,@security_deposit_prty			decimal(18,2)
			,@penalty_prty					decimal(18,2)
			,@owner_prty					nvarchar(250)
			,@address_prty					nvarchar(1000)						
			,@purchase_prty					nvarchar(50)
			,@total_rental_period_prty		nvarchar(9)
			,@rental_period_prty			nvarchar(15)
			,@rental_price_per_year_prty	decimal(18,2)
			,@rental_price_per_month_prty	decimal(18,2)
			,@total_rental_price_prty		decimal(18,2)
			,@start_rental_date_prty		datetime
			,@end_rental_date_prty			datetime
			,@remark_prty					nvarchar(4000)
			,@is_depre						nvarchar(1)
			,@po_date						datetime

	begin try
		declare curr_asset_upload cursor fast_forward read_only for

		select
			  au.status_upload 
			  ,au.item_code
			  ,au.item_name
			  ,au.condition
			  ,au.cost_center_code
			  ,au.cost_center_name
			  ,au.barcode
			  ,au.po_no
			  ,au.requestor_code
			  ,au.requestor_name
			  ,au.vendor_code
			  ,au.vendor_name
			  ,au.type_code
			  ,au.category_code
			  ,au.category_name
			  ,au.purchase_date
			  ,au.purchase_price
			  ,au.invoice_no
			  ,au.invoice_date
			  ,au.original_price
			  ,au.sale_amount
			  ,au.sale_date
			  ,au.disposal_date
			  ,au.branch_code
			  ,au.branch_name
			  ,au.location_code
			  ,au.LOCATION_NAME
			  ,au.division_code
			  ,au.division_name
			  ,au.department_code
			  ,au.department_name
			  ,au.sub_department_code
			  ,au.sub_department_name
			  ,au.units_code
			  ,au.units_name
			  ,au.pic_code
			  ,au.pic_name
			  ,au.residual_value
			  ,au.depre_category_comm_code
			  ,au.total_depre_comm
			  ,au.depre_period_comm
			  ,au.net_book_value_comm
			  ,au.depre_category_fiscal_code
			  ,au.total_depre_fiscal
			  ,au.depre_period_fiscal
			  ,au.net_book_value_fiscal
			  ,au.is_rental
			  ,au.opl_code
			  ,au.rental_date
			  ,au.contractor_name
			  ,au.contractor_address
			  ,au.contractor_email
			  ,au.contractor_pic
			  ,au.contractor_pic_phone
			  ,au.contractor_start_date
			  ,au.contractor_end_date
			  ,au.warranty
			  ,au.warranty_start_date
			  ,au.warranty_end_date
			  ,au.remarks_warranty
			  ,au.is_maintenance
			  ,au.maintenance_time
			  ,au.maintenance_type
			  ,au.maintenance_cycle_time
			  ,au.maintenance_start_date
			  ,au.use_life
			  ,au.last_meter
			  ,au.last_used_by_code
			  ,au.last_used_by_name
			  ,au.last_location_code
			  ,au.last_location_name
			  ,au.last_service_date
			  ,au.pph
			  ,au.ppn
			  ,au.remarks
			  ,avu.merk_code
			  ,avu.merk_name
			  ,avu.type_code
			  ,avu.type_name
			  ,avu.model_code
			  ,avu.MODEL_NAME
			  ,avu.plat_no
			  ,avu.chassis_no
			  ,avu.engine_no
			  ,avu.bpkb_no
			  ,avu.colour
			  ,avu.cylinder
			  ,avu.stnk_no
			  ,avu.stnk_expired_date
			  ,avu.stnk_tax_date
			  ,avu.stnk_renewal
			  ,avu.built_year
			  ,avu.last_miles
			  ,avu.last_maintenance_date
			  ,avu.purchase
			  ,avu.remark
			  ,aeu.merk_code
			  ,aeu.merk_name
			  ,aeu.type_code
			  ,aeu.type_name
			  ,aeu.model_code
			  ,aeu.model_name
			  ,aeu.serial_no
			  ,aeu.dimension
			  ,aeu.hdd
			  ,aeu.processor
			  ,aeu.ram_size
			  ,aeu.domain
			  ,aeu.imei
			  ,aeu.purchase
			  ,aeu.remark
			  ,afu.merk_code
			  ,afu.merk_name
			  ,afu.type_code
			  ,afu.type_name
			  ,afu.model_code
			  ,afu.model_name
			  ,afu.purchase
			  ,afu.remark
			  ,amu.merk_code
			  ,amu.merk_name
			  ,amu.type_item_code
			  ,amu.type_item_name
			  ,amu.model_code
			  ,amu.model_name
			  ,amu.built_year
			  ,amu.chassis_no
			  ,amu.engine_no
			  ,amu.colour
			  ,amu.serial_no
			  ,amu.purchase
			  ,amu.remark
			  ,aou.remark
			  ,aou.license_no
			  ,aou.start_date_license
			  ,aou.end_date_license
			  ,aou.nominal
			  ,apu.imb_no
			  ,apu.certificate_no
			  ,apu.land_size
			  ,apu.building_size 
			  ,apu.status_of_ruko
			  ,apu.number_of_ruko_and_floor
			  ,apu.total_square
			  ,apu.vat
			  ,apu.no_lease_agreement
			  ,apu.date_of_lease_agreement
			  ,apu.land_and_building_tax
			  ,apu.security_deposit
			  ,apu.penalty
			  ,apu.owner
			  ,apu.address
			  ,apu.purchase
			  ,apu.total_rental_period
			  ,apu.rental_period
			  ,apu.rental_price_per_year
			  ,apu.rental_price_per_month
			  ,apu.total_rental_price
			  ,apu.start_rental_date
			  ,apu.end_rental_date
			  ,apu.remark
			  ,au.is_depre
			  ,au.po_date
		from dbo.asset_upload au
		left join dbo.asset_vehicle_upload avu on (avu.upload_no = au.upload_no)
		left join dbo.asset_electronic_upload aeu on (aeu.upload_no = au.upload_no)
		left join dbo.asset_furniture_upload afu on (afu.upload_no = au.upload_no)
		left join dbo.asset_machine_upload amu on (amu.upload_no = au.upload_no)
		left join dbo.asset_other_upload aou on (aou.upload_no = au.upload_no)
		left join dbo.asset_property_upload apu on (apu.upload_no = au.upload_no)
		where au.upload_no = @p_upload_no

		open curr_asset_upload
		
		fetch next from curr_asset_upload 
		into 
			@status
			,@item_code						
			,@item_name						
			,@condition
			,@cost_center_code
			,@cost_center_name					
			,@barcode						
			,@po_no							
			,@requestor_code				
			,@requestor_name				
			,@vendor_code					
			,@vendor_name					
			,@type_code						
			,@category_code	
			,@category_name				
			,@purchase_date					
			,@purchase_price				
			,@invoice_no					
			,@invocie_date					
			,@original_price				
			,@sale_amount					
			,@sale_date						
			,@disposal_date					
			,@branch_code					
			,@branch_name					
			,@loaction_code	
			,@location_name								
			,@division_code					
			,@division_name					
			,@departement_code				
			,@departement_name				
			,@sub_departement_code			
			,@sub_departement_name			
			,@unit_code						
			,@unit_name						
			,@pic_code
			,@pic_name						
			,@residual_value				
			,@depre_category_comm_code		
			,@total_depre_comm				
			,@depre_period_comm				
			,@net_book_value_comm			
			,@depre_category_fiscal_code	
			,@total_depre_fiscal			
			,@depre_period_fiscal			
			,@net_book_value_fiscal			
			,@is_rental						
			,@opl_code						
			,@rental_date					
			,@contractor_name				
			,@contractor_address			
			,@contractor_email				
			,@contractor_pic				
			,@contractor_pic_phone			
			,@contractor_start_date			
			,@contractor_end_date			
			,@warranty						
			,@warranty_start_date			
			,@warranty_end_date				
			,@remarks_warranty				
			,@is_maintenance				
			,@maintenance_time				
			,@maintenance_type				
			,@maintenance_cycle_time		
			,@maintenance_start_date		
			,@use_life						
			,@last_meter					
			,@last_used_by_code					
			,@last_used_by_name					
			,@last_location_code				
			,@last_location_name				
			,@last_service_date				
			,@pph							
			,@ppn							
			,@remarks
			,@merk_code_vhcl			
			,@merk_name_vhcl			
			,@type_code_vhcl			
			,@type_name_vhcl			
			,@model_code_vhcl
			,@model_name_vhcl		
			,@plat_no_vhcl				
			,@chasis_no_vhcl			
			,@engine_no_vhcl			
			,@bpkb_no_vhcl				
			,@colour_vhcl				
			,@cylynder_vhcl				
			,@stnk_no_vhcl				
			,@stnk_expired_date_vhcl	
			,@stnk_tax_date_vhcl		
			,@stnk_renewal_vhcl			
			,@built_year_vhcl			
			,@last_miles_vhcl			
			,@last_maintenance_date_vhcl
			,@purchase_vhcl				
			,@remark_vhcl
			,@merk_code_elct	
			,@merk_name_elct	
			,@type_code_elct	
			,@type_name_elct	
			,@model_code_elct	
			,@model_name_elct	
			,@serial_no_elct	
			,@dimension_elct	
			,@hdd_elct			
			,@processor_elct	
			,@ram_size_elct		
			,@domain_elct		
			,@imei_elct			
			,@purchase_elct		
			,@remark_elct
			,@merk_code_fntr	
			,@merk_name_fntr	
			,@type_code_fntr	
			,@type_name_fntr	
			,@model_code_fntr	
			,@model_name_fntr	
			,@purchase_fntr		
			,@remark_fntr
			,@merk_code_mchn	
			,@merk_name_mchn	
			,@type_code_mchn	
			,@type_name_mchn	
			,@model_code_mchn	
			,@model_name_mchn	
			,@built_year_mchn	
			,@chassis_no_mchn	
			,@engine_no_mchn	
			,@colour_mchn		
			,@serial_no_mchn	
			,@purchase_mchn		
			,@remark_mchn
			,@remark_othrs
			,@license_no_othrs			
			,@start_date_license_othrs	
			,@end_date_license_othrs	
			,@nominal_othrs				
			,@imb_no_prty					
			,@certificate_no_prty			
			,@land_size_prty				
			,@building_size_prty			
			,@status_of_ruko_prty			
			,@number_of_ruko_and_floor_prty	
			,@total_square_prty				
			,@vat_prty						
			,@no_lease_agreement_prty		
			,@date_of_lease_agreement_prty	
			,@land_and_building_tax_prty	
			,@security_deposit_prty			
			,@penalty_prty					
			,@owner_prty					
			,@address_prty					
			,@purchase_prty					
			,@total_rental_period_prty		
			,@rental_period_prty			
			,@rental_price_per_year_prty	
			,@rental_price_per_month_prty	
			,@total_rental_price_prty		
			,@start_rental_date_prty		
			,@end_rental_date_prty			
			,@remark_prty
			,@is_depre
			,@po_date
				

		while @@fetch_status = 0
		begin								
			if(@asset_code = '')
			begin
				exec dbo.xsp_asset_insert_for_upload @p_code						 = @asset_code output
													 ,@p_company_code				 = @p_company_code
													 ,@p_item_code					 = @item_code
													 ,@p_item_name					 = @item_name
													 ,@p_condition					 = @condition
													 ,@p_cost_center_code			 = @cost_center_code
													 ,@p_cost_center_name			 = @cost_center_name
													 ,@p_barcode					 = @barcode
													 ,@p_status						 = 'NEW'
													 ,@p_po_no						 = @po_no
													 ,@p_requestor_code				 = @requestor_code
													 ,@p_requestor_name				 = @requestor_name
													 ,@p_vendor_code				 = @vendor_code
													 ,@p_vendor_name				 = @vendor_name
													 ,@p_type_code					 = @type_code
													 ,@p_category_code				 = @category_code
													 ,@p_category_name				 = @category_name				
													 ,@p_purchase_date				 = @purchase_date
													 ,@p_purchase_price				 = @purchase_price
													 ,@p_invoice_no					 = @invoice_no
													 ,@p_invoice_date				 = @invocie_date
													 ,@p_original_price				 = @original_price
													 ,@p_sale_amount				 = @sale_amount
													 ,@p_sale_date					 = @sale_date
													 ,@p_disposal_date				 = @disposal_date
													 ,@p_branch_code				 = @branch_code
													 ,@p_branch_name				 = @branch_name
													 ,@p_location_code				 = @loaction_code
													 ,@p_location_name				 = @location_name
													 ,@p_division_code				 = @division_code
													 ,@p_division_name				 = @division_name
													 ,@p_department_code			 = @departement_code
													 ,@p_department_name			 = @departement_name
													 ,@p_sub_department_code		 = @sub_departement_code
													 ,@p_sub_department_name		 = @sub_departement_name
													 ,@p_units_code					 = @unit_code
													 ,@p_units_name					 = @unit_name
													 ,@p_pic_code					 = @pic_code
													 ,@p_pic_name					 = @pic_name
													 ,@p_residual_value				 = @residual_value
													 ,@p_is_depre					 = @is_depre
													 ,@p_depre_category_comm_code	 = @depre_category_comm_code
													 ,@p_total_depre_comm			 = @total_depre_comm
													 ,@p_depre_period_comm			 = @depre_period_comm
													 ,@p_net_book_value_comm		 = @net_book_value_comm
													 ,@p_depre_category_fiscal_code  = @depre_category_fiscal_code
													 ,@p_total_depre_fiscal			 = @total_depre_fiscal
													 ,@p_depre_period_fiscal		 = @depre_period_fiscal
													 ,@p_net_book_value_fiscal		 = @net_book_value_fiscal
													 ,@p_is_rental					 = @is_rental
													 ,@p_opl_code					 = @opl_code
													 ,@p_rental_date				 = @rental_date
													 ,@p_contractor_name			 = @contractor_name
													 ,@p_contractor_address			 = @contractor_address
													 ,@p_contractor_email			 = @contractor_email
													 ,@p_contractor_pic				 = @contractor_pic
													 ,@p_contractor_pic_phone		 = @contractor_pic_phone
													 ,@p_contractor_start_date		 = @contractor_start_date
													 ,@p_contractor_end_date		 = @contractor_end_date
													 ,@p_warranty					 = @warranty
													 ,@p_warranty_start_date		 = @warranty_start_date
													 ,@p_warranty_end_date			 = @warranty_end_date
													 ,@p_remarks_warranty			 = @remarks_warranty
													 ,@p_is_maintenance				 = @is_maintenance
													 ,@p_maintenance_time			 = @maintenance_time
													 ,@p_maintenance_type			 = @maintenance_type
													 ,@p_maintenance_cycle_time		 = @maintenance_cycle_time
													 ,@p_maintenance_start_date		 = @maintenance_start_date
													 ,@p_use_life					 = @use_life
													 ,@p_last_meter					 = @last_meter
													 ,@p_last_used_by_code			 = @last_used_by_code
													 ,@p_last_used_by_name			 = @last_used_by_name
													 ,@p_last_location_code			 = @last_location_code
													 ,@p_last_location_name			 = @last_location_name
													 ,@p_last_service_date			 = @last_service_date
													 ,@p_pph						 = @pph
													 ,@p_ppn						 = @ppn
													 ,@p_remarks					 = @remarks
													 ,@p_po_date					 = @po_date
													 ,@p_cre_date					 = @p_mod_date		
													 ,@p_cre_by						 = @p_mod_by			
													 ,@p_cre_ip_address				 = @p_mod_ip_address
													 ,@p_mod_date					 = @p_mod_date		
													 ,@p_mod_by						 = @p_mod_by			
													 ,@p_mod_ip_address				 = @p_mod_ip_address
													 
				
				--exec dbo.xsp_asset_insert @p_code						 = @asset_code output
				--						  ,@p_company_code				 = @p_company_code
				--						  ,@p_item_code					 = @item_code
				--						  ,@p_item_name					 = @item_name
				--						  ,@p_condition					 = @condition
				--						  ,@p_barcode					 = @barcode
				--						  ,@p_status					 = 'NEW'
				--						  ,@p_po_no						 = @po_no
				--						  ,@p_requestor_code			 = @requestor_code
				--						  ,@p_requestor_name			 = @requestor_name
				--						  ,@p_vendor_code				 = @vendor_code
				--						  ,@p_vendor_name				 = @vendor_name
				--						  ,@p_type_code					 = @type_code
				--						  ,@p_category_code				 = @category_code
				--						  ,@p_purchase_date				 = @purchase_date
				--						  ,@p_purchase_price			 = @purchase_price
				--						  ,@p_invoice_no				 = @invoice_no
				--						  ,@p_invoice_date				 = @invocie_date
				--						  ,@p_original_price			 = @original_price
				--						  ,@p_sale_amount				 = @sale_amount
				--						  ,@p_sale_date					 = @sale_date
				--						  ,@p_disposal_date				 = @disposal_date
				--						  ,@p_branch_code				 = @branch_code
				--						  ,@p_branch_name				 = @branch_name
				--						  ,@p_location_code				 = @loaction_code
				--						  ,@p_division_code				 = @division_code
				--						  ,@p_division_name				 = @division_name
				--						  ,@p_department_code			 = @departement_code
				--						  ,@p_department_name			 = @departement_name
				--						  ,@p_sub_department_code		 = @sub_departement_code
				--						  ,@p_sub_department_name		 = @sub_departement_name
				--						  ,@p_units_code				 = @unit_code
				--						  ,@p_units_name				 = @unit_name
				--						  ,@p_pic_code					 = @pic_code
				--						  ,@p_residual_value			 = @residual_value
				--						  ,@p_is_depre					 = ''
				--						  ,@p_depre_category_comm_code	 = @depre_category_comm_code
				--						  ,@p_total_depre_comm			 = @total_depre_comm
				--						  ,@p_depre_period_comm			 = @depre_period_comm
				--						  ,@p_net_book_value_comm		 = @net_book_value_comm
				--						  ,@p_depre_category_fiscal_code = @depre_category_fiscal_code
				--						  ,@p_total_depre_fiscal		 = @total_depre_fiscal
				--						  ,@p_depre_period_fiscal		 = @depre_period_fiscal
				--						  ,@p_net_book_value_fiscal		 = @net_book_value_fiscal
				--						  ,@p_is_rental					 = @is_rental
				--						  ,@p_opl_code					 = @opl_code
				--						  ,@p_rental_date				 = @rental_date
				--						  ,@p_contractor_name			 = @contractor_name
				--						  ,@p_contractor_address		 = @contractor_address
				--						  ,@p_contractor_email			 = @contractor_email
				--						  ,@p_contractor_pic			 = @contractor_pic
				--						  ,@p_contractor_pic_phone		 = @contractor_pic_phone
				--						  ,@p_contractor_start_date		 = @contractor_start_date
				--						  ,@p_contractor_end_date		 = @contractor_end_date
				--						  ,@p_warranty					 = @warranty
				--						  ,@p_warranty_start_date		 = @warranty_start_date
				--						  ,@p_warranty_end_date			 = @warranty_end_date
				--						  ,@p_remarks_warranty			 = @remarks_warranty
				--						  ,@p_is_maintenance			 = @is_maintenance
				--						  ,@p_maintenance_time			 = @maintenance_time
				--						  ,@p_maintenance_type			 = @maintenance_type
				--						  ,@p_maintenance_cycle_time	 = @maintenance_cycle_time
				--						  ,@p_maintenance_start_date	 = @maintenance_start_date
				--						  ,@p_use_life					 = @use_life
				--						  ,@p_last_meter				 = @last_meter
				--						  ,@p_last_used_by				 = @last_used_by
				--						  ,@p_last_location				 = @last_location
				--						  ,@p_last_service_date			 = @last_service_date
				--						  ,@p_pph						 = @pph
				--						  ,@p_ppn						 = @ppn
				--						  ,@p_remarks					 = @remarks
				--						  ,@p_cre_date					 = @p_mod_date		
				--						  ,@p_cre_by					 = @p_mod_by			
				--						  ,@p_cre_ip_address			 = @p_mod_ip_address
				--						  ,@p_mod_date					 = @p_mod_date		
				--						  ,@p_mod_by					 = @p_mod_by			
				--						  ,@p_mod_ip_address			 = @p_mod_ip_address
			
				if(@type_code = 'VHCL')
				begin
					exec dbo.xsp_asset_vehicle_insert @p_asset_code					 = @asset_code
												  ,@p_merk_code						 = @merk_code_vhcl
												  ,@p_merk_name						 = @merk_name_vhcl
												  ,@p_type_item_code						 = @type_code_vhcl
												  ,@p_type_item_name						 = @type_name_vhcl
												  ,@p_model_code					 = @model_code_vhcl
												  ,@p_model_name					 = @model_name_vhcl
												  ,@p_plat_no						 = @plat_no_vhcl
												  ,@p_chassis_no					 = @chasis_no_vhcl
												  ,@p_engine_no						 = @engine_no_vhcl
												  ,@p_bpkb_no						 = @bpkb_no_vhcl
												  ,@p_colour						 = @colour_vhcl
												  ,@p_cylinder						 = @cylynder_vhcl
												  ,@p_stnk_no						 = @stnk_no_vhcl
												  ,@p_stnk_expired_date				 = @stnk_expired_date_vhcl
												  ,@p_stnk_tax_date					 = @stnk_expired_date_vhcl
												  ,@p_stnk_renewal					 = @stnk_renewal_vhcl
												  ,@p_built_year					 = @built_year_vhcl
												  ,@p_last_miles					 = @last_miles_vhcl
												  ,@p_last_maintenance_date			 = @last_maintenance_date_vhcl
												  ,@p_purchase						 = @purchase_vhcl
												  ,@p_no_lease_agreement			 = ''
												  ,@p_date_of_lease_agreement		 = ''
												  ,@p_security_deposit				 = 0
												  ,@p_total_rental_period			 = ''
												  ,@p_rental_period					 = ''
												  ,@p_rental_price					 = 0
												  ,@p_total_rental_price			 = 0
												  ,@p_start_rental_date				 = ''
												  ,@p_end_rental_date				 = ''
												  ,@p_remark						 = @remark_vhcl
												  ,@p_cre_date						 = @p_mod_date		
												  ,@p_cre_by						 = @p_mod_by			
												  ,@p_cre_ip_address				 = @p_mod_ip_address
												  ,@p_mod_date						 = @p_mod_date		
												  ,@p_mod_by						 = @p_mod_by			
												  ,@p_mod_ip_address				 = @p_mod_ip_address
				end
					else if(@type_code = 'ELCT')
				begin
					exec dbo.xsp_asset_electronic_insert @p_asset_code					 = @asset_code
														 ,@p_merk_code					 = @merk_code_elct
														 ,@p_merk_name					 = @merk_name_elct
														 ,@p_type_item_code				 = @type_code_elct
														 ,@p_type_item_name				 = @type_name_elct
														 ,@p_model_code					 = @model_code_elct
														 ,@p_model_name					 = @model_name_elct
														 ,@p_serial_no					 = @serial_no_elct
														 ,@p_dimension					 = @dimension_elct
														 ,@p_hdd						 = @hdd_elct
														 ,@p_processor					 = @processor_elct
														 ,@p_ram_size					 = @ram_size_elct
														 ,@p_domain						 = @domain_elct
														 ,@p_imei						 = @imei_elct
														 ,@p_purchase					 = @purchase_elct
														 ,@p_no_lease_agreement			 = ''
														 ,@p_date_of_lease_agreement	 = ''
														 ,@p_security_deposit			 = 0
														 ,@p_total_rental_period		 = ''
														 ,@p_rental_period				 = ''
														 ,@p_rental_price				 = 0
														 ,@p_total_rental_price			 = 0
														 ,@p_start_rental_date			 = ''
														 ,@p_end_rental_date			 = ''
														 ,@p_remark						 = @remark_elct
														 ,@p_cre_date					 = @p_mod_date		
														 ,@p_cre_by						 = @p_mod_by			
														 ,@p_cre_ip_address				 = @p_mod_ip_address
														 ,@p_mod_date					 = @p_mod_date		
														 ,@p_mod_by						 = @p_mod_by			
														 ,@p_mod_ip_address				 = @p_mod_ip_address
				end
				else if(@type_code = 'FNTR')
				begin
					exec dbo.xsp_asset_furniture_insert @p_asset_code				 = @asset_code
													,@p_merk_code					 = @merk_code_fntr
													,@p_merk_name					 = @merk_name_fntr
													,@p_type_code					 = @type_code_fntr
													,@p_type_name					 = @type_name_fntr
													,@p_model_code					 = @model_code_fntr
													,@p_model_name					 = @model_name_fntr
													,@p_purchase					 = @purchase_fntr
													,@p_no_lease_agreement			 = ''
													,@p_date_of_lease_agreement		 = ''
													,@p_security_deposit			 = 0
													,@p_total_rental_period			 = ''
													,@p_rental_period				 = ''
													,@p_rental_price				 = 0
													,@p_total_rental_price			 = 0
													,@p_start_rental_date			 = ''
													,@p_end_rental_date				 = ''
													,@p_remark						 = ''
													,@p_cre_date					 = @p_mod_date		
													,@p_cre_by						 = @p_mod_by			
													,@p_cre_ip_address				 = @p_mod_ip_address
													,@p_mod_date					 = @p_mod_date		
													,@p_mod_by						 = @p_mod_by			
													,@p_mod_ip_address				 = @p_mod_ip_address
				end
				else if(@type_code = 'MCHN')
				begin
				print @colour_mchn
					exec dbo.xsp_asset_machine_insert @p_asset_code					 = @asset_code
												  ,@p_merk_code						 = @merk_code_mchn 
												  ,@p_merk_name						 = @merk_name_mchn
												  ,@p_type_item_code				 = @type_code_mchn
												  ,@p_type_item_name			     = @type_name_mchn
												  ,@p_model_code					 = @model_code_mchn
												  ,@p_model_name					 = @model_name_mchn
												  ,@p_built_year					 = @built_year_mchn
												  ,@p_chassis_no					 = @chassis_no_mchn
												  ,@p_engine_no						 = @engine_no_mchn
												  ,@p_colour						 = @colour_mchn
												  ,@p_serial_no						 = @serial_no_mchn
												  ,@p_purchase						 = @purchase_mchn
												  ,@p_no_lease_agreement			 = ''
												  ,@p_date_of_lease_agreement		 = ''
												  ,@p_security_deposit				 = 0
												  ,@p_total_rental_period			 = ''
												  ,@p_rental_period					 = ''
												  ,@p_rental_price					 = 0
												  ,@p_total_rental_price			 = 0
												  ,@p_start_rental_date				 = ''
												  ,@p_end_rental_date				 = ''
												  ,@p_remark						 = @remark_mchn
												  ,@p_cre_date						 = @p_mod_date		
												  ,@p_cre_by						 = @p_mod_by			
												  ,@p_cre_ip_address				 = @p_mod_ip_address
												  ,@p_mod_date						 = @p_mod_date		
												  ,@p_mod_by						 = @p_mod_by			
												  ,@p_mod_ip_address				 = @p_mod_ip_address
				end
				else if(@type_code = 'OTHR')
				begin

					exec dbo.xsp_asset_other_insert @p_asset_code					 = @asset_code
													,@p_remark						 = @remark_othrs
													,@p_license_no					 = @license_no_othrs			
													,@p_start_date_license			 = @start_date_license_othrs	
													,@p_end_date_license			 = @end_date_license_othrs	
													,@p_nominal						 = @nominal_othrs				
													,@p_cre_date					 = @p_mod_date		
													,@p_cre_by						 = @p_mod_by			
													,@p_cre_ip_address				 = @p_mod_ip_address
													,@p_mod_date					 = @p_mod_date		
													,@p_mod_by						 = @p_mod_by			
													,@p_mod_ip_address				 = @p_mod_ip_address
					
				end
				else if(@type_code = 'PRTY')
				begin
					exec dbo.xsp_asset_property_insert @p_asset_code				 = @asset_code
												   ,@p_imb_no						 = @imb_no_prty
												   ,@p_certificate_no				 = @certificate_no_prty
												   ,@p_land_size					 = @land_size_prty
												   ,@p_building_size				 = @building_size_prty
												   ,@p_status_of_ruko				 = @status_of_ruko_prty
												   ,@p_number_of_ruko_and_floor		 = @number_of_ruko_and_floor_prty
												   ,@p_total_square					 = @total_square_prty
												   ,@p_vat							 = @vat_prty
												   ,@p_no_lease_agreement			 = @no_lease_agreement_prty
												   ,@p_date_of_lease_agreement		 = @date_of_lease_agreement_prty
												   ,@p_land_and_building_tax		 = @land_and_building_tax_prty
												   ,@p_security_deposit				 = @security_deposit_prty
												   ,@p_penalty						 = @penalty_prty
												   ,@p_owner						 = @owner_prty
												   ,@p_address						 = @address_prty
												   ,@p_purchase						 = @purchase_prty
												   ,@p_total_rental_period			 = @total_rental_period_prty
												   ,@p_rental_period				 = @rental_period_prty
												   ,@p_rental_price_per_year		 = @rental_price_per_year_prty
												   ,@p_rental_price_per_month		 = @rental_price_per_month_prty
												   ,@p_total_rental_price			 = @total_rental_price_prty
												   ,@p_start_rental_date			 = @start_rental_date_prty
												   ,@p_end_rental_date				 = @end_rental_date_prty
												   ,@p_remark						 = @remark_prty
												   ,@p_cre_date						 = @p_mod_date		
												   ,@p_cre_by						 = @p_mod_by		
												   ,@p_cre_ip_address				 = @p_mod_ip_address
												   ,@p_mod_date						 = @p_mod_date		
												   ,@p_mod_by						 = @p_mod_by		
												   ,@p_mod_ip_address				 = @p_mod_ip_address
				end

				exec dbo.xsp_asset_mutation_history_insert @p_id							 = 0
														   ,@p_asset_code					 = @asset_code
														   ,@p_date							 = @date
														   ,@p_document_refference_no		 = @p_upload_no
														   ,@p_document_refference_type		 = 'UPE'
														   ,@p_usage_duration				 = 0
														   ,@p_from_branch_code				 = ''
														   ,@p_from_branch_name				 = ''
														   ,@p_to_branch_code				 = ''
														   ,@p_to_branch_name				 = ''
														   ,@p_from_location_code			 = ''
														   ,@p_to_location_code				 = ''
														   ,@p_from_pic_code				 = ''
														   ,@p_to_pic_code					 = ''
														   ,@p_from_division_code			 = ''
														   ,@p_from_division_name			 = ''
														   ,@p_to_division_code				 = ''
														   ,@p_to_division_name				 = ''
														   ,@p_from_department_code			 = ''
														   ,@p_from_department_name			 = ''
														   ,@p_to_department_code			 = ''
														   ,@p_to_department_name			 = ''
														   ,@p_from_sub_department_code		 = ''
														   ,@p_from_sub_department_name		 = ''
														   ,@p_to_sub_department_code		 = ''
														   ,@p_to_sub_department_name		 = ''
														   ,@p_from_unit_code				 = ''
														   ,@p_from_unit_name				 = ''
														   ,@p_to_unit_code					 = ''
														   ,@p_to_unit_name					 = ''
														   ,@p_cre_date						 = @p_mod_date	  
														   ,@p_cre_by						 = @p_mod_by		  
														   ,@p_cre_ip_address				 = @p_mod_ip_address
														   ,@p_mod_date						 = @p_mod_date	  
														   ,@p_mod_by						 = @p_mod_by		  
														   ,@p_mod_ip_address				 = @p_mod_ip_address
			end

		    fetch next from curr_asset_upload 
			into 
			@status
			,@item_code						
			,@item_name						
			,@condition	
			,@cost_center_code
			,@cost_center_name					
			,@barcode						
			,@po_no							
			,@requestor_code				
			,@requestor_name				
			,@vendor_code					
			,@vendor_name					
			,@type_code						
			,@category_code	
			,@category_name						
			,@purchase_date					
			,@purchase_price				
			,@invoice_no					
			,@invocie_date					
			,@original_price				
			,@sale_amount					
			,@sale_date						
			,@disposal_date					
			,@branch_code					
			,@branch_name					
			,@loaction_code	
			,@location_name								
			,@division_code					
			,@division_name					
			,@departement_code				
			,@departement_name				
			,@sub_departement_code			
			,@sub_departement_name			
			,@unit_code						
			,@unit_name						
			,@pic_code						
			,@pic_name						
			,@residual_value				
			,@depre_category_comm_code		
			,@total_depre_comm				
			,@depre_period_comm				
			,@net_book_value_comm			
			,@depre_category_fiscal_code	
			,@total_depre_fiscal			
			,@depre_period_fiscal			
			,@net_book_value_fiscal			
			,@is_rental						
			,@opl_code						
			,@rental_date					
			,@contractor_name				
			,@contractor_address			
			,@contractor_email				
			,@contractor_pic				
			,@contractor_pic_phone			
			,@contractor_start_date			
			,@contractor_end_date			
			,@warranty						
			,@warranty_start_date			
			,@warranty_end_date				
			,@remarks_warranty				
			,@is_maintenance				
			,@maintenance_time				
			,@maintenance_type				
			,@maintenance_cycle_time		
			,@maintenance_start_date		
			,@use_life						
			,@last_meter					
			,@last_used_by_code					
			,@last_used_by_name					
			,@last_location_code				
			,@last_location_name				
			,@last_service_date				
			,@pph							
			,@ppn							
			,@remarks
			,@merk_code_vhcl			
			,@merk_name_vhcl			
			,@type_code_vhcl			
			,@type_name_vhcl			
			,@model_code_vhcl
			,@model_name_vhcl			
			,@plat_no_vhcl				
			,@chasis_no_vhcl			
			,@engine_no_vhcl			
			,@bpkb_no_vhcl				
			,@colour_vhcl				
			,@cylynder_vhcl				
			,@stnk_no_vhcl				
			,@stnk_expired_date_vhcl	
			,@stnk_tax_date_vhcl		
			,@stnk_renewal_vhcl			
			,@built_year_vhcl			
			,@last_miles_vhcl			
			,@last_maintenance_date_vhcl
			,@purchase_vhcl				
			,@remark_vhcl
			,@merk_code_elct	
			,@merk_name_elct	
			,@type_code_elct	
			,@type_name_elct	
			,@model_code_elct	
			,@model_name_elct	
			,@serial_no_elct	
			,@dimension_elct	
			,@hdd_elct			
			,@processor_elct	
			,@ram_size_elct		
			,@domain_elct		
			,@imei_elct			
			,@purchase_elct		
			,@remark_elct
			,@merk_code_fntr	
			,@merk_name_fntr	
			,@type_code_fntr	
			,@type_name_fntr	
			,@model_code_fntr	
			,@model_name_fntr	
			,@purchase_fntr		
			,@remark_fntr
			,@merk_code_mchn	
			,@merk_name_mchn	
			,@type_code_mchn	
			,@type_name_mchn	
			,@model_code_mchn	
			,@model_name_mchn	
			,@built_year_mchn	
			,@chassis_no_mchn	
			,@engine_no_mchn	
			,@colour_mchn		
			,@serial_no_mchn	
			,@purchase_mchn		
			,@remark_mchn
			,@remark_othrs
			,@license_no_othrs			
			,@start_date_license_othrs	
			,@end_date_license_othrs	
			,@nominal_othrs				
			,@imb_no_prty					
			,@certificate_no_prty			
			,@land_size_prty				
			,@building_size_prty			
			,@status_of_ruko_prty			
			,@number_of_ruko_and_floor_prty	
			,@total_square_prty				
			,@vat_prty						
			,@no_lease_agreement_prty		
			,@date_of_lease_agreement_prty	
			,@land_and_building_tax_prty	
			,@security_deposit_prty			
			,@penalty_prty					
			,@owner_prty					
			,@address_prty					
			,@purchase_prty					
			,@total_rental_period_prty		
			,@rental_period_prty			
			,@rental_price_per_year_prty	
			,@rental_price_per_month_prty	
			,@total_rental_price_prty		
			,@start_rental_date_prty		
			,@end_rental_date_prty			
			,@remark_prty
			,@is_depre			
			,@po_date	
		end
		
		close curr_asset_upload
		deallocate curr_asset_upload


		if (@status = 'NEW')
		begin
			    update	dbo.asset_upload
				set		status_upload	= 'POST'
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	upload_no		= @p_upload_no ;	
		end
		else
		begin
			set @msg = 'Data Already POST';
			raiserror(@msg ,16,-1);
		end
		
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;	
end ;
