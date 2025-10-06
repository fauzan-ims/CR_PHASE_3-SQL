CREATE PROCEDURE dbo.xsp_asset_vehicle_upload_update
(
	@p_fa_upload_id			  bigint
	,@p_file_name			  nvarchar(250)
	,@p_upload_no			  nvarchar(50)
	,@p_asset_code			  nvarchar(50)
	,@p_merk_code			  nvarchar(50)
	,@p_merk_name			  nvarchar(250)
	,@p_type_code			  nvarchar(50)
	,@p_type_name			  nvarchar(250)
	,@p_model_code			  nvarchar(50)
	,@p_plat_no				  nvarchar(20)
	,@p_chassis_no			  nvarchar(50)
	,@p_engine_no			  nvarchar(50)
	,@p_bpkb_no				  nvarchar(50)
	,@p_colour				  nvarchar(50)
	,@p_cylinder			  nvarchar(20)
	,@p_stnk_no				  nvarchar(50)
	,@p_stnk_expired_date	  datetime
	,@p_stnk_tax_date		  datetime
	,@p_stnk_renewal		  nvarchar(15)
	,@p_built_year			  nvarchar(4)
	,@p_last_miles			  nvarchar(15)
	,@p_last_maintenance_date datetime
	,@p_purchase			  nvarchar(50)
	,@p_remark				  nvarchar(4000)
	--
	,@p_mod_date			  datetime
	,@p_mod_by				  nvarchar(15)
	,@p_mod_ip_address		  nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	asset_vehicle_upload
		set		file_name				= @p_file_name
				,upload_no				= @p_upload_no
				,asset_code				= @p_asset_code
				,merk_code				= @p_merk_code
				,merk_name				= @p_merk_name
				,type_code				= @p_type_code
				,type_name				= @p_type_name
				,model_code				= @p_model_code
				,plat_no				= @p_plat_no
				,chassis_no				= @p_chassis_no
				,engine_no				= @p_engine_no
				,bpkb_no				= @p_bpkb_no
				,colour					= @p_colour
				,cylinder				= @p_cylinder
				,stnk_no				= @p_stnk_no
				,stnk_expired_date		= @p_stnk_expired_date
				,stnk_tax_date			= @p_stnk_tax_date
				,stnk_renewal			= @p_stnk_renewal
				,built_year				= @p_built_year
				,last_miles				= @p_last_miles
				,last_maintenance_date	= @p_last_maintenance_date
				,purchase				= @p_purchase
				,remark					= @p_remark
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	fa_upload_id			= @p_fa_upload_id ;
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
