CREATE PROCEDURE dbo.xsp_application_guarantor_insert
(
	@p_id					  bigint		= 0 output
	,@p_application_no		  nvarchar(50)
	,@p_guarantor_client_type nvarchar(10)
	,@p_guarantor_client_code nvarchar(50)	= null
	,@p_relationship		  nvarchar(250)
	,@p_guaranted_pct		  decimal(9, 6)
	,@p_remarks				  nvarchar(4000)
	--
	,@p_full_name			  nvarchar(250)
	,@p_gender_code			  nvarchar(50)	= null
	,@p_mother_maiden_name	  nvarchar(250) = null
	,@p_place_of_birth		  nvarchar(250) = null
	,@p_date_of_birth		  datetime		= null
	,@p_province_code		  nvarchar(50)	= null
	,@p_province_name		  nvarchar(250) = null
	,@p_city_code			  nvarchar(50)	= null
	,@p_city_name			  nvarchar(250) = null
	,@p_zip_code			  nvarchar(50)	= null
	,@p_zip_code_code		  nvarchar(50)	= null
	,@p_zip_name			  nvarchar(250) = null
	,@p_sub_district		  nvarchar(250) = null
	,@p_village				  nvarchar(250) = null
	,@p_address				  nvarchar(4000)
	,@p_rt					  nvarchar(5)	= null
	,@p_rw					  nvarchar(5)	= null
	,@p_area_mobile_no		  nvarchar(4)	= null
	,@p_mobile_no			  nvarchar(15)	= null
	,@p_id_no				  nvarchar(50)	= null
	,@p_npwp_no				  nvarchar(50)	= null
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

	if exists
	(
		select	1
		from	dbo.application_guarantor
		where	application_no				 = @p_application_no
				and (
						id_no				 = @p_id_no
						or	npwp_no			 = @p_npwp_no
					)
	)
	begin
		set @msg = 'Client Guarantor already exists' ;

		raiserror(@msg, 16, -1) ;
	end ;

	begin try
		insert into application_guarantor
		(
			application_no
			,guarantor_client_type
			,guarantor_client_code
			,relationship
			,guaranted_pct
			,remarks
			,full_name
			,gender_code
			,mother_maiden_name
			,place_of_birth
			,date_of_birth
			,province_code
			,province_name
			,city_code
			,city_name
			,zip_code
			,zip_code_code
			,zip_name
			,sub_district
			,village
			,address
			,rt
			,rw
			,area_mobile_no
			,mobile_no
			,id_no
			,npwp_no
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_application_no
			,@p_guarantor_client_type
			,@p_guarantor_client_code
			,@p_relationship
			,@p_guaranted_pct
			,@p_remarks
			,@p_full_name
			,@p_gender_code
			,@p_mother_maiden_name
			,@p_place_of_birth
			,@p_date_of_birth
			,@p_province_code
			,@p_province_name
			,@p_city_code
			,@p_city_name
			,@p_zip_code
			,@p_zip_code_code
			,@p_zip_name
			,@p_sub_district
			,@p_village
			,@p_address
			,@p_rt
			,@p_rw
			,@p_area_mobile_no
			,@p_mobile_no
			,@p_id_no
			,@p_npwp_no
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;
	end try
	Begin catch
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

