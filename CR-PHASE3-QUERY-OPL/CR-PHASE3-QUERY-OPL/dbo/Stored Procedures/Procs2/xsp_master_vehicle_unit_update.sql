---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE dbo.xsp_master_vehicle_unit_update
(
	@p_code						 nvarchar(50)
	,@p_vehicle_category_code	 nvarchar(50)
	,@p_vehicle_subcategory_code nvarchar(50)
	,@p_vehicle_merk_code		 nvarchar(50)
	,@p_vehicle_model_code		 nvarchar(50)
	,@p_vehicle_type_code		 nvarchar(50)
	,@p_vehicle_name			 nvarchar(250)
	,@p_description				 nvarchar(250)
	,@p_is_cbu					 nvarchar(1)
	,@p_is_karoseri				 nvarchar(1)
	,@p_is_active				 nvarchar(1)
	--
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_cbu = 'T'
		set @p_is_cbu = '1' ;
	else
		set @p_is_cbu = '0' ;

	if @p_is_karoseri = 'T'
		set @p_is_karoseri = '1' ;
	else
		set @p_is_karoseri = '0' ;

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	begin try
		if exists (select 1 from master_vehicle_unit where description = @p_description and code <> @p_code)
		begin
			set @msg = 'Description already exist';
			raiserror(@msg, 16, -1) ;
		end 

		update	master_vehicle_unit
		set		vehicle_category_code		= @p_vehicle_category_code
				,vehicle_subcategory_code	= @p_vehicle_subcategory_code
				,vehicle_merk_code			= @p_vehicle_merk_code
				,vehicle_model_code			= @p_vehicle_model_code
				,vehicle_type_code			= @p_vehicle_type_code
				,vehicle_name				= upper(@p_vehicle_name)
				,description				= upper(@p_description)
				,is_cbu						= @p_is_cbu
				,is_karoseri				= @p_is_karoseri
				,is_active					= @p_is_active
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	code						= @p_code ;
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


