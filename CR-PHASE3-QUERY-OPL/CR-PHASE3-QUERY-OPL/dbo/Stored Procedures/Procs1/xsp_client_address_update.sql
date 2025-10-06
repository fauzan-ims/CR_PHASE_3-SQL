CREATE PROCEDURE dbo.xsp_client_address_update
(
	@p_code			   nvarchar(50)
	,@p_client_code	   nvarchar(50)
	,@p_address		   nvarchar(4000)
	,@p_province_code  nvarchar(50)
	,@p_province_name  nvarchar(250)
	,@p_city_code	   nvarchar(50)
	,@p_city_name	   nvarchar(250)
	,@p_zip_code_code  nvarchar(50)
	,@p_zip_code	   nvarchar(50)
	,@p_zip_name	   nvarchar(250)
	,@p_sub_district   nvarchar(250)
	,@p_village		   nvarchar(250)
	,@p_rt			   nvarchar(5)
	,@p_rw			   nvarchar(5)
	,@p_area_phone_no  nvarchar(4)
	,@p_phone_no	   nvarchar(15)
	,@p_is_legal	   nvarchar(1)
	,@p_is_collection  nvarchar(1)
	,@p_is_mailing	   nvarchar(1)
	,@p_is_residence   nvarchar(1)
	,@p_range_in_km	   decimal(18, 2)
	,@p_ownership	   nvarchar(250)
	,@p_lenght_of_stay int = 0
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_legal = 'T'
		set @p_is_legal = '1' ;
	else
		set @p_is_legal = '0' ;

	if @p_is_collection = 'T'
		set @p_is_collection = '1' ;
	else
		set @p_is_collection = '0' ;

	if @p_is_mailing = 'T'
		set @p_is_mailing = '1' ;
	else
		set @p_is_mailing = '0' ;

	if @p_is_residence = 'T'
		set @p_is_residence = '1' ;
	else
		set @p_is_residence = '0' ;

	begin try
		exec [dbo].[xsp_client_update_invalid] @p_client_code		= @p_client_code  
												,@p_mod_date		= @p_mod_date
												,@p_mod_by			= @p_mod_by
												,@p_mod_ip_address	= @p_mod_ip_address

		update	client_address
		set		client_code		= @p_client_code
				,address		= @p_address
				,province_code	= @p_province_code
				,province_name	= @p_province_name
				,city_code		= @p_city_code
				,city_name		= @p_city_name
				,zip_code_code  = @p_zip_code_code
				,zip_code		= @p_zip_code
				,zip_name		= @p_zip_name
				,sub_district	= @p_sub_district
				,village		= @p_village
				,rt				= @p_rt
				,rw				= @p_rw
				,area_phone_no	= @p_area_phone_no
				,phone_no		= @p_phone_no
				,is_legal		= @p_is_legal
				,is_collection	= @p_is_collection
				,is_mailing		= @p_is_mailing
				,is_residence	= @p_is_residence
				,range_in_km	= @p_range_in_km
				,ownership		= upper(@p_ownership)
				,lenght_of_stay = @p_lenght_of_stay
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	code			= @p_code ;
		
		if @p_is_legal = '1'
		begin
			update	dbo.client_address
			set		is_legal		= '0'
			where	client_code		= @p_client_code
			and		code			<> @p_code
		end

		if @p_is_collection = '1'
		begin
			update	dbo.client_address
			set		is_collection	= '0'
			where	client_code		= @p_client_code
			and		code			<> @p_code
		end

		if @p_is_mailing = '1'
		begin
			update	dbo.client_address
			set		is_mailing		= '0'
			where	client_code		= @p_client_code
			and		code			<> @p_code
		end

		if @p_is_residence = '1'
		begin
			update	dbo.client_address
			set		is_residence	= '0'
			where	client_code		= @p_client_code
			and		code			<> @p_code
		end
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


