CREATE PROCEDURE [dbo].[xsp_asset_update]
(
	@p_code								nvarchar(50)
	,@p_company_code					nvarchar(50)
	,@p_item_code						nvarchar(50)
	,@p_item_name						nvarchar(250)
	,@p_condition						nvarchar(50)		= ''
	,@p_barcode							nvarchar(50)		= ''
	,@p_status							nvarchar(50)
	,@p_po_no							nvarchar(50)		= ''
	,@p_po_date							datetime			= null
	,@p_requestor_code					nvarchar(50)		= ''
	,@p_requestor_name					nvarchar(250)		= ''
	,@p_vendor_code						nvarchar(50)
	,@p_vendor_name						nvarchar(250)
	,@p_type_code						nvarchar(50)		= ''
	,@p_category_code					nvarchar(50)		= ''
	,@p_purchase_date					datetime			= null
	,@p_purchase_price					decimal(18, 2)
	,@p_invoice_no						nvarchar(50)		= ''
	,@p_invoice_date					datetime			= null
	,@p_original_price					decimal(18, 2)
	,@p_sale_amount						decimal(18, 2)		= 0
	,@p_sale_date						datetime			= null
	,@p_disposal_date					datetime			= null
	,@p_branch_code						nvarchar(50)
	,@p_branch_name						nvarchar(250)
	,@p_division_code					nvarchar(50)		= ''
	,@p_division_name					nvarchar(250)		= ''
	,@p_department_code					nvarchar(50)		= ''
	,@p_department_name					nvarchar(250)		= ''
	,@p_pic_code						nvarchar(50)		= ''
	,@p_residual_value					decimal(18, 2)
	,@p_is_depre						nvarchar(1)			= ''
	,@p_depre_category_comm_code		nvarchar(50)		= ''
	,@p_total_depre_comm				decimal(18, 2)
	,@p_depre_period_comm				nvarchar(6)			= ''
	,@p_net_book_value_comm				decimal(18, 2)
	,@p_depre_category_fiscal_code		nvarchar(50)		= ''
	,@p_total_depre_fiscal				decimal(18, 2)		= 0
	,@p_depre_period_fiscal				nvarchar(6)			= ''
	,@p_net_book_value_fiscal			decimal(18, 2)		= 0
	,@p_is_rental						nvarchar(1)
	,@p_contractor_name					nvarchar(250)		= ''
	,@p_contractor_address				nvarchar(4000)		= ''
	,@p_contractor_email				nvarchar(50)		= ''
	,@p_contractor_pic					nvarchar(250)		= ''
	,@p_contractor_pic_phone			nvarchar(25)		= ''
	,@p_contractor_start_date			datetime			= null
	,@p_contractor_end_date				datetime			= null
	,@p_warranty						int
	,@p_warranty_start_date				datetime			= null
	,@p_warranty_end_date				datetime			= null
	,@p_remarks_warranty				nvarchar(4000)		= ''
	,@p_is_maintenance					nvarchar(1)
	,@p_maintenance_time				int					= 0
	,@p_maintenance_type				nvarchar(50)		= ''
	,@p_maintenance_cycle_time			int					= 0
	,@p_maintenance_start_date			datetime			= null
	,@p_use_life						nvarchar(15)		= ''
	,@p_last_meter						nvarchar(15)		= ''
	,@p_last_service_date				datetime			= null
	,@p_pph								decimal(9,6)		= 0
	,@p_ppn								decimal(9,6)		= 0
	,@p_remarks							nvarchar(4000)		= ''
	,@p_last_so_date					datetime			= null
	,@p_last_so_condition				nvarchar(50)		= ''
	,@p_category_name					nvarchar(250)		= ''		
	,@p_pic_name						nvarchar(250)		= ''		
	,@p_last_used_by_code				nvarchar(50)		= ''		
	,@p_last_used_by_name				nvarchar(250)		= ''		
	,@p_last_location_code				nvarchar(50)		= ''		
	,@p_last_location_name				nvarchar(250)		= ''		
	,@p_asset_purpose					nvarchar(50)		= ''
	,@p_asset_from						nvarchar(50)		= ''
	,@p_type_code_asset					nvarchar(50)		= ''
	,@p_model_code						nvarchar(50)		= ''
	,@p_merek_code						nvarchar(50)		= ''
	,@p_model_name						nvarchar(250)		= ''
	,@p_merk_name						nvarchar(250)		= ''
	,@p_type_name_asset					nvarchar(250)		= ''		
	,@p_item_group_code					nvarchar(50)		= ''
	,@p_unit_province_code				nvarchar(50)		= ''
	,@p_unit_province_name				nvarchar(250)		= ''
	,@p_unit_city_code					nvarchar(50)		= ''
	,@p_unit_city_name					nvarchar(250)		= ''
	,@p_parking_location				nvarchar(250)		= ''
	,@p_reserved_by						nvarchar(250)		= ''
	,@p_reserved_date					datetime			= null
	,@p_process_status					nvarchar(50)		= ''
	,@p_re_rent_status					nvarchar(10)		= ''
	--
	,@p_mod_date						datetime
	,@p_mod_by							nvarchar(15)
	,@p_mod_ip_address					nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max) 
			,@old_barcode	nvarchar(50)
			,@status		nvarchar(50)
			,@amt_threshold	decimal(18,2)
			,@is_valid		int 
			,@rental_status	nvarchar(50)
	begin try

	if @p_is_maintenance = 'T'
		set @p_is_maintenance = '1' ;
	else if @p_is_maintenance = '1'
		set @p_is_maintenance = '1' ;
	else if @p_is_maintenance = '0'
		set @p_is_maintenance = '0' ;
	else
		set @p_is_maintenance = '0' ;

	if @p_is_rental = 'T'
		set @p_is_rental = '1' ;
	else
		set @p_is_rental = '0' ;

	if @p_re_rent_status = 'NOT'
		set @p_re_rent_status = ''

	
	select	@old_barcode	= barcode
			,@status		= status
			,@rental_status = rental_status
	from	dbo.asset
	where	code = @p_code

	--select	@p_category_name = description -- temporary 
	--		,@amt_threshold = depre_amount_threshold
	--from	dbo.master_category 
	--where	code = @p_category_code ;

	--if(isnull(@rental_status,'') <> '')
	--begin
	--	set @msg = 'Cannot allocate asset to employee, because asset status In Use.';
	--	raiserror(@msg ,16,-1);	
	--end


	select	@p_category_name				= mc.description -- temporary 
			,@amt_threshold					= depre_amount_threshold
			,@p_type_code					= isnull(mc.asset_type_code,'')
			,@p_category_code				= mc.code
			,@p_depre_category_comm_code	= mc.depre_cat_commercial_code
			,@p_depre_category_fiscal_code	= mc.depre_cat_fiscal_code
			,@p_use_life					= mdcc.usefull
			,@amt_threshold					= mc.depre_amount_threshold
	from	dbo.master_category mc
			inner join dbo.master_depre_category_commercial mdcc on mc.depre_cat_commercial_code = mdcc.code
	where	mc.code = @p_category_code
		
	select @is_valid = dbo.xfn_depre_threshold_validation(@p_company_code, @p_category_code, @p_purchase_price)
	if @is_valid = 1
	    set @p_is_depre = '1';
	else
	    set @p_is_depre = '0';

	if(@status = 'HOLD')
	begin
			if(@p_pic_code = '' and @p_pic_name = '')
			begin
				set @rental_status = ''
			end
			else
			begin
				set @rental_status = 'COMPLIMENT'
			end

			update	asset
			set		item_code					= @p_item_code
					,item_name					= @p_item_name
					,condition					= @p_condition
					,barcode					= @p_barcode
					,status						= @p_status
					,po_no						= @p_po_no
					,po_date					= @p_po_date
					,requestor_code				= @p_requestor_code
					,requestor_name				= @p_requestor_name
					,vendor_code				= @p_vendor_code
					,vendor_name				= @p_vendor_name
					,type_code					= @p_type_code
					,category_code				= @p_category_code
					,purchase_date				= @p_purchase_date
					,purchase_price				= @p_purchase_price
					,invoice_no					= @p_invoice_no
					,invoice_date				= @p_invoice_date
					,original_price				= @p_original_price
					,branch_code				= @p_branch_code
					,branch_name				= @p_branch_name
					,division_code				= @p_division_code
					,division_name				= @p_division_name
					,department_code			= @p_department_code
					,department_name			= @p_department_name
					,pic_code					= @p_pic_code
					,residual_value				= @p_residual_value
					,is_depre					= @p_is_depre
					,depre_category_comm_code	= @p_depre_category_comm_code
					,total_depre_comm			= @p_total_depre_comm
					,depre_period_comm			= @p_depre_period_comm
					,net_book_value_comm		= case when @p_purchase_price >= @amt_threshold then @p_purchase_price else 0 end -- Dicki 22-Oct-2022 ket : for WOM (+)
					,depre_category_fiscal_code = @p_depre_category_fiscal_code
					,total_depre_fiscal			= @p_total_depre_fiscal
					,depre_period_fiscal		= @p_depre_period_fiscal
					,net_book_value_fiscal		= case when @p_purchase_price >= @amt_threshold then @p_purchase_price else 0 end -- Dicki 22-Oct-2022 ket : for WOM (+)
					,is_rental					= @p_is_rental
					,contractor_name			= @p_contractor_name
					,contractor_address			= @p_contractor_address
					,contractor_email			= @p_contractor_email
					,contractor_pic				= @p_contractor_pic
					,contractor_pic_phone		= @p_contractor_pic_phone
					,contractor_start_date		= @p_contractor_start_date
					,contractor_end_date		= @p_contractor_end_date
					,warranty					= @p_warranty
					,warranty_start_date		= @p_warranty_start_date
					,warranty_end_date			= @p_warranty_end_date
					,remarks_warranty			= @p_remarks_warranty
					,is_maintenance				= @p_is_maintenance
					,maintenance_time			= @p_maintenance_time
					,maintenance_type			= @p_maintenance_type
					,maintenance_cycle_time		= @p_maintenance_cycle_time
					,maintenance_start_date		= @p_maintenance_start_date
					,use_life					= @p_use_life
					,last_meter					= @p_last_meter
					,last_service_date			= @p_last_service_date
					,pph						= @p_pph
					,ppn						= @p_ppn
					,remarks					= @p_remarks
					,last_so_date				= @p_last_so_date
					,last_so_condition			= @p_last_so_condition	
					,category_name				= @p_category_name		
					,pic_name					= @p_pic_name			
					,last_used_by_code			= @p_last_used_by_code	
					,last_used_by_name			= @p_last_used_by_name	
					,last_location_code			= @p_last_location_code	
					,last_location_name			= @p_last_location_name	
					,asset_purpose				= @p_asset_purpose
					,asset_from					= @p_asset_from
					,model_code					= @p_model_code
					,model_name					= @p_model_name
					,merk_code					= @p_merek_code
					,merk_name					= @p_merk_name
					,type_code_asset			= @p_type_code_asset
					,type_name_asset			= @p_type_name_asset
					,item_group_code			= @p_item_group_code
					,unit_province_code			= @p_unit_province_code
					,unit_province_name			= @p_unit_province_name
					,unit_city_code				= @p_unit_city_code
					,unit_city_name				= @p_unit_city_name
					,parking_location			= @p_parking_location
					,reserved_by				= @p_reserved_by
					,reserved_date				= @p_reserved_date
					,process_status				= @p_process_status
					,rental_status				= @rental_status
					,re_rent_status				= @p_re_rent_status
					--
					,mod_date					= @p_mod_date
					,mod_by						= @p_mod_by
					,mod_ip_address				= @p_mod_ip_address
			where	code						= @p_code
					and company_code			= @p_company_code ;
		
			if(@p_type_code = 'ELCT')
			begin
				update	dbo.asset_electronic
				set		model_code					= @p_model_code
						,model_name					= @p_model_name
						,merk_code					= @p_merek_code
						,merk_name					= @p_merk_name
						,type_item_code				= @p_type_code_asset
						,type_item_name				= @p_type_name_asset
						--
						,mod_date					= @p_mod_date
						,mod_by						= @p_mod_by
						,mod_ip_address				= @p_mod_ip_address
				where	asset_code					= @p_code
			end
			else if(@p_type_code = 'MCHN')
			begin
				update	dbo.asset_machine
				set		model_code					= @p_model_code
						,model_name					= @p_model_name
						,merk_code					= @p_merek_code
						,merk_name					= @p_merk_name
						,type_item_code				= @p_type_code_asset
						,type_item_name				= @p_type_name_asset
						--
						,mod_date					= @p_mod_date
						,mod_by						= @p_mod_by
						,mod_ip_address				= @p_mod_ip_address
				where	asset_code					= @p_code
			end
			else if(@p_type_code = 'VHCL')
			begin
				update	dbo.asset_vehicle
				set		model_code					= @p_model_code
						,model_name					= @p_model_name
						,merk_code					= @p_merek_code
						,merk_name					= @p_merk_name
						,type_item_code				= @p_type_code_asset
						,type_item_name				= @p_type_name_asset
						--
						,mod_date					= @p_mod_date
						,mod_by						= @p_mod_by
						,mod_ip_address				= @p_mod_ip_address
				where	asset_code					= @p_code
			end
			else if(@p_type_code = 'HE')
			begin
				update	dbo.asset_he
				set		model_code					= @p_model_code
						,model_name					= @p_model_name
						,merk_code					= @p_merek_code
						,merk_name					= @p_merk_name
						,type_item_code				= @p_type_code_asset
						,type_item_name				= @p_type_name_asset
						--
						,mod_date					= @p_mod_date
						,mod_by						= @p_mod_by
						,mod_ip_address				= @p_mod_ip_address
				where	asset_code					= @p_code
			end
		end
	else
	begin
		if(@p_pic_code = '' and @p_pic_name = '')
		begin
			set @rental_status = @rental_status
		end
		else
		begin
			set @rental_status = 'COMPLIMENT'
		end
		update	asset
			set		use_life					= @p_use_life
					,contractor_name			= @p_contractor_name
					,contractor_address			= @p_contractor_address
					,contractor_email			= @p_contractor_email
					,contractor_pic				= @p_contractor_pic
					,contractor_pic_phone		= @p_contractor_pic_phone
					,contractor_start_date		= @p_contractor_start_date
					,contractor_end_date		= @p_contractor_end_date
					,is_maintenance				= @p_is_maintenance
					,maintenance_time			= @p_maintenance_time
					,maintenance_type			= @p_maintenance_type
					,maintenance_cycle_time		= @p_maintenance_cycle_time
					,maintenance_start_date		= @p_maintenance_start_date
					,barcode					= @p_barcode
					,is_rental					= @p_is_rental
					,pic_code					= @p_pic_code
					,pic_name					= @p_pic_name
					,warranty					= @p_warranty
					,warranty_start_date		= @p_warranty_start_date
					,warranty_end_date			= @p_warranty_end_date
					,remarks_warranty			= @p_remarks_warranty
					,remarks					= @p_remarks
					,asset_purpose				= @p_asset_purpose
					,unit_province_code			= @p_unit_province_code
					,unit_province_name			= @p_unit_province_name
					,unit_city_code				= @p_unit_city_code
					,unit_city_name				= @p_unit_city_name
					,parking_location			= @p_parking_location
					,reserved_by				= @p_reserved_by
					,reserved_date				= @p_reserved_date
					,rental_status				= @rental_status
					,process_status				= @p_process_status
					,re_rent_status				= @p_re_rent_status
					--
					,mod_date					= @p_mod_date
					,mod_by						= @p_mod_by
					,mod_ip_address				= @p_mod_ip_address
			where	code						= @p_code
					and company_code			= @p_company_code ;
	end

	
		
	if (@p_barcode <> @old_barcode and @old_barcode <> '')
	begin
		-- insert ke FA_ASSET_BARCODE_HISTORY
		exec dbo.xsp_asset_barcode_history_insert @p_id						 = 0
												  ,@p_asset_code			 = @p_code
												  ,@p_previous_barcode		 = @old_barcode
												  ,@p_new_barcode			 = @p_barcode
												  ,@p_remark				 = 'CHANGE BARCODE'
												  ,@p_cre_date				 = @p_mod_date		
												  ,@p_cre_by				 = @p_mod_by			
												  ,@p_cre_ip_address		 = @p_mod_ip_address
												  ,@p_mod_date				 = @p_mod_date		
												  ,@p_mod_by				 = @p_mod_by			
												  ,@p_mod_ip_address		 = @p_mod_ip_address;

	end
	else if (@p_barcode <> @old_barcode and @old_barcode = '')
	begin
		-- insert ke FA_ASSET_BARCODE_HISTORY
		exec dbo.xsp_asset_barcode_history_insert @p_id						 = 0
												  ,@p_asset_code			 = @p_code
												  ,@p_previous_barcode		 = '-'
												  ,@p_new_barcode			 = @p_barcode
												  ,@p_remark				 = 'NEW BARCODE'
												  ,@p_cre_date				 = @p_mod_date		
												  ,@p_cre_by				 = @p_mod_by			
												  ,@p_cre_ip_address		 = @p_mod_ip_address
												  ,@p_mod_date				 = @p_mod_date		
												  ,@p_mod_by				 = @p_mod_by			
												  ,@p_mod_ip_address		 = @p_mod_ip_address;
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
