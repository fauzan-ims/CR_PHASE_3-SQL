
-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_final_grn_request_detail_update]
(
	 @p_id int
	--,@p_asset_no			 nvarchar(50)
	--,@p_delivery_to			 nvarchar(250)
	--,@p_year				 nvarchar(50)
	--,@p_colour				 nvarchar(50)
	--,@p_po_code_asset		 nvarchar(50)
	--,@p_grn_code_asset		 nvarchar(50)
	--,@p_grn_detail_id_asset	 int
	--,@p_supplier_name_asset	 nvarchar(250)
	--,@p_grn_receive_date	 datetime
	--,@p_status				 nvarchar(50)
	,@p_item_name				 NVARCHAR(50) = ''
	,@p_plat_no				 nvarchar(50) = ''
	,@p_engine_no			 nvarchar(50) = ''
	,@p_chasis_no			 nvarchar(40) = ''
	,@p_asset_code			 nvarchar(50) = ''
	--
	,@p_mod_date			 datetime
	,@p_mod_by				 nvarchar(15)
	,@p_mod_ip_address		 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		UPDATE dbo.final_grn_request_detail set

			--final_grn_request_no					= @p_final_grn_request_no
			--,asset_no								= @p_asset_no
			--,delivery_to							= @p_delivery_to
			--,year									= @p_year
			--,colour								= @p_colour
			--,po_code_asset						= @p_po_code_asset
			--,grn_code_asset							= @p_grn_code_asset
			--,grn_detail_id_asset					= @p_grn_detail_id_asset
			--,supplier_name_asset					= @p_supplier_name_asset
			--,grn_receive_date						= @p_grn_receive_date
			asset_name								= @p_item_name
			,plat_no								= @p_plat_no
			,engine_no								= @p_engine_no
			,chasis_no								= @p_chasis_no
			--,status								= @p_status
			,asset_code								= @p_asset_code
			--										--
			,mod_date								= @p_mod_date
			,mod_by									= @p_mod_by
			,mod_ip_address							= @p_mod_ip_address
			WHERE id = @p_id

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
