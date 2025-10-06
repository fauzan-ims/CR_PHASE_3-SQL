CREATE procedure dbo.xsp_efam_interface_asset_furniture_update
(
	@p_asset_code	   nvarchar(50)
	,@p_merk_code	   nvarchar(50)
	,@p_merk_name	   nvarchar(250)
	,@p_type_code	   nvarchar(50)
	,@p_type_name	   nvarchar(250)
	,@p_model_code	   nvarchar(50)
	,@p_model_name	   nvarchar(250)
	,@p_remark		   nvarchar(4000)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	efam_interface_asset_furniture
		set		merk_code			 = @p_merk_code
				,merk_name			 = @p_merk_name
				,type_code			 = @p_type_code
				,type_name			 = @p_type_name
				,model_code			 = @p_model_code
				,model_name			 = @p_model_name
				,remark				 = @p_remark
				--
				,mod_date			 = @p_mod_date
				,mod_by				 = @p_mod_by
				,mod_ip_address		 = @p_mod_ip_address
		where	asset_code			 = @p_asset_code ;
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
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
