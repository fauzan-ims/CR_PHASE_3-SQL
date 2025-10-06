CREATE procedure dbo.xsp_efam_interface_asset_barcode_image_update
(
	@p_asset_code	  nvarchar(50)
	,@p_barcode		  nvarchar(50)
	,@p_barcode_image image
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	efam_interface_asset_barcode_image
		set		barcode = @p_barcode
				,barcode_image = @p_barcode_image
		where	asset_code = @p_asset_code ;
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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
