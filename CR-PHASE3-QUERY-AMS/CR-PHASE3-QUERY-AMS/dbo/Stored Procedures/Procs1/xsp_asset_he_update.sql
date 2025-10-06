CREATE PROCEDURE dbo.xsp_asset_he_update
(
	@p_asset_code				nvarchar(50)
	,@p_merk_code				nvarchar(50)	= ''
	,@p_merk_name				nvarchar(250)	= ''
	,@p_type_item_code			nvarchar(50)	= ''
	,@p_type_item_name			nvarchar(250)	= ''
	,@p_model_code				nvarchar(50)	= ''
	,@p_built_year				nvarchar(4)		= ''
	,@p_invoice_no_detail		nvarchar(50)	= ''
	,@p_chassis_no				nvarchar(50)	= ''
	,@p_engine_no				nvarchar(50)	= ''
	,@p_colour					nvarchar(50)	= ''
	,@p_serial_no				nvarchar(50)	= ''
	,@p_remark					nvarchar(4000)	= ''
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
	,@p_model_name				nvarchar(250)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	asset_he
		set		merk_code					= @p_merk_code
				,merk_name					= @p_merk_name
				,type_item_code				= @p_type_item_code
				,type_item_name				= @p_type_item_name
				,model_code					= @p_model_code
				,built_year					= @p_built_year
				,invoice_no					= @p_invoice_no_detail
				,chassis_no					= @p_chassis_no
				,engine_no					= @p_engine_no
				,colour						= @p_colour
				,serial_no					= @p_serial_no
				,remark						= @p_remark
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
				,model_name					= @p_model_name
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
