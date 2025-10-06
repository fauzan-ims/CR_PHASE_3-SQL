CREATE PROCEDURE dbo.xsp_application_asset_vehicle_insert
(
	@p_asset_no				     nvarchar(50)
	,@p_vehicle_category_code	 nvarchar(50)	= null
	,@p_vehicle_subcategory_code nvarchar(50)	= null
	,@p_vehicle_merk_code		 nvarchar(50)	= null
	,@p_vehicle_model_code		 nvarchar(50)	= null
	,@p_vehicle_type_code		 nvarchar(50)	= null
	,@p_vehicle_unit_code		 nvarchar(50)	= null 
	,@p_colour					 nvarchar(250)	= null 
	,@p_transmisi				 nvarchar(250)	= null
	,@p_remarks					 nvarchar(4000)	= null
	--
	,@p_cre_date				 datetime
	,@p_cre_by					 nvarchar(15)
	,@p_cre_ip_address			 nvarchar(15)
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into application_asset_vehicle
		(
			asset_no
			,vehicle_category_code
			,vehicle_subcategory_code
			,vehicle_merk_code
			,vehicle_model_code
			,vehicle_type_code
			,vehicle_unit_code 
			,colour 
			,transmisi
			,remarks
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_asset_no
			,@p_vehicle_category_code
			,@p_vehicle_subcategory_code
			,@p_vehicle_merk_code
			,@p_vehicle_model_code
			,@p_vehicle_type_code
			,@p_vehicle_unit_code  
			,upper(@p_colour) 
			,@p_transmisi
			,@p_remarks
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


