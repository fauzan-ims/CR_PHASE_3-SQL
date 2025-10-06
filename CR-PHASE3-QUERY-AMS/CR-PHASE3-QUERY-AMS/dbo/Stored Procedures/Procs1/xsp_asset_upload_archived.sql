CREATE PROCEDURE dbo.xsp_asset_upload_archived 
as
begin
	declare @msg							nvarchar(max)
			,@max_value						int	
			,@upload_no						nvarchar(250)
			,@company_code					nvarchar(50)
			,@file_name						nvarchar(250)
			,@status_upload					nvarchar(20)
			,@item_code						nvarchar(50)
			,@item_name						nvarchar(250)
			,@condition						nvarchar(50)
			,@barcode						nvarchar(50)
			,@status						nvarchar(20)
			,@po_no							nvarchar(50)
			,@requestor_code				nvarchar(50)
			,@requestor_name				nvarchar(250)
			,@vendor_code					nvarchar(50)
			,@vendor_name					nvarchar(250)
			,@type_code						nvarchar(50)
			,@category_code					nvarchar(50)
			,@purchase_date					datetime
			,@purchase_price				decimal(18, 2)
			,@invoice_no					nvarchar(50)
			,@invoice_date					datetime
			,@original_price				decimal(18, 2)
			,@sale_amount					decimal(18, 2)
			,@sale_date						datetime
			,@disposal_date					datetime
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@location_code					nvarchar(50)
			,@division_code					nvarchar(50)
			,@division_name					nvarchar(250)
			,@department_code				nvarchar(50)
			,@department_name				nvarchar(250)
			,@sub_department_code			nvarchar(50)
			,@sub_department_name			nvarchar(250)
			,@units_code					nvarchar(50)
			,@units_name					nvarchar(250)
			,@pic_code						nvarchar(50)
			,@residual_value				decimal(18, 2)
			,@depre_category_comm_code		nvarchar(50)
			,@total_depre_comm				decimal(18, 2)
			,@depre_period_comm				nvarchar(6)
			,@net_book_value_comm			decimal(18, 2)
			,@depre_category_fiscal_code	nvarchar(50)
			,@total_depre_fiscal			decimal(18, 2)
			,@depre_period_fiscal			nvarchar(6)
			,@net_book_value_fiscal			decimal(18, 2)
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
			,@last_service_date				datetime
			,@pph							decimal(18, 2)
			,@ppn							decimal(18, 2)
			,@remarks						nvarchar(4000)
			,@category_name					nvarchar(250)
			,@regional_code					nvarchar(50)
			,@regional_name					nvarchar(250)
			,@location_name					nvarchar(250)
			,@pic_name						nvarchar(250)
			,@last_used_by_code				nvarchar(50)
			,@last_used_by_name				nvarchar(250)
			,@last_location_code			nvarchar(50)
			,@last_location_name			nvarchar(250)
			,@cost_center_code				nvarchar(50)
			,@cost_center_name				nvarchar(250)
			,@po_date						datetime
			,@is_depre						nvarchar(1)
			,@last_so_date					datetime
			,@last_so_condition				nvarchar(100)
			--
			,@asset_code					nvarchar(50)
			,@description_detail			nvarchar(4000)
			--
			,@file_name_doc					nvarchar(250)
			,@path_doc						nvarchar(250)
			,@description_doc				nvarchar(400)
			,@cre_date						datetime
			,@cre_by						nvarchar(50)
			,@cre_ip_address				nvarchar(15)
			,@mod_date						datetime
			,@mod_by						nvarchar(50)
			,@mod_ip_address				nvarchar(15) ;

	begin try 
		declare @code_asset_upload as table
		(
			code nvarchar(50)
		)

		select	@max_value = cast(value as int)
		from	dbo.sys_global_param
		where	code = 'MAD'
		
		declare c_asset_upload_trx cursor fast_forward read_only for 
		select	upload_no
				,company_code
				,file_name
				,status_upload
				,item_code
				,item_name
				,condition
				,barcode
				,status
				,po_no
				,requestor_code
				,requestor_name
				,vendor_code
				,vendor_name
				,type_code
				,category_code
				,purchase_date
				,purchase_price
				,invoice_no
				,invoice_date
				,original_price
				,sale_amount
				,sale_date
				,disposal_date
				,branch_code
				,branch_name
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
				,residual_value
				,depre_category_comm_code
				,total_depre_comm
				,depre_period_comm
				,net_book_value_comm
				,depre_category_fiscal_code
				,total_depre_fiscal
				,depre_period_fiscal
				,net_book_value_fiscal
				,is_rental
				,opl_code
				,rental_date
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
				,use_life
				,last_meter
				,last_service_date
				,pph
				,ppn
				,remarks
				,category_name
				,regional_code
				,regional_name
				,location_name
				,pic_name
				,last_used_by_code
				,last_used_by_name
				,last_location_code
				,last_location_name
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
				,cost_center_code
				,cost_center_name
				,po_date
				,is_depre
				,last_so_date
				,last_so_condition
		from	dbo.asset_upload 
		where	status_upload in ('REJECT', 'CANCEL')
		and		status_upload <> 'POST'
		and		datediff(month,cre_date, dbo.xfn_get_system_date()) > @max_value ;

		open c_asset_upload_trx
		
		fetch next from c_asset_upload_trx 
		into	@upload_no
				,@company_code
				,@file_name
				,@status_upload
				,@item_code
				,@item_name
				,@condition
				,@barcode
				,@status
				,@po_no
				,@requestor_code
				,@requestor_name
				,@vendor_code
				,@vendor_name
				,@type_code
				,@category_code
				,@purchase_date
				,@purchase_price
				,@invoice_no
				,@invoice_date
				,@original_price
				,@sale_amount
				,@sale_date
				,@disposal_date
				,@branch_code
				,@branch_name
				,@location_code
				,@division_code
				,@division_name
				,@department_code
				,@department_name
				,@sub_department_code
				,@sub_department_name
				,@units_code
				,@units_name
				,@pic_code
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
				,@last_service_date
				,@pph
				,@ppn
				,@remarks
				,@category_name
				,@regional_code
				,@regional_name
				,@location_name
				,@pic_name
				,@last_used_by_code
				,@last_used_by_name
				,@last_location_code
				,@last_location_name
				,@cre_date
				,@cre_by
				,@cre_ip_address
				,@mod_date
				,@mod_by
				,@mod_ip_address
				,@cost_center_code
				,@cost_center_name
				,@po_date
				,@is_depre
				,@last_so_date
				,@last_so_condition
		
		while @@fetch_status = 0
		begin
		    
			exec dbo.xsp_asset_upload_history_insert @p_id							= 0
													,@p_upload_no					= @upload_no					
													,@p_company_code				= @company_code					
													,@p_file_name					= @file_name					
													,@p_status_upload				= @status_upload				
													,@p_item_code					= @item_code					
													,@p_item_name					= @item_name					
													,@p_condition					= @condition					
													,@p_barcode						= @barcode						
													,@p_status						= @status						
													,@p_po_no						= @po_no						
													,@p_requestor_code				= @requestor_code				
													,@p_requestor_name				= @requestor_name				
													,@p_vendor_code					= @vendor_code					
													,@p_vendor_name					= @vendor_name					
													,@p_type_code					= @type_code					
													,@p_category_code				= @category_code				
													,@p_purchase_date				= @purchase_date				
													,@p_purchase_price				= @purchase_price				
													,@p_invoice_no					= @invoice_no					
													,@p_invoice_date				= @invoice_date					
													,@p_original_price				= @original_price				
													,@p_sale_amount					= @sale_amount					
													,@p_sale_date					= @sale_date					
													,@p_disposal_date				= @disposal_date				
													,@p_branch_code					= @branch_code					
													,@p_branch_name					= @branch_name					
													,@p_location_code				= @location_code				
													,@p_division_code				= @division_code				
													,@p_division_name				= @division_name				
													,@p_department_code				= @department_code				
													,@p_department_name				= @department_name				
													,@p_sub_department_code			= @sub_department_code			
													,@p_sub_department_name			= @sub_department_name			
													,@p_units_code					= @units_code					
													,@p_units_name					= @units_name					
													,@p_pic_code					= @pic_code						
													,@p_residual_value				= @residual_value				
													,@p_depre_category_comm_code	= @depre_category_comm_code		
													,@p_total_depre_comm			= @total_depre_comm				
													,@p_depre_period_comm			= @depre_period_comm			
													,@p_net_book_value_comm			= @net_book_value_comm			
													,@p_depre_category_fiscal_code	= @depre_category_fiscal_code	
													,@p_total_depre_fiscal			= @total_depre_fiscal			
													,@p_depre_period_fiscal			= @depre_period_fiscal			
													,@p_net_book_value_fiscal		= @net_book_value_fiscal		
													,@p_is_rental					= @is_rental					
													,@p_opl_code					= @opl_code						
													,@p_rental_date					= @rental_date					
													,@p_contractor_name				= @contractor_name				
													,@p_contractor_address			= @contractor_address			
													,@p_contractor_email			= @contractor_email				
													,@p_contractor_pic				= @contractor_pic				
													,@p_contractor_pic_phone		= @contractor_pic_phone			
													,@p_contractor_start_date		= @contractor_start_date		
													,@p_contractor_end_date			= @contractor_end_date			
													,@p_warranty					= @warranty						
													,@p_warranty_start_date			= @warranty_start_date			
													,@p_warranty_end_date			= @warranty_end_date			
													,@p_remarks_warranty			= @remarks_warranty				
													,@p_is_maintenance				= @is_maintenance				
													,@p_maintenance_time			= @maintenance_time				
													,@p_maintenance_type			= @maintenance_type				
													,@p_maintenance_cycle_time		= @maintenance_cycle_time		
													,@p_maintenance_start_date		= @maintenance_start_date		
													,@p_use_life					= @use_life						
													,@p_last_meter					= @last_meter					
													,@p_last_service_date			= @last_service_date			
													,@p_pph							= @pph							
													,@p_ppn							= @ppn							
													,@p_remarks						= @remarks						
													,@p_category_name				= @category_name				
													,@p_regional_code				= @regional_code				
													,@p_regional_name				= @regional_name				
													,@p_location_name				= @location_name				
													,@p_pic_name					= @pic_name						
													,@p_last_used_by_code			= @last_used_by_code			
													,@p_last_used_by_name			= @last_used_by_name			
													,@p_last_location_code			= @last_location_code			
													,@p_last_location_name			= @last_location_name
													,@p_is_depre					= @is_depre
													,@p_cost_center_code			= @cost_center_code
													,@p_cost_center_name			= @cost_center_name
													,@p_po_date						= @po_date
													,@p_last_so_date				= @last_so_date
													,@p_last_so_condition			= @last_so_condition
													--
													,@p_cre_date					= @cre_date
													,@p_cre_by						= @cre_by
													,@p_cre_ip_address				= @cre_ip_address
													,@p_mod_date					= @mod_date
													,@p_mod_by						= @mod_by
													,@p_mod_ip_address				= @mod_ip_address	;
			
			
			-- asset electronic
			insert into dbo.asset_electronic_upload_history
			(
			    file_name
				,upload_no
				,asset_code
				,merk_code
				,merk_name
				,model_code
				,model_name
				,type_code
				,type_name
				,serial_no
				,dimension
				,hdd
				,processor
				,ram_size
				,domain
				,imei
				,purchase
				,remark
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	upl.file_name
					,upl.upload_no
					,upl.asset_code
					,upl.merk_code
					,upl.merk_name
					,upl.model_code
					,upl.model_name
					,upl.type_code
					,upl.type_name
					,upl.serial_no
					,upl.dimension
					,upl.hdd
					,upl.processor
					,upl.ram_size
					,upl.domain
					,upl.imei
					,upl.purchase
					,upl.remark
					,upl.cre_date
					,upl.cre_by
					,upl.cre_ip_address
					,upl.mod_date
					,upl.mod_by
					,upl.mod_ip_address
			from	dbo.asset_electronic_upload upl
					inner join dbo.asset_upload aup on aup.upload_no = upl.upload_no
			where	upl.upload_no = @upload_no
			and		aup.status_upload <> 'POST';

			-- asset furniture
			insert into dbo.asset_furniture_upload_history
			(
			    file_name
				,upload_no
				,asset_code
				,merk_code
				,merk_name
				,type_code
				,type_name
				,model_code
				,model_name
				,purchase
				,remark
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	upl.file_name
					,upl.upload_no
					,upl.asset_code
					,upl.merk_code
					,upl.merk_name
					,upl.type_code
					,upl.type_name
					,upl.model_code
					,upl.model_name
					,upl.purchase
					,upl.remark
					,upl.cre_date
					,upl.cre_by
					,upl.cre_ip_address
					,upl.mod_date
					,upl.mod_by
					,upl.mod_ip_address
			from	dbo.asset_furniture_upload  upl
					inner join dbo.asset_upload aup on aup.upload_no = upl.upload_no
			where	upl.upload_no = @upload_no
			and		aup.status_upload <> 'POST' ;

			-- asset machine
			insert into dbo.asset_machine_upload_history
			(
			    file_name
				,upload_no
				,asset_code
				,merk_code
				,merk_name
				,type_item_code
				,type_item_name
				,model_code
				,model_name
				,built_year
				,chassis_no
				,engine_no
				,colour
				,serial_no
				,purchase
				,remark
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	upl.file_name
					,upl.upload_no
					,upl.asset_code
					,upl.merk_code
					,upl.merk_name
					,upl.type_item_code
					,upl.type_item_name
					,upl.model_code
					,upl.model_name
					,upl.built_year
					,upl.chassis_no
					,upl.engine_no
					,upl.colour
					,upl.serial_no
					,upl.purchase
					,upl.remark
					,upl.cre_date
					,upl.cre_by
					,upl.cre_ip_address
					,upl.mod_date
					,upl.mod_by
					,upl.mod_ip_address
			from	dbo.asset_machine_upload upl
					inner join dbo.asset_upload aup on aup.upload_no = upl.upload_no
			where	upl.upload_no = @upload_no
			and		aup.status_upload <> 'POST';

			-- asset other
			insert into dbo.asset_other_upload_history
			(
			    file_name
				,upload_no
				,asset_code
				,remark
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	upl.file_name
					,upl.upload_no
					,upl.asset_code
					,upl.remark
					,upl.cre_date
					,upl.cre_by
					,upl.cre_ip_address
					,upl.mod_date
					,upl.mod_by
					,upl.mod_ip_address
			from	dbo.asset_other_upload upl
					inner join dbo.asset_upload aup on aup.upload_no = upl.upload_no
			where	upl.upload_no = @upload_no
			and		aup.status_upload <> 'POST';

			-- asset property
			insert into dbo.asset_property_upload_history
			(
			    file_name
				,upload_no
				,asset_code
				,imb_no
				,certificate_no
				,land_size
				,building_size
				,status_of_ruko
				,number_of_ruko_and_floor
				,total_square
				,vat
				,no_lease_agreement
				,date_of_lease_agreement
				,land_and_building_tax
				,security_deposit
				,penalty
				,owner
				,address
				,purchase
				,total_rental_period
				,rental_period
				,rental_price_per_year
				,rental_price_per_month
				,total_rental_price
				,start_rental_date
				,end_rental_date
				,remark
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	upl.file_name
					,upl.upload_no
					,upl.asset_code
					,upl.imb_no
					,upl.certificate_no
					,upl.land_size
					,upl.building_size
					,upl.status_of_ruko
					,upl.number_of_ruko_and_floor
					,upl.total_square
					,upl.vat
					,upl.no_lease_agreement
					,upl.date_of_lease_agreement
					,upl.land_and_building_tax
					,upl.security_deposit
					,upl.penalty
					,upl.owner
					,upl.address
					,upl.purchase
					,upl.total_rental_period
					,upl.rental_period
					,upl.rental_price_per_year
					,upl.rental_price_per_month
					,upl.total_rental_price
					,upl.start_rental_date
					,upl.end_rental_date
					,upl.remark
					,upl.cre_date
					,upl.cre_by
					,upl.cre_ip_address
					,upl.mod_date
					,upl.mod_by
					,upl.mod_ip_address
			from	dbo.asset_property_upload  upl
					inner join dbo.asset_upload aup on aup.upload_no = upl.upload_no
			where	upl.upload_no = @upload_no
			and		aup.status_upload <> 'POST' ;

			-- asset vehicle
			insert into dbo.asset_vehicle_upload_history
			(
			    file_name
				,upload_no
				,asset_code
				,merk_code
				,merk_name
				,type_code
				,type_name
				,model_code
				,plat_no
				,chassis_no
				,engine_no
				,bpkb_no
				,colour
				,cylinder
				,stnk_no
				,stnk_expired_date
				,stnk_tax_date
				,stnk_renewal
				,built_year
				,last_miles
				,last_maintenance_date
				,purchase
				,remark
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	upl.file_name
					,upl.upload_no
					,upl.asset_code
					,upl.merk_code
					,upl.merk_name
					,upl.type_code
					,upl.type_name
					,upl.model_code
					,upl.plat_no
					,upl.chassis_no
					,upl.engine_no
					,upl.bpkb_no
					,upl.colour
					,upl.cylinder
					,upl.stnk_no
					,upl.stnk_expired_date
					,upl.stnk_tax_date
					,upl.stnk_renewal
					,upl.built_year
					,upl.last_miles
					,upl.last_maintenance_date
					,upl.purchase
					,upl.remark
					,upl.cre_date
					,upl.cre_by
					,upl.cre_ip_address
					,upl.mod_date
					,upl.mod_by
					,upl.mod_ip_address
			from	dbo.asset_vehicle_upload upl
					inner join dbo.asset_upload aup on aup.upload_no = upl.upload_no
			where	upl.upload_no = @upload_no
			and		aup.status_upload <> 'POST';



			insert into @code_asset_upload
			(
			    code
			)
			values 
			(
				@upload_no
			)

		    fetch next from c_asset_upload_trx 
			into	@upload_no
					,@company_code
					,@file_name
					,@status_upload
					,@item_code
					,@item_name
					,@condition
					,@barcode
					,@status
					,@po_no
					,@requestor_code
					,@requestor_name
					,@vendor_code
					,@vendor_name
					,@type_code
					,@category_code
					,@purchase_date
					,@purchase_price
					,@invoice_no
					,@invoice_date
					,@original_price
					,@sale_amount
					,@sale_date
					,@disposal_date
					,@branch_code
					,@branch_name
					,@location_code
					,@division_code
					,@division_name
					,@department_code
					,@department_name
					,@sub_department_code
					,@sub_department_name
					,@units_code
					,@units_name
					,@pic_code
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
					,@last_service_date
					,@pph
					,@ppn
					,@remarks
					,@category_name
					,@regional_code
					,@regional_name
					,@location_name
					,@pic_name
					,@last_used_by_code
					,@last_used_by_name
					,@last_location_code
					,@last_location_name
					,@cre_date
					,@cre_by
					,@cre_ip_address
					,@mod_date
					,@mod_by
					,@mod_ip_address
					,@cost_center_code
					,@cost_center_name
					,@po_date
					,@is_depre
					,@last_so_date
					,@last_so_condition
		end
		
		close c_asset_upload_trx
		deallocate c_asset_upload_trx
		
		-- delete data
		delete	dbo.asset_upload 
		where	upload_no in (select upload_no collate latin1_general_ci_as from @code_asset_upload)
		and		status_upload <> 'POST' ;

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

