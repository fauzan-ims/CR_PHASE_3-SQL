CREATE PROCEDURE dbo.xsp_master_public_service_address_update
(
	@p_id					bigint
	,@p_public_service_code nvarchar(50)
	,@p_province_code		nvarchar(50)
	,@p_province_name		nvarchar(250)
	,@p_city_code			nvarchar(50)
	,@p_city_name			nvarchar(250)
	,@p_zip_code			nvarchar(50)
	,@p_sub_district		nvarchar(250)
	,@p_village				nvarchar(250)
	,@p_address				nvarchar(4000)
	,@p_rt					nvarchar(5)
	,@p_rw					nvarchar(5)
	,@p_is_latest			nvarchar(1)
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_latest = 'T'
		set @p_is_latest = '1' ;
	else
		set @p_is_latest = '0' ;

	begin try
    
		if @p_is_latest = '1'
		begin
			update	dbo.master_public_service_address
			set		is_latest = 0
			where	public_service_code = @p_public_service_code
			and		is_latest = 1
		end

		update	master_public_service_address
		set		public_service_code = @p_public_service_code
				,province_code		= @p_province_code
				,province_name		= @p_province_name
				,city_code			= @p_city_code
				,city_name			= @p_city_name
				,zip_code			= @p_zip_code
				,sub_district		= @p_sub_district
				,village			= @p_village
				,address			= @p_address
				,rt					= @p_rt
				,rw					= @p_rw
				,is_latest			= @p_is_latest
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	id					= @p_id ;
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



