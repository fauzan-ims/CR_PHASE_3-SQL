CREATE PROCEDURE dbo.xsp_efam_interface_asset_update
(
	@p_code						   nvarchar(50)
	,@p_company_code			   nvarchar(50)
	,@p_item_code				   nvarchar(50)
	,@p_item_name				   nvarchar(250)
	,@p_barcode					   nvarchar(50)
	,@p_status					   nvarchar(20)
	,@p_po_no					   nvarchar(50)
	,@p_requestor_code			   nvarchar(50)
	,@p_requestor_name			   nvarchar(250)
	,@p_vendor_code				   nvarchar(50)
	,@p_vendor_name				   nvarchar(250)
	,@p_type_code				   nvarchar(50)
	,@p_category_code			   nvarchar(50)
	,@p_purchase_date			   datetime
	,@p_purchase_price			   decimal(18, 2)
	,@p_invoice_no				   nvarchar(50)
	,@p_invoice_date			   datetime
	,@p_original_price			   decimal(18, 2)
	,@p_sale_amount				   decimal(18, 2)
	,@p_sale_date				   datetime
	,@p_disposal_date			   datetime
	,@p_branch_code				   nvarchar(50)
	,@p_branch_name				   nvarchar(250)
	,@p_location_code			   nvarchar(50)
	,@p_division_code			   nvarchar(50)
	,@p_division_name			   nvarchar(250)
	,@p_department_code			   nvarchar(50)
	,@p_department_name			   nvarchar(250)
	,@p_sub_department_code		   nvarchar(50)
	,@p_sub_department_name		   nvarchar(250)
	,@p_units_code				   nvarchar(50)
	,@p_units_name				   nvarchar(250)
	,@p_pic_code				   nvarchar(50)
	,@p_residual_value			   decimal(18, 2)
	,@p_depre_category_comm_code   nvarchar(50)
	,@p_total_depre_comm		   decimal(18, 2)
	,@p_depre_period_comm		   nvarchar(6)
	,@p_net_book_value_comm		   decimal(18, 2)
	,@p_depre_category_fiscal_code nvarchar(50)
	,@p_total_depre_fiscal		   decimal(18, 2)
	,@p_depre_period_fiscal		   nvarchar(6)
	,@p_net_book_value_fiscal	   decimal(18, 2)
	,@p_contractor_name			   nvarchar(250)
	,@p_contractor_address		   nvarchar(4000)
	,@p_contractor_email		   nvarchar(50)
	,@p_contractor_pic			   nvarchar(250)
	,@p_contractor_pic_phone	   nvarchar(25)
	,@p_contractor_start_date	   datetime
	,@p_contractor_end_date		   datetime
	,@p_warranty				   int
	,@p_warranty_start_date		   datetime
	,@p_warranty_end_date		   datetime
	,@p_remarks_warranty		   nvarchar(4000)
	,@p_is_maintenance			   nvarchar(1)
	,@p_maintenance_time		   int
	,@p_maintenance_type		   nvarchar(50)
	,@p_maintenance_cycle_time	   int
	,@p_maintenance_start_date	   datetime
	,@p_remarks					   nvarchar(4000)
	--
	,@p_mod_date				   datetime
	,@p_mod_by					   nvarchar(15)
	,@p_mod_ip_address			   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_maintenance = 'T'
		set @p_is_maintenance = '1' ;
	else
		set @p_is_maintenance = '0' ;

	begin try
		update	efam_interface_asset
		set		company_code				= @p_company_code
				,item_code					= @p_item_code
				,item_name					= @p_item_name
				,barcode					= @p_barcode
				,status						= @p_status
				,po_no						= @p_po_no
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
				,sale_amount				= @p_sale_amount
				,sale_date					= @p_sale_date
				,disposal_date				= @p_disposal_date
				,branch_code				= @p_branch_code
				,branch_name				= @p_branch_name
				,location_code				= @p_location_code
				,division_code				= @p_division_code
				,division_name				= @p_division_name
				,department_code			= @p_department_code
				,department_name			= @p_department_name
				,sub_department_code		= @p_sub_department_code
				,sub_department_name		= @p_sub_department_name
				,units_code					= @p_units_code
				,units_name					= @p_units_name
				,pic_code					= @p_pic_code
				,residual_value				= @p_residual_value
				,depre_category_comm_code	= @p_depre_category_comm_code
				,total_depre_comm			= @p_total_depre_comm
				,depre_period_comm			= @p_depre_period_comm
				,net_book_value_comm		= @p_net_book_value_comm
				,depre_category_fiscal_code = @p_depre_category_fiscal_code
				,total_depre_fiscal			= @p_total_depre_fiscal
				,depre_period_fiscal		= @p_depre_period_fiscal
				,net_book_value_fiscal		= @p_net_book_value_fiscal
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
				,remarks					= @p_remarks
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	code						= @p_code ;
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
