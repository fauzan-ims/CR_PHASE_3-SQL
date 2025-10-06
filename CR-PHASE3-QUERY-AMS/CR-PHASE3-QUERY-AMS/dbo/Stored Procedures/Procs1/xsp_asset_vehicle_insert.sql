CREATE PROCEDURE dbo.xsp_asset_vehicle_insert
(
	@p_asset_code							nvarchar(50)
	,@p_merk_code							nvarchar(50)
	,@p_merk_name							nvarchar(250)
	,@p_type_item_code						nvarchar(50)
	,@p_type_item_name						nvarchar(250)
	,@p_model_code							nvarchar(50)
	,@p_model_name							nvarchar(250)
	,@p_plat_no								nvarchar(20)
	,@p_chassis_no							nvarchar(50)
	,@p_engine_no							nvarchar(50)
	,@p_bpkb_no								nvarchar(50)
	,@p_colour								nvarchar(50)
	,@p_cylinder							nvarchar(20)
	,@p_stnk_no								nvarchar(50)
	,@p_stnk_expired_date					datetime
	,@p_stnk_tax_date						datetime
	,@p_stnk_renewal						nvarchar(15)
	,@p_keur_no								nvarchar(50)
	,@p_keur_date							datetime
	,@p_keur_expired_date					datetime
	,@p_built_year							nvarchar(4)
	,@p_remark								nvarchar(4000)
	,@p_stnk_name							nvarchar(50)
	,@p_stnk_date							datetime
	,@p_stnk_address						nvarchar(4000)
	--
	,@p_cre_date							datetime
	,@p_cre_by								nvarchar(15)
	,@p_cre_ip_address						nvarchar(15)
	,@p_mod_date							datetime
	,@p_mod_by								nvarchar(15)
	,@p_mod_ip_address						nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into asset_vehicle
		(
			asset_code
			,merk_code
			,merk_name
			,type_item_code
			,type_item_name
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
			,keur_no
			,keur_date
			,keur_expired_date
			,built_year
			,remark
			,stnk_name
			,stnk_date
			,stnk_address
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_asset_code
			,@p_merk_code
			,@p_merk_name
			,@p_type_item_code
			,@p_type_item_name
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
			,@p_keur_no
			,@p_keur_date
			,@p_keur_expired_date
			,@p_built_year
			,@p_remark
			,@p_stnk_name	
			,@p_stnk_date	
			,@p_stnk_address
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
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
