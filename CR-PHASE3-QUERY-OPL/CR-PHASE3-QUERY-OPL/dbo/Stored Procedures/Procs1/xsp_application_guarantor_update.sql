CREATE PROCEDURE dbo.xsp_application_guarantor_update
(
	@p_id					  bigint
	,@p_application_no		  nvarchar(50)
	,@p_guarantor_client_code nvarchar(50)
	,@p_relationship		  nvarchar(250)
	,@p_guaranted_pct		  decimal(9, 6)
	,@p_remarks				  nvarchar(4000)
	,@p_full_name			  nvarchar(250)
	,@p_gender_code			  nvarchar(50)	   = null
	,@p_mother_maiden_name	  nvarchar(250)	   = null
	,@p_place_of_birth		  nvarchar(250)	   = null
	,@p_date_of_birth		  datetime		   = null
	,@p_province_code		  nvarchar(50)	   = null
	,@p_province_name		  nvarchar(250)	   = null
	,@p_city_code			  nvarchar(50)	   = null
	,@p_city_name			  nvarchar(250)	   = null
	,@p_zip_code			  nvarchar(50)	   = null
	,@p_zip_code_code		  nvarchar(50)	   = null
	,@p_zip_name			  nvarchar(250)	   = null
	,@p_sub_district		  nvarchar(250)	   = null
	,@p_village				  nvarchar(250)	   = null
	,@p_address				  nvarchar(4000)
	,@p_rt					  nvarchar(5)	   = null
	,@p_rw					  nvarchar(5)	   = null
	,@p_area_mobile_no		  nvarchar(4)	   = null
	,@p_mobile_no			  nvarchar(15)	   = null
	,@p_id_no				  nvarchar(50)	   = null
	,@p_npwp_no				  nvarchar(50)	   = null
	--
	,@p_mod_date			  datetime
	,@p_mod_by				  nvarchar(15)
	,@p_mod_ip_address		  nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;
	

	if exists
	(
		select	1
		from	dbo.application_guarantor
		where	application_no				 = @p_application_no
				and (
						id_no				 = @p_id_no
						or	npwp_no			 = @p_npwp_no
					)
				and id						 <> @p_id
	)
	begin
		set @msg = 'Client Guarantor already exists' ;

		raiserror(@msg, 16, -1) ;
	end ;
	begin try
		update	application_guarantor
		set		relationship			= @p_relationship
				,guaranted_pct			= @p_guaranted_pct
				,remarks				= @p_remarks
				,full_name				= @p_full_name
				,gender_code			= @p_gender_code
				,mother_maiden_name		= @p_mother_maiden_name
				,place_of_birth			= @p_place_of_birth
				,date_of_birth			= @p_date_of_birth
				,province_code			= @p_province_code
				,province_name			= @p_province_name
				,city_code				= @p_city_code
				,city_name				= @p_city_name
				,zip_code				= @p_zip_code
				,zip_code_code			= @p_zip_code_code
				,zip_name				= @p_zip_name
				,sub_district			= @p_sub_district
				,village				= @p_village
				,address				= @p_address
				,rt						= @p_rt
				,rw						= @p_rw
				,area_mobile_no			= @p_area_mobile_no
				,mobile_no				= @p_mobile_no
				,id_no					= @p_id_no
				,npwp_no				= @p_npwp_no
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	id						= @p_id ;
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

