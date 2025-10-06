CREATE procedure [dbo].[xsp_asset_insert]
(
	@p_code						   nvarchar(50) output
	,@p_company_code			   nvarchar(50)
	,@p_item_code				   nvarchar(50)
	,@p_item_name				   nvarchar(250)
	,@p_item_group_code			   nvarchar(50)	  = null
	,@p_condition				   nvarchar(50)	  = ''
	,@p_barcode					   nvarchar(50)	  = ''
	,@p_status					   nvarchar(50)
	,@p_po_no					   nvarchar(50)	  = ''
	,@p_requestor_code			   nvarchar(50)	  = ''
	,@p_requestor_name			   nvarchar(250)  = ''
	,@p_vendor_code				   nvarchar(50)	  = ''
	,@p_vendor_name				   nvarchar(250)  = ''
	,@p_type_code				   nvarchar(50)	  = ''	--
	,@p_category_code			   nvarchar(50)	  = ''	--
	,@p_purchase_date			   datetime
	,@p_purchase_price			   decimal(18, 2)
	,@p_invoice_no				   nvarchar(50)	  = ''
	,@p_invoice_date			   datetime		  = null
	,@p_original_price			   decimal(18, 2)
	,@p_sale_amount				   decimal(18, 2) = 0
	,@p_sale_date				   datetime		  = null
	,@p_disposal_date			   datetime		  = null
	,@p_branch_code				   nvarchar(50)
	,@p_branch_name				   nvarchar(250)
	,@p_division_code			   nvarchar(50)	  = ''
	,@p_division_name			   nvarchar(250)  = ''
	,@p_department_code			   nvarchar(50)	  = ''
	,@p_department_name			   nvarchar(250)  = ''
	,@p_pic_code				   nvarchar(50)	  = ''
	,@p_residual_value			   decimal(18, 2) = 0
	,@p_is_depre				   nvarchar(1)	  = ''
	,@p_depre_category_comm_code   nvarchar(50)	  = ''	--
	,@p_total_depre_comm		   decimal(18, 2) = 0
	,@p_depre_period_comm		   nvarchar(6)	  = ''
	,@p_net_book_value_comm		   decimal(18, 2) = 0
	,@p_depre_category_fiscal_code nvarchar(50)	  = ''	--
	,@p_total_depre_fiscal		   decimal(18, 2) = 0
	,@p_depre_period_fiscal		   nvarchar(6)	  = ''
	,@p_net_book_value_fiscal	   decimal(18, 2) = 0
	,@p_is_rental				   nvarchar(1)	  = ''
	,@p_contractor_name			   nvarchar(250)  = ''
	,@p_contractor_address		   nvarchar(4000) = ''
	,@p_contractor_email		   nvarchar(50)	  = ''
	,@p_contractor_pic			   nvarchar(250)  = ''
	,@p_contractor_pic_phone	   nvarchar(25)	  = ''
	,@p_contractor_start_date	   datetime		  = null
	,@p_contractor_end_date		   datetime		  = null
	,@p_warranty				   int			  = 0
	,@p_warranty_start_date		   datetime		  = null
	,@p_warranty_end_date		   datetime		  = null
	,@p_remarks_warranty		   nvarchar(4000) = ''
	,@p_is_maintenance			   nvarchar(1)
	,@p_maintenance_time		   int			  = 0
	,@p_maintenance_type		   nvarchar(50)	  = ''
	,@p_maintenance_cycle_time	   int			  = 0
	,@p_maintenance_start_date	   datetime		  = null
	,@p_use_life				   nvarchar(15)	  = ''	--
	,@p_last_meter				   nvarchar(15)	  = ''
	,@p_last_service_date		   datetime		  = null
	,@p_pph						   decimal(9, 6)  = 0
	,@p_ppn						   decimal(9, 6)  = 0
	,@p_remarks					   nvarchar(4000) = ''
														--(+) Saparudin : 03-10-2022
	,@p_category_name			   nvarchar(250)  = ''
	,@p_pic_name				   nvarchar(250)  = ''
	,@p_last_used_by_code		   nvarchar(50)	  = ''
	,@p_last_used_by_name		   nvarchar(250)  = ''
	,@p_last_location_code		   nvarchar(50)	  = ''
	,@p_last_location_name		   nvarchar(250)  = ''
														--(END) Saparudin : 03-10-2022
	,@p_cost_center_code		   nvarchar(50)	  = ''
	,@p_cost_center_name		   nvarchar(250)  = ''
	,@p_is_po					   nvarchar(1)	  = ''
	,@p_is_lock					   nvarchar(1)	  = ''
	,@p_asset_purpose			   nvarchar(50)	  = ''
	,@p_asset_from				   nvarchar(50)	  = ''
	,@p_type_code_asset			   nvarchar(50)	  = ''
	,@p_model_code				   nvarchar(50)	  = ''
	,@p_merek_code				   nvarchar(50)	  = ''
	,@p_model_name				   nvarchar(250)  = ''
	,@p_merk_name				   nvarchar(250)  = ''
	,@p_type_name_asset			   nvarchar(250)  = ''
	,@p_unit_province_code		   nvarchar(50)	  = ''
	,@p_unit_province_name		   nvarchar(250)  = ''
	,@p_unit_city_code			   nvarchar(50)	  = ''
	,@p_unit_city_name			   nvarchar(250)  = ''
	,@p_parking_location		   nvarchar(250)  = ''
	,@p_process_status			   nvarchar(50)	  = ''
	,@p_spaf_amount				   decimal(18, 2) = null
	,@p_subvention_amount		   decimal(18, 2) = null
	,@p_claim_spaf				   nvarchar(50)	  = null
	,@p_claim_spaf_date			   datetime		  = null
														--(+) 12/12/2023 Raffy: penambahan field baru
	,@p_ppn_amount				   decimal(18, 2) = null
	,@p_pph_amount				   decimal(18, 2) = null
	,@p_discount_amount			   decimal(18, 2) = null
														--
	,@p_cre_date				   datetime
	,@p_cre_by					   nvarchar(15)
	,@p_cre_ip_address			   nvarchar(15)
	,@p_mod_date				   datetime
	,@p_mod_by					   nvarchar(15)
	,@p_mod_ip_address			   nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max)
			,@year			nvarchar(4)
			,@month			nvarchar(2)
			,@code			nvarchar(50)
			,@amt_threshold decimal(18, 2)
			-- Arga 12-Oct-2022 ket : for WOM (+)
			,@is_valid		int
			,@max_day		int
			,@value_type	nvarchar(50)
			,@region_code	nvarchar(50)
			,@region_name	nvarchar(250) ;

	begin try
		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			= @code output
													,@p_branch_code			= @p_branch_code
													,@p_sys_document_code	= ''
													,@p_custom_prefix		= 'ASM'
													,@p_year				= @year
													,@p_month				= @month
													,@p_table_name			= 'ASSET'
													,@p_run_number_length	= 5
													,@p_delimiter			= '.'
													,@p_run_number_only		= '0' ;

		if @p_is_maintenance = 'T'
			set @p_is_maintenance = '1' ;
		else
			set @p_is_maintenance = '0' ;

		if @p_is_rental = 'T'
			set @p_is_rental = '1' ;
		else
			set @p_is_rental = '0' ;

		select	@p_category_name			   = mc.description -- temporary 
				,@amt_threshold				   = depre_amount_threshold
				,@p_type_code				   = isnull(mc.asset_type_code, '')
				,@p_category_code			   = mc.code
				,@p_depre_category_comm_code   = mc.depre_cat_commercial_code
				,@p_depre_category_fiscal_code = mc.depre_cat_fiscal_code
				,@p_use_life				   = mdcc.usefull
				,@amt_threshold				   = mc.depre_amount_threshold
				,@value_type				   = mc.value_type
		from	dbo.master_category								mc
				inner join dbo.master_depre_category_commercial mdcc on mc.depre_cat_commercial_code = mdcc.code
		where	mc.code = @p_category_code ;

		if (@p_asset_from = 'BUY')
		begin
			select	@is_valid = dbo.xfn_depre_threshold_validation(@p_company_code, @p_category_code, @p_purchase_price) ;

			if @is_valid = 1
				set @p_is_depre = '1' ;
			else
				set @p_is_depre = '0' ;
		end ;

		-- Arga 03-Nov-2022 ket : for WOM to control amount value (+)
		set @is_valid = dbo.xfn_threshold_validation(@p_category_code, @p_purchase_price) ;

		select	@max_day = cast(value as int)
		from	dbo.sys_global_param
		where	code = 'MDT' ;

		if @is_valid = 0
		begin
			if @value_type = 'LOW VALUE'
				set @msg = N'For the Low Value category, the purchase price must be less than the threshold amount' ;
			else
				set @msg = N'For the High Value category, the purchase price must be greater than the threshold amount' ;

			raiserror(@msg, 16, -1) ;
		end ;

		-- End of additional control ===================================================
		insert into asset
		(
			code
			,company_code
			,item_code
			,item_name
			,item_group_code
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
			,division_code
			,division_name
			,department_code
			,department_name
			,pic_code
			,residual_value
			,is_depre
			,depre_category_comm_code
			,total_depre_comm
			,depre_period_comm
			,net_book_value_comm
			,depre_category_fiscal_code
			,total_depre_fiscal
			,depre_period_fiscal
			,net_book_value_fiscal
			,is_rental
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
			--(+) Saparudin : 03-10-2022
			,category_name
			,pic_name
			,last_used_by_code
			,last_used_by_name
			,last_location_code
			,last_location_name
			--(end) Saparudin : 03-10-2022
			,is_po
			,is_lock
			,asset_purpose
			,asset_from
			,model_code
			,model_name
			,merk_code
			,merk_name
			,type_code_asset
			,type_name_asset
			,unit_province_code
			,unit_province_name
			,unit_city_code
			,unit_city_name
			,parking_location
			,process_status
			,spaf_amount
			,subvention_amount
			,claim_spaf
			,claim_spaf_date
			,ppn_amount
			,pph_amount
			,discount_amount
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(
			@code
			,@p_company_code
			,@p_item_code
			,@p_item_name
			,@p_item_group_code
			,@p_condition
			,@p_barcode
			,@p_status
			,@p_po_no
			,@p_requestor_code
			,@p_requestor_name
			,@p_vendor_code
			,@p_vendor_name
			,@p_type_code
			,@p_category_code
			,@p_purchase_date
			,@p_purchase_price
			,@p_invoice_no
			,@p_invoice_date
			,@p_original_price
			,@p_sale_amount
			,@p_sale_date
			,@p_disposal_date
			,@p_branch_code
			,@p_branch_name
			,@p_division_code
			,@p_division_name
			,@p_department_code
			,@p_department_name
			,@p_pic_code
			,@p_residual_value
			,@p_is_depre
			,@p_depre_category_comm_code
			,@p_total_depre_comm
			,@p_depre_period_comm
					--,@p_net_book_value_comm
			,case
				 when @p_purchase_price >= @amt_threshold then @p_purchase_price
				 else 0
			 end	-- Arga 19-Oct-2022 ket : for WOM (+)
					--,@p_original_price -- Arga 19-Oct-2022 ket : for WOM (-) -- edit by bagas (otomatis keisi ketika insert harga original price) 9 September 2021
			,@p_depre_category_fiscal_code
			,@p_total_depre_fiscal
			,@p_depre_period_fiscal
					--,@p_net_book_value_fiscal
			,case
				 when @p_purchase_price >= @amt_threshold then @p_purchase_price
				 else 0
			 end	-- Arga 19-Oct-2022 ket : for WOM (+)
					--,@p_original_price -- Arga 19-Oct-2022 ket : for WOM (-) -- edit by bagas (otomatis keisi ketika insert harga original price) 9 September 2021
			,@p_is_rental
			,@p_contractor_name
			,@p_contractor_address
			,@p_contractor_email
			,@p_contractor_pic
			,@p_contractor_pic_phone
			,@p_contractor_start_date
			,@p_contractor_end_date
			,@p_warranty
			,@p_warranty_start_date
			,@p_warranty_end_date
			,@p_remarks_warranty
			,@p_is_maintenance
			,@p_maintenance_time
			,@p_maintenance_type
			,@p_maintenance_cycle_time
			,@p_maintenance_start_date
			,@p_use_life
			,@p_last_meter
			,@p_last_service_date
			,@p_pph
			,@p_ppn
			,@p_remarks
					--(+) Saparudin : 03-10-2022
			,@p_category_name
			,@p_pic_name
			,@p_last_used_by_code
			,@p_last_used_by_name
			,@p_last_location_code
			,@p_last_location_name
					--(end) Saparudin : 03-10-2022
			,'0'
			,'0'
			,@p_asset_purpose
			,@p_asset_from
			,@p_model_code
			,@p_model_name
			,@p_merek_code
			,@p_merk_name
			,@p_type_code_asset
			,@p_type_name_asset
			,@p_unit_province_code
			,@p_unit_province_name
			,@p_unit_city_code
			,@p_unit_city_name
			,@p_parking_location
			,@p_process_status
			,@p_spaf_amount
			,@p_subvention_amount
			,@p_claim_spaf
			,@p_claim_spaf_date
			,@p_ppn_amount
			,@p_pph_amount
			,@p_discount_amount
					--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		--Insert asset code sesuai @p_type_code
		if (@p_type_code = 'ELCT')
		begin
			exec dbo.xsp_asset_electronic_insert @code
												 ,@p_merek_code
												 ,@p_merk_name
												 ,@p_type_code_asset
												 ,@p_type_name_asset
												 ,@p_model_code
												 ,@p_model_name
												 ,null
												 ,null
												 ,null
												 ,null
												 ,null
												 ,null
												 ,null
												 ,null
												 ,@p_cre_date
												 ,@p_cre_by
												 ,@p_cre_ip_address
												 ,@p_mod_date
												 ,@p_mod_by
												 ,@p_mod_ip_address ;
		end ;
		else if (@p_type_code = 'FNTR')
		begin
			exec dbo.xsp_asset_furniture_insert @code
												,null
												,null
												,null
												,null
												,null
												,null
												,null
												,null
												,null
												,0
												,null
												,null
												,0
												,0
												,null
												,null
												,null
												,@p_cre_date
												,@p_cre_by
												,@p_cre_ip_address
												,@p_mod_date
												,@p_mod_by
												,@p_mod_ip_address ;
		end ;
		else if (@p_type_code = 'MCHN')
		begin
			exec dbo.xsp_asset_machine_insert @code
											  ,@p_merek_code
											  ,@p_merk_name
											  ,@p_type_code_asset
											  ,@p_type_name_asset
											  ,@p_model_code
											  ,@p_model_name
											  ,null
											  ,null
											  ,null
											  ,null
											  ,null
											  ,null
											  ,null
											  ,@p_cre_date
											  ,@p_cre_by
											  ,@p_cre_ip_address
											  ,@p_mod_date
											  ,@p_mod_by
											  ,@p_mod_ip_address ;
		end ;
		else if (@p_type_code = 'OTHR')
		begin
			exec dbo.xsp_asset_other_insert @p_asset_code = @code
											,@p_remark = ''
											,@p_license_no = ''
											,@p_start_date_license = null
											,@p_end_date_license = null
											,@p_nominal = 0
											,@p_cre_date = @p_cre_date
											,@p_cre_by = @p_cre_by
											,@p_cre_ip_address = @p_cre_ip_address
											,@p_mod_date = @p_mod_date
											,@p_mod_by = @p_mod_by
											,@p_mod_ip_address = @p_mod_ip_address ;
		end ;
		else if (@p_type_code = 'PRTY')
		begin
			exec dbo.xsp_asset_property_insert @code
											   ,null
											   ,null
											   ,0
											   ,0
											   ,null
											   ,null
											   ,null
											   ,0
											   ,null
											   ,null
											   ,null
											   ,0
											   ,0
											   ,null
											   ,null
											   ,null
											   ,null
											   ,null
											   ,0
											   ,0
											   ,0
											   ,null
											   ,null
											   ,null
											   ,@p_cre_date
											   ,@p_cre_by
											   ,@p_cre_ip_address
											   ,@p_mod_date
											   ,@p_mod_by
											   ,@p_mod_ip_address ;
		end ;
		else if (@p_type_code = 'VHCL')
		begin
			exec dbo.xsp_asset_vehicle_insert @code
											  ,@p_merek_code
											  ,@p_merk_name
											  ,@p_type_code_asset
											  ,@p_type_name_asset
											  ,@p_model_code
											  ,@p_model_name
											  ,null
											  ,null
											  ,null
											  ,null
											  ,null
											  ,null
											  ,null
											  ,null
											  ,null
											  ,null
											  ,null
											  ,null
											  ,null
											  ,null
											  ,null
											  ,null
											  ,null
											  ,null
											  ,@p_cre_date
											  ,@p_cre_by
											  ,@p_cre_ip_address
											  ,@p_mod_date
											  ,@p_mod_by
											  ,@p_mod_ip_address ;
		end ;
		else if (@p_type_code = 'HE')
		begin
			exec dbo.xsp_asset_he_insert @code
										 ,@p_merek_code
										 ,@p_merk_name
										 ,@p_type_code_asset
										 ,@p_type_name_asset
										 ,@p_model_code
										 ,@p_model_name
										 ,null
										 ,null
										 ,null
										 ,null
										 ,null
										 ,null
										 ,null
										 ,@p_cre_date
										 ,@p_cre_by
										 ,@p_cre_ip_address
										 ,@p_mod_date
										 ,@p_mod_by
										 ,@p_mod_ip_address ;
		end ;

		set @p_code = @code ;

		--insert ke barcode history
		if (@p_barcode <> '')
		begin
			exec dbo.xsp_asset_barcode_history_insert @p_id					= 0
													  ,@p_asset_code		= @p_code
													  ,@p_previous_barcode	= '-'
													  ,@p_new_barcode		= @p_barcode
													  ,@p_remark			= 'NEW BARCODE'
													  ,@p_cre_date			= @p_cre_date
													  ,@p_cre_by			= @p_cre_by
													  ,@p_cre_ip_address	= @p_cre_ip_address
													  ,@p_mod_date			= @p_mod_date
													  ,@p_mod_by			= @p_mod_by
													  ,@p_mod_ip_address	= @p_mod_ip_address ;
		end ;
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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
