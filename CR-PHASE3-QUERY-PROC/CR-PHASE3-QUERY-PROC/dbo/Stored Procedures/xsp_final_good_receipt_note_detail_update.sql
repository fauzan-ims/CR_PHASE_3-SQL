
CREATE procedure [dbo].[xsp_final_good_receipt_note_detail_update]
(
	@p_id								  bigint
	,@p_final_good_receipt_note_code	  nvarchar(50)
	,@p_good_receipt_note_detail_id		  int
	,@p_item_code						  nvarchar(50)
	,@p_item_name						  nvarchar(250)
	,@p_type_asset_code					  nvarchar(50)
	,@p_item_category_code				  nvarchar(50)
	,@p_item_category_name				  nvarchar(250)
	,@p_item_merk_code					  nvarchar(50)
	,@p_item_merk_name					  nvarchar(250)
	,@p_item_model_code					  nvarchar(50)
	,@p_item_model_name					  nvarchar(250)
	,@p_item_type_code					  nvarchar(50)
	,@p_item_type_name					  nvarchar(250)
	,@p_uom_code						  nvarchar(50)
	,@p_uom_name						  nvarchar(250)
	,@p_price_amount					  decimal(18, 2)
	,@p_specification					  nvarchar(250)
	,@p_po_quantity						  int
	,@p_receive_quantity				  int
	,@p_location_code					  nvarchar(50)
	,@p_location_name					  nvarchar(250)
	,@p_warehouse_code					  nvarchar(50)
	,@p_warehouse_name					  nvarchar(250)
	,@p_shipper_code					  nvarchar(50)
	,@p_no_resi							  nvarchar(50)
	--
	,@p_mod_date						  datetime
	,@p_mod_by							  nvarchar(15)
	,@p_mod_ip_address					  nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	final_good_receipt_note_detail
		set		final_good_receipt_note_code = @p_final_good_receipt_note_code
				,good_receipt_note_detail_id = @p_good_receipt_note_detail_id
				,item_code					 = @p_item_code
				,item_name					 = @p_item_name
				,type_asset_code			 = @p_type_asset_code
				,item_category_code			 = @p_item_category_code
				,item_category_name			 = @p_item_category_name
				,item_merk_code				 = @p_item_merk_code
				,item_merk_name				 = @p_item_merk_name
				,item_model_code			 = @p_item_model_code
				,item_model_name			 = @p_item_model_name
				,item_type_code				 = @p_item_type_code
				,item_type_name				 = @p_item_type_name
				,uom_code					 = @p_uom_code
				,uom_name					 = @p_uom_name
				,price_amount				 = @p_price_amount
				,specification				 = @p_specification
				,po_quantity				 = @p_po_quantity
				,receive_quantity			 = @p_receive_quantity
				,location_code				 = @p_location_code
				,location_name				 = @p_location_name
				,warehouse_code				 = @p_warehouse_code
				,warehouse_name				 = @p_warehouse_name
				,shipper_code				 = @p_shipper_code
				,no_resi					 = @p_no_resi
				--
				,mod_date					 = @p_mod_date
				,mod_by						 = @p_mod_by
				,mod_ip_address				 = @p_mod_ip_address
		where	id = @p_id ;
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
			set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
