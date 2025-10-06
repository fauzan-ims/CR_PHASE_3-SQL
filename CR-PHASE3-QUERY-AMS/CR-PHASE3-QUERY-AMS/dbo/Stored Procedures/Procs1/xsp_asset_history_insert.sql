CREATE PROCEDURE dbo.xsp_asset_history_insert
(
	@p_code							nvarchar(50)
	,@p_company_code				nvarchar(50)
	,@p_item_code					nvarchar(50)
	,@p_item_name					nvarchar(250)
	,@p_condition					nvarchar(50)
	,@p_barcode						nvarchar(50)
	,@p_cost_center_code			nvarchar(50)
	,@p_cost_center_name			nvarchar(50)
	,@p_status						nvarchar(50)
	,@p_po_no						nvarchar(50)
	,@p_requestor_code				nvarchar(50)
	,@p_requestor_name				nvarchar(250)
	,@p_vendor_code					nvarchar(50)
	,@p_vendor_name					nvarchar(250)
	,@p_type_code					nvarchar(50)
	,@p_category_code				nvarchar(50)
	,@p_category_name				nvarchar(250)
	,@p_po_date						datetime
	,@p_purchase_date				datetime
	,@p_purchase_price				decimal(18, 2)
	,@p_invoice_no					nvarchar(50)
	,@p_invoice_date				datetime
	,@p_original_price				decimal(18, 2)
	,@p_sale_amount					decimal(18, 2)
	,@p_sale_date					datetime
	,@p_disposal_date				datetime
	,@p_branch_code					nvarchar(50)
	,@p_branch_name					nvarchar(250)
	,@p_location_code				nvarchar(50)
	,@p_location_name				nvarchar(250)
	,@p_division_code				nvarchar(50)
	,@p_division_name				nvarchar(250)
	,@p_department_code				nvarchar(50)
	,@p_department_name				nvarchar(250)
	,@p_sub_department_code			nvarchar(50)
	,@p_sub_department_name			nvarchar(250)
	,@p_units_code					nvarchar(50)
	,@p_units_name					nvarchar(250)
	,@p_pic_code					nvarchar(50)
	,@p_pic_name					nvarchar(250)
	,@p_residual_value				decimal(18, 2)
	,@p_is_depre					nvarchar(1)
	,@p_depre_category_comm_code	nvarchar(50)
	,@p_total_depre_comm			decimal(18, 2)
	,@p_depre_period_comm			nvarchar(6)
	,@p_net_book_value_comm			decimal(18, 2)
	,@p_depre_category_fiscal_code	nvarchar(50)
	,@p_total_depre_fiscal			decimal(18, 2)
	,@p_depre_period_fiscal			nvarchar(6)
	,@p_net_book_value_fiscal		decimal(18, 2)
	,@p_is_rental					nvarchar(1)
	,@p_opl_code					nvarchar(50)
	,@p_rental_date					datetime
	,@p_contractor_name				nvarchar(250)
	,@p_contractor_address			nvarchar(4000)
	,@p_contractor_email			nvarchar(50)
	,@p_contractor_pic				nvarchar(250)
	,@p_contractor_pic_phone		nvarchar(25)
	,@p_contractor_start_date		datetime
	,@p_contractor_end_date			datetime
	,@p_warranty					int
	,@p_warranty_start_date			datetime
	,@p_warranty_end_date			datetime
	,@p_remarks_warranty			nvarchar(4000)
	,@p_is_maintenance				nvarchar(1)
	,@p_maintenance_time			int
	,@p_maintenance_type			nvarchar(50)
	,@p_maintenance_cycle_time		int
	,@p_maintenance_start_date		datetime
	,@p_use_life					nvarchar(15)
	,@p_last_meter					nvarchar(15)
	,@p_last_service_date			datetime
	,@p_pph							decimal(18, 2)
	,@p_ppn							decimal(18, 2)
	,@p_remarks						nvarchar(4000)
	,@p_last_so_date				datetime
	,@p_last_so_condition			nvarchar(50)
	,@p_regional_code				nvarchar(50)
	,@p_regional_name				nvarchar(250)
	,@p_last_used_by_code			nvarchar(50)
	,@p_last_used_by_name			nvarchar(250)
	,@p_last_location_code			nvarchar(50)
	,@p_last_location_name			nvarchar(250)
	--
	,@p_cre_date					datetime
	,@p_cre_by						nvarchar(15)
	,@p_cre_ip_address				nvarchar(15)
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_depre = 'T'
		set @p_is_depre = '1'
	else
		set @p_is_depre = '0'

	if @p_is_rental = 'T'
		set @p_is_rental = '1'
	else
		set @p_is_rental = '0'

	if @p_is_maintenance = 'T'
		set @p_is_maintenance = '1'
	else
		set @p_is_maintenance = '0'

	begin try
		insert into asset_history
		(
			code
			,company_code
			,item_code
			,item_name
			,condition
			,barcode
			,cost_center_code
			,cost_center_name
			,status
			,po_no
			,requestor_code
			,requestor_name
			,vendor_code
			,vendor_name
			,type_code
			,category_code
			,category_name
			,po_date
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
			,location_name
			,division_code
			,division_name
			,department_code
			,department_name
			,sub_department_code
			,sub_department_name
			,units_code
			,units_name
			,pic_code
			,pic_name
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
			,last_so_date
			,last_so_condition
			,regional_code
			,regional_name
			,last_used_by_code
			,last_used_by_name
			,last_location_code
			,last_location_name
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
			@p_code
			,@p_company_code
			,@p_item_code
			,@p_item_name
			,@p_condition
			,@p_barcode
			,@p_cost_center_code
			,@p_cost_center_name
			,@p_status
			,@p_po_no
			,@p_requestor_code
			,@p_requestor_name
			,@p_vendor_code
			,@p_vendor_name
			,@p_type_code
			,@p_category_code
			,@p_category_name
			,@p_po_date
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
			,@p_location_code
			,@p_location_name
			,@p_division_code
			,@p_division_name
			,@p_department_code
			,@p_department_name
			,@p_sub_department_code
			,@p_sub_department_name
			,@p_units_code
			,@p_units_name
			,@p_pic_code
			,@p_pic_name
			,@p_residual_value
			,@p_is_depre
			,@p_depre_category_comm_code
			,@p_total_depre_comm
			,@p_depre_period_comm
			,@p_net_book_value_comm
			,@p_depre_category_fiscal_code
			,@p_total_depre_fiscal
			,@p_depre_period_fiscal
			,@p_net_book_value_fiscal
			,@p_is_rental
			,@p_opl_code
			,@p_rental_date
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
			,@p_last_so_date
			,@p_last_so_condition
			,@p_regional_code
			,@p_regional_name
			,@p_last_used_by_code
			,@p_last_used_by_name
			,@p_last_location_code
			,@p_last_location_name
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		)

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
