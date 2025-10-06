CREATE PROCEDURE dbo.xsp_eproc_interface_asset_update
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
	--
	,@p_mod_date				   datetime
	,@p_mod_by					   nvarchar(15)
	,@p_mod_ip_address			   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	eproc_interface_asset
		set		company_code = @p_company_code
				,item_code = @p_item_code
				,item_name = @p_item_name
				,barcode = @p_barcode
				,status = @p_status
				,po_no = @p_po_no
				,requestor_code = @p_requestor_code
				,requestor_name = @p_requestor_name
				,vendor_code = @p_vendor_code
				,vendor_name = @p_vendor_name
				,type_code = @p_type_code
				,category_code = @p_category_code
				,purchase_date = @p_purchase_date
				,purchase_price = @p_purchase_price
				,invoice_no = @p_invoice_no
				,invoice_date = @p_invoice_date
				,original_price = @p_original_price
				,branch_code = @p_branch_code
				,branch_name = @p_branch_name
				,location_code = @p_location_code
				,division_code = @p_division_code
				,division_name = @p_division_name
				,department_code = @p_department_code
				,department_name = @p_department_name
				,sub_department_code = @p_sub_department_code
				,sub_department_name = @p_sub_department_name
				,units_code = @p_units_code
				,units_name = @p_units_name
				--
				,mod_date = @p_mod_date
				,mod_by = @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	code = @p_code ;
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
