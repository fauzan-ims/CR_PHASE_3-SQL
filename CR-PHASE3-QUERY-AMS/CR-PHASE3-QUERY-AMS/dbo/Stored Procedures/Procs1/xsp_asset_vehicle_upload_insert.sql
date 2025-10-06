CREATE PROCEDURE dbo.xsp_asset_vehicle_upload_insert
(
	@p_fa_upload_id			  bigint = 0 output
	,@p_file_name			  nvarchar(250)
	,@p_upload_no			  nvarchar(50)
	,@p_asset_code			  nvarchar(50)
	,@p_merk_code			  nvarchar(50)
	,@p_merk_name			  nvarchar(250)
	,@p_type_code			  nvarchar(50)
	,@p_type_name			  nvarchar(250)
	,@p_model_code			  nvarchar(50)
	,@p_model_name			  nvarchar(250)
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
	,@p_cre_date			  datetime
	,@p_cre_by				  nvarchar(15)
	,@p_cre_ip_address		  nvarchar(15)
	,@p_mod_date			  datetime
	,@p_mod_by				  nvarchar(15)
	,@p_mod_ip_address		  nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into asset_vehicle_upload
		(
			file_name
			,upload_no
			,asset_code
			,merk_code
			,merk_name
			,type_code
			,type_name
			,model_code
			,model_name
			,plat_no
			,chassis_no
			,engine_no
			,bpkb_no
			,colour
			,cylinder
			,stnk_no
			,stnk_expired_date
			,stnk_tax_date
			,stnk_renewal
			,built_year
			,last_miles
			,last_maintenance_date
			,purchase
			,remark
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_file_name
			,@p_upload_no
			,@p_asset_code
			,@p_merk_code
			,@p_merk_name
			,@p_type_code
			,@p_type_name
			,@p_model_code
			,@p_model_name
			,@p_plat_no
			,@p_chassis_no
			,@p_engine_no
			,@p_bpkb_no
			,@p_colour
			,@p_cylinder
			,@p_stnk_no
			,@p_stnk_expired_date
			,@p_stnk_tax_date
			,@p_stnk_renewal
			,@p_built_year
			,@p_last_miles
			,@p_last_maintenance_date
			,@p_purchase
			,@p_remark
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		)set @p_fa_upload_id = @@identity ;
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
