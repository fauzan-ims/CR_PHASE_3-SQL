CREATE PROCEDURE dbo.xsp_asset_all_upload_data_from_excel
(
	--@p_id						   bigint = 0 output
	--@p_upload_no				   nvarchar(50)
	@p_company_code				   nvarchar(50)
	,@p_status_upload			   nvarchar(20)
	,@p_item_code				   nvarchar(50)
	,@p_item_name				   nvarchar(250)
	,@p_condition				   nvarchar(50)		= ''
	,@p_barcode					   nvarchar(50)		= ''
	,@p_status					   nvarchar(20)
	,@p_po_no					   nvarchar(50)		= ''
	,@p_requestor_code			   nvarchar(50)		= ''
	,@p_requestor_name			   nvarchar(250)	= ''
	,@p_vendor_code				   nvarchar(50)
	,@p_vendor_name				   nvarchar(250)
	,@p_type_code				   nvarchar(50)		= ''
	,@p_category_code			   nvarchar(50)		= ''
	,@p_purchase_date			   datetime
	,@p_purchase_price			   decimal(18, 2)
	,@p_invoice_no				   nvarchar(50)
	,@p_invoice_date			   datetime
	,@p_original_price			   decimal(18, 2)
	,@p_sale_amount				   decimal(18, 2)	= 0
	,@p_sale_date				   datetime			= null
	,@p_disposal_date			   datetime			= null
	,@p_branch_code				   nvarchar(50)
	,@p_branch_name				   nvarchar(250)
	,@p_location_code			   nvarchar(50)
	,@p_division_code			   nvarchar(50)		= ''
	,@p_division_name			   nvarchar(250)	= ''
	,@p_department_code			   nvarchar(50)		= ''
	,@p_department_name			   nvarchar(250)	= ''
	,@p_sub_department_code		   nvarchar(50)		= ''
	,@p_sub_department_name		   nvarchar(250)	= ''
	,@p_units_code				   nvarchar(50)		= ''
	,@p_units_name				   nvarchar(250)	= ''
	,@p_pic_code				   nvarchar(50)		= ''
	,@p_residual_value			   decimal(18, 2)	= 0
	,@p_depre_category_comm_code   nvarchar(50)
	,@p_total_depre_comm		   decimal(18, 2)
	,@p_depre_period_comm		   nvarchar(6)		= ''
	,@p_net_book_value_comm		   decimal(18, 2)
	,@p_depre_category_fiscal_code nvarchar(50)
	,@p_total_depre_fiscal		   decimal(18, 2)
	,@p_depre_period_fiscal		   nvarchar(6)		= ''
	,@p_net_book_value_fiscal	   decimal(18, 2)
	,@p_is_rental				   nvarchar(1)		= ''
	,@p_opl_code				   nvarchar(50)		= ''
	,@p_rental_date				   datetime			= ''
	,@p_contractor_name			   nvarchar(250)	= ''
	,@p_contractor_address		   nvarchar(4000)	= ''
	,@p_contractor_email		   nvarchar(50)		= ''
	,@p_contractor_pic			   nvarchar(250)	= ''
	,@p_contractor_pic_phone	   nvarchar(25)		= ''
	,@p_contractor_start_date	   datetime			= null
	,@p_contractor_end_date		   datetime			= null
	,@p_warranty				   int				= 0
	,@p_warranty_start_date		   datetime			= null
	,@p_warranty_end_date		   datetime			= null
	,@p_remarks_warranty		   nvarchar(4000)	= ''
	,@p_is_maintenance			   nvarchar(1)		= ''
	,@p_maintenance_time		   int				= 0
	,@p_maintenance_type		   nvarchar(50)		= ''
	,@p_maintenance_cycle_time	   int				= 0
	,@p_maintenance_start_date	   datetime			= null
	,@p_use_life				   nvarchar(15)		= ''
	,@p_last_meter				   nvarchar(15)		= ''
	--
	,@p_category_name			   nvarchar(250)	= ''
	,@p_regional_code			   nvarchar(50)		= ''
	,@p_regional_name			   nvarchar(250)	= ''
	,@p_location_name			   nvarchar(250)	= ''
	,@p_pic_name				   nvarchar(250)	= ''
	,@p_last_used_by_code		   nvarchar(50)		= ''
	,@p_last_used_by_name		   nvarchar(250)	= ''
	,@p_last_location_code		   nvarchar(50)		= ''
	,@p_last_location_name		   nvarchar(250)	= ''
	,@p_cost_center_code		   nvarchar(50)		= ''
	,@p_cost_center_name		   nvarchar(250)	= ''
	,@p_po_date					   datetime			= null
	,@p_is_depre				   nvarchar(1)		= ''
	,@p_last_so_date			   datetime			= null
	,@p_last_so_condition		   nvarchar(50)		= ''
	--
	,@p_last_service_date		   datetime			= null
	,@p_pph						   decimal(18, 2)	= 0
	,@p_ppn						   decimal(18, 2)	= 0
	,@p_remarks					   nvarchar(4000)	= ''
	--ELCT
	,@p_file_name_elect			   nvarchar(250)
	,@p_upload_no_elect			   nvarchar(50)
	,@p_asset_code_elect		   nvarchar(50)
	,@p_merk_code_elect			   nvarchar(50)
	,@p_merk_name_elect			   nvarchar(250)
	,@p_type_code_elect			   nvarchar(50)
	,@p_type_name_elect			   nvarchar(250)
	,@p_model_code_elect		   nvarchar(50)
	,@p_model_name_elect		   nvarchar(250)
	,@p_serial_no_elect			   nvarchar(50)
	,@p_dimension_elect			   nvarchar(50)
	,@p_hdd_elect				   nvarchar(10)
	,@p_processor_elect			   nvarchar(10)
	,@p_ram_size_elect			   nvarchar(8)
	,@p_domain_elect			   nvarchar(100)
	,@p_imei_elect				   nvarchar(100)
	,@p_purchase_elect			   nvarchar(50)
	,@p_remark_elect			   nvarchar(4000)
	--FNTR
	,@p_file_name_fntr			   nvarchar(250)
	,@p_upload_no_fntr			   nvarchar(50)
	,@p_asset_code_fntr			   nvarchar(50)
	,@p_merk_code_fntr			   nvarchar(50)
	,@p_merk_name_fntr			   nvarchar(250)
	,@p_type_code_fntr			   nvarchar(50)
	,@p_type_name_fntr			   nvarchar(250)
	,@p_model_code_fntr			   nvarchar(50)
	,@p_model_name_fntr			   nvarchar(250)
	,@p_purchase_fntr			   nvarchar(50)
	,@p_remark_fntr				   nvarchar(4000)
	--MCHN
	,@p_file_name_mchn			   nvarchar(250)
	,@p_upload_no_mchn			   nvarchar(50)
	,@p_asset_code_mchn			   nvarchar(50)
	,@p_merk_code_mchn			   nvarchar(50)
	,@p_merk_name_mchn			   nvarchar(250)
	,@p_type_code_mchn			   nvarchar(50)
	,@p_type_name_mchn			   nvarchar(250)
	,@p_model_code_mchn			   nvarchar(50)
	,@p_built_year_mchn			   nvarchar(4)
	,@p_chassis_no_mchn			   nvarchar(50)
	,@p_engine_no_mchn			   nvarchar(50)
	,@p_colour_mchn				   nvarchar(50)
	,@p_serial_no_mchn			   nvarchar(50)
	,@p_purchase_mchn			   nvarchar(50)
	,@p_remark_mchn				   nvarchar(4000)
	--OTHR
	,@p_file_name_othr			   nvarchar(250)
	,@p_upload_no_othr			   nvarchar(50)
	,@p_asset_code_othr			   nvarchar(50)
	,@p_remark_othr				   nvarchar(4000)
	--PRTY
	,@p_file_name_prty					nvarchar(250)
	,@p_upload_no_prty					nvarchar(50)
	,@p_asset_code_prty					nvarchar(50)
	,@p_imb_no_prty						nvarchar(50)
	,@p_certificate_no_prty				nvarchar(50)
	,@p_land_size_prty					decimal(18, 2)
	,@p_building_size_prty				decimal(18, 2)
	,@p_status_of_ruko_prty				nvarchar(50)
	,@p_number_of_ruko_and_floor_prty	nvarchar(50)
	,@p_total_square_prty				nvarchar(10)
	,@p_vat_prty						decimal(18, 2)
	,@p_no_lease_agreement_prty			nvarchar(50)
	,@p_date_of_lease_agreement_prty	datetime
	,@p_land_and_building_tax_prty		nvarchar(50)
	,@p_security_deposit_prty			decimal(18, 2)
	,@p_penalty_prty					decimal(18, 2)
	,@p_owner_prty						nvarchar(250)
	,@p_address_prty					nvarchar(400)
	,@p_purchase_prty					nvarchar(50)
	,@p_total_rental_period_prty		nvarchar(9)
	,@p_rental_period_prty				nvarchar(15)
	,@p_rental_price_per_year_prty		decimal(18, 2)
	,@p_rental_price_per_month_prty		decimal(18, 2)
	,@p_total_rental_price_prty			decimal(18, 2)
	,@p_start_rental_date_prty			datetime
	,@p_end_rental_date_prty			datetime
	,@p_remark_prty						nvarchar(4000)
	--
	,@p_cre_date						datetime
	,@p_cre_by							nvarchar(15)
	,@p_cre_ip_address					nvarchar(15)
	,@p_mod_date						datetime
	,@p_mod_by							nvarchar(15)
	,@p_mod_ip_address					nvarchar(15)
)
as
begin
	
	declare @msg				nvarchar(max)
			,@year				nvarchar(4)
			,@month				nvarchar(2)
			,@upload_no			nvarchar(50)
			,@id				bigint
			,@type_code			nvarchar(50);
			            
	begin try	


		
		exec dbo.xsp_asset_upload_insert @p_id									= 0
										 ,@p_upload_no							= @upload_no
										 ,@p_company_code						= @p_company_code
										 ,@p_status_upload						= 'NEW'
										 ,@p_item_code							= @p_item_code
										 ,@p_item_name							= @p_item_name
										 ,@p_condition							= @p_condition
										 ,@p_barcode							= @p_barcode
										 ,@p_status								= 'NEW'
										 ,@p_po_no								= @p_po_no
										 ,@p_requestor_code						= @p_requestor_code
										 ,@p_requestor_name						= @p_requestor_name
										 ,@p_vendor_code						= @p_vendor_code
										 ,@p_vendor_name						= @p_vendor_name
										 ,@p_type_code							= @p_type_code
										 ,@p_category_code						= @p_category_code
										 ,@p_purchase_date						= @p_purchase_date
										 ,@p_purchase_price						= @p_purchase_price
										 ,@p_invoice_no							= @p_invoice_no
										 ,@p_invoice_date						= @p_invoice_date
										 ,@p_original_price						= @p_original_price
										 ,@p_sale_amount						= @p_sale_amount
										 ,@p_sale_date							= @p_sale_date
										 ,@p_disposal_date						= @p_disposal_date
										 ,@p_branch_code						= @p_branch_code
										 ,@p_branch_name						= @p_branch_name
										 ,@p_location_code						= @p_location_code
										 ,@p_division_code						= @p_division_code
										 ,@p_division_name						= @p_division_name
										 ,@p_department_code					= @p_department_code
										 ,@p_department_name					= @p_department_name
										 ,@p_sub_department_code				= @p_sub_department_code
										 ,@p_sub_department_name				= @p_sub_department_name
										 ,@p_units_code							= @p_units_code
										 ,@p_units_name							= @p_units_name
										 ,@p_pic_code							= @p_pic_code
										 ,@p_residual_value						= @p_residual_value
										 ,@p_depre_category_comm_code			= @p_depre_category_comm_code
										 ,@p_total_depre_comm					= @p_total_depre_comm
										 ,@p_depre_period_comm					= @p_depre_period_comm
										 ,@p_net_book_value_comm				= @p_net_book_value_comm
										 ,@p_depre_category_fiscal_code			= @p_depre_category_fiscal_code
										 ,@p_total_depre_fiscal					= @p_total_depre_fiscal
										 ,@p_depre_period_fiscal				= @p_depre_period_fiscal
										 ,@p_net_book_value_fiscal				= @p_net_book_value_fiscal
										 ,@p_is_rental							= @p_is_rental
										 ,@p_opl_code							= @p_opl_code
										 ,@p_rental_date						= @p_rental_date
										 ,@p_contractor_name					= @p_contractor_name
										 ,@p_contractor_address					= @p_contractor_address
										 ,@p_contractor_email					= @p_contractor_email
										 ,@p_contractor_pic						= @p_contractor_pic
										 ,@p_contractor_pic_phone				= @p_contractor_pic_phone
										 ,@p_contractor_start_date				= @p_contractor_start_date
										 ,@p_contractor_end_date				= @p_contractor_end_date
										 ,@p_warranty							= @p_warranty
										 ,@p_warranty_start_date				= @p_warranty_start_date
										 ,@p_warranty_end_date					= @p_warranty_end_date
										 ,@p_remarks_warranty					= @p_remarks_warranty
										 ,@p_is_maintenance						= @p_is_maintenance
										 ,@p_maintenance_time					= @p_maintenance_time
										 ,@p_maintenance_type					= @p_maintenance_type
										 ,@p_maintenance_cycle_time				= @p_maintenance_cycle_time
										 ,@p_maintenance_start_date				= @p_maintenance_start_date
										 ,@p_use_life							= @p_use_life
										 ,@p_last_meter							= @p_last_meter
										 ,@p_category_name						= @p_category_name		
										 ,@p_regional_code						= @p_regional_code		
										 ,@p_regional_name						= @p_regional_name		
										 ,@p_location_name						= @p_location_name		
										 ,@p_pic_name							= @p_pic_name			
										 ,@p_last_used_by_code					= @p_last_used_by_code	
										 ,@p_last_used_by_name					= @p_last_used_by_name	
										 ,@p_last_location_code					= @p_last_location_code	
										 ,@p_last_location_name					= @p_last_location_name	
										 ,@p_cost_center_code					= @p_cost_center_code	
										 ,@p_cost_center_name					= @p_cost_center_name	
										 ,@p_po_date							= @p_po_date				
										 ,@p_is_depre							= @p_is_depre			
										 ,@p_last_so_date						= @p_last_so_date		
										 ,@p_last_so_condition					= @p_last_so_condition	
										 ,@p_last_service_date					= @p_last_service_date
										 ,@p_pph								= @p_pph
										 ,@p_ppn								= @p_ppn
										 ,@p_remarks							= @p_remarks
										 ,@p_cre_date							= @p_cre_date	
										 ,@p_cre_by								= @p_cre_by		
										 ,@p_cre_ip_address						= @p_cre_ip_address
										 ,@p_mod_date							= @p_mod_date	
										 ,@p_mod_by								= @p_mod_by		
										 ,@p_mod_ip_address						= @p_mod_ip_address;
										 
			select @upload_no = upload_no
					,@type_code = type_code 
			from dbo.asset_upload
			where id = @id
			
			if(@type_code = 'ELCT')
			begin				
				exec dbo.xsp_asset_electronic_upload_data_from_excel @p_fa_upload_id			 = 0
																	 ,@p_file_name				 = @p_file_name_elect
																	 ,@p_upload_no				 = @upload_no
																	 ,@p_asset_code				 = @p_asset_code_elect
																	 ,@p_merk_code				 = @p_merk_code_elect
																	 ,@p_merk_name				 = @p_merk_name_elect
																	 ,@p_type_code				 = @p_type_code_elect
																	 ,@p_type_name				 = @p_type_name_elect
																	 ,@p_model_code				 = @p_model_code_elect
																	 ,@p_model_name				 = @p_model_name_elect
																	 ,@p_serial_no				 = @p_serial_no_elect
																	 ,@p_dimension				 = @p_dimension_elect
																	 ,@p_hdd					 = @p_hdd_elect
																	 ,@p_processor				 = @p_processor_elect
																	 ,@p_ram_size				 = @p_ram_size_elect
																	 ,@p_domain					 = @p_domain_elect
																	 ,@p_imei					 = @p_imei_elect
																	 ,@p_purchase				 = @p_purchase_elect
																	 ,@p_remark					 = @p_remark_elect
																	 ,@p_cre_date				 = @p_cre_date
																	 ,@p_cre_by					 = @p_cre_by		
																	 ,@p_cre_ip_address			 = @p_cre_ip_address
																	 ,@p_mod_date				 = @p_mod_date	
																	 ,@p_mod_by					 = @p_mod_by		
																	 ,@p_mod_ip_address			 = @p_mod_ip_address;
			end	
			else if (@type_code = 'FNTR')
			begin				
				exec dbo.xsp_asset_furniture_upload_data_from_excel @p_fa_upload_id		 = 0
																	,@p_file_name		 = @p_file_name_fntr
																	,@p_upload_no		 = @upload_no
																	,@p_asset_code		 = @p_asset_code_fntr
																	,@p_merk_code		 = @p_merk_code_fntr
																	,@p_merk_name		 = @p_merk_name_fntr
																	,@p_type_code		 = @p_type_code_fntr
																	,@p_type_name		 = @p_type_name_fntr
																	,@p_model_code		 = @p_model_code_fntr
																	,@p_model_name		 = @p_model_name_fntr
																	,@p_purchase		 = @p_purchase_fntr
																	,@p_remark			 = @p_remark_fntr
																	,@p_cre_date		 = @p_cre_date		
																	,@p_cre_by			 = @p_cre_by			
																	,@p_cre_ip_address	 = @p_cre_ip_address
																	,@p_mod_date		 = @p_mod_date		
																	,@p_mod_by			 = @p_mod_by			
																	,@p_mod_ip_address	 = @p_mod_ip_address
			end
			else if (@type_code = 'MCHN')
			begin
				exec dbo.xsp_asset_machine_upload_data_from_excel @p_fa_upload_id		 = 0
																  ,@p_file_name			 = N'' -- nvarchar(250)
																  ,@p_upload_no			 = N'' -- nvarchar(50)
																  ,@p_asset_code		 = N'' -- nvarchar(50)
																  ,@p_merk_code			 = N'' -- nvarchar(50)
																  ,@p_merk_name			 = N'' -- nvarchar(250)
																  ,@p_type_code			 = N'' -- nvarchar(50)
																  ,@p_type_name			 = N'' -- nvarchar(250)
																  ,@p_model_code		 = N'' -- nvarchar(50)
																  ,@p_built_year		 = N'' -- nvarchar(4)
																  ,@p_chassis_no		 = N'' -- nvarchar(50)
																  ,@p_engine_no			 = N'' -- nvarchar(50)
																  ,@p_colour			 = N'' -- nvarchar(50)
																  ,@p_serial_no			 = N'' -- nvarchar(50)
																  ,@p_purchase			 = N'' -- nvarchar(50)
																  ,@p_remark			 = N'' -- nvarchar(4000)
																  ,@p_cre_date			 = @p_cre_date		
																  ,@p_cre_by			 = @p_cre_by			
																  ,@p_cre_ip_address	 = @p_cre_ip_address
																  ,@p_mod_date			 = @p_mod_date		
																  ,@p_mod_by			 = @p_mod_by			
																  ,@p_mod_ip_address	 = @p_mod_ip_address
			end
			else if (@type_code = 'OTHR')
			begin				
				exec dbo.xsp_asset_other_upload_data_from_excel @p_fa_upload_id		 = 0
																,@p_file_name		 = @p_file_name_othr
																,@p_upload_no		 = @upload_no
																,@p_asset_code		 = @p_asset_code_othr
																,@p_remark			 = @p_remark_othr
																,@p_cre_date		 = @p_cre_date		
																,@p_cre_by			 = @p_cre_by			
																,@p_cre_ip_address	 = @p_cre_ip_address
																,@p_mod_date		 = @p_mod_date		
																,@p_mod_by			 = @p_mod_by			
																,@p_mod_ip_address	 = @p_mod_ip_address
			end
			else if (@type_code = 'PRTY')
			begin				
				exec dbo.xsp_asset_property_upload_data_from_excel @p_fa_upload_id				 = 0
																   ,@p_file_name				 = @p_file_name_prty
																   ,@p_upload_no				 = @upload_no
																   ,@p_asset_code				 = @p_asset_code_prty
																   ,@p_imb_no					 = @p_imb_no_prty
																   ,@p_certificate_no			 = @p_certificate_no_prty
																   ,@p_land_size				 = @p_land_size_prty
																   ,@p_building_size			 = @p_building_size_prty
																   ,@p_status_of_ruko			 = @p_status_of_ruko_prty
																   ,@p_number_of_ruko_and_floor	 = @p_number_of_ruko_and_floor_prty
																   ,@p_total_square				 = @p_total_square_prty
																   ,@p_vat						 = @p_vat_prty
																   ,@p_no_lease_agreement		 = @p_no_lease_agreement_prty
																   ,@p_date_of_lease_agreement	 = @p_date_of_lease_agreement_prty
																   ,@p_land_and_building_tax	 = @p_land_and_building_tax_prty
																   ,@p_security_deposit			 = @p_security_deposit_prty
																   ,@p_penalty					 = @p_penalty_prty
																   ,@p_owner					 = @p_owner_prty
																   ,@p_address					 = @p_address_prty
																   ,@p_purchase					 = @p_purchase_prty
																   ,@p_total_rental_period		 = @p_total_rental_period_prty
																   ,@p_rental_period			 = @p_rental_period_prty
																   ,@p_rental_price_per_year	 = @p_rental_price_per_year_prty
																   ,@p_rental_price_per_month	 = @p_rental_price_per_month_prty
																   ,@p_total_rental_price		 = @p_total_rental_price_prty
																   ,@p_start_rental_date		 = @p_start_rental_date_prty
																   ,@p_end_rental_date			 = @p_end_rental_date_prty
																   ,@p_remark					 = @p_remark_prty
																   ,@p_cre_date					 = @p_cre_date		
																   ,@p_cre_by					 = @p_cre_by			
																   ,@p_cre_ip_address			 = @p_cre_ip_address	
																   ,@p_mod_date					 = @p_mod_date		
																   ,@p_mod_by					 = @p_mod_by			
																   ,@p_mod_ip_address			 = @p_mod_ip_address		
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

end    
