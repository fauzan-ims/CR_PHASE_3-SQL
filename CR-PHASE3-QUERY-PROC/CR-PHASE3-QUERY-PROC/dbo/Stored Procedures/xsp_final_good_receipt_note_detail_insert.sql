
-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_final_good_receipt_note_detail_insert]
(
	@p_id								  bigint = 0 output
	,@p_final_good_receipt_note_code nvarchar(50)
	,@p_good_receipt_note_detail_id		  int
    ,@p_reff_no							  nvarchar(50)
	,@p_reff_name						  nvarchar(50)
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
	,@p_cre_date						  datetime
	,@p_cre_by							  nvarchar(15)
	,@p_cre_ip_address					  nvarchar(15)
	,@p_mod_date						  datetime
	,@p_mod_by							  nvarchar(15)
	,@p_mod_ip_address					  nvarchar(15)
	,@p_po_object_id					  bigint = 0
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into final_good_receipt_note_detail
		(
			final_good_receipt_note_code
			,good_receipt_note_detail_id
			,reff_no
			,reff_name
			,item_code
			,item_name
			,type_asset_code
			,item_category_code
			,item_category_name
			,item_merk_code
			,item_merk_name
			,item_model_code
			,item_model_name
			,item_type_code
			,item_type_name
			,uom_code
			,uom_name
			,price_amount
			,specification
			,po_quantity
			,receive_quantity
			,location_code
			,location_name
			,warehouse_code
			,warehouse_name
			,shipper_code
			,no_resi
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
			,po_object_id
		)
		values
		(
			@p_final_good_receipt_note_code
			,@p_good_receipt_note_detail_id
			,@p_reff_no	
			,@p_reff_name
			,@p_item_code
			,@p_item_name
			,@p_type_asset_code
			,@p_item_category_code
			,@p_item_category_name
			,@p_item_merk_code
			,@p_item_merk_name
			,@p_item_model_code
			,@p_item_model_name
			,@p_item_type_code
			,@p_item_type_name
			,@p_uom_code
			,@p_uom_name
			,@p_price_amount
			,@p_specification
			,@p_po_quantity
			,@p_receive_quantity
			,@p_location_code
			,@p_location_name
			,@p_warehouse_code
			,@p_warehouse_name
			,@p_shipper_code
			,@p_no_resi
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
			,@p_po_object_id
		) ;

		set @p_id = @@identity ;
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
