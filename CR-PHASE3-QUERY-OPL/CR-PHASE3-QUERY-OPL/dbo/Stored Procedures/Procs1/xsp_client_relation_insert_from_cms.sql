CREATE PROCEDURE dbo.xsp_client_relation_insert_from_cms

(
	@p_id						   bigint 
	,@p_client_code				   nvarchar(50)	  = ''
	,@p_relation_client_code	   nvarchar(50)	  = ''
	,@p_relation_type			   nvarchar(15)	  = ''
	,@p_client_type				   nvarchar(10)	  = ''
	,@p_full_name				   nvarchar(250)	= null
	,@p_gender_code				   nvarchar(50)		= null
	,@p_mother_maiden_name		   nvarchar(250)	= null
	,@p_place_of_birth			   nvarchar(250)	= null
	,@p_date_of_birth			   datetime			= null
	,@p_province_code			   nvarchar(50)		= null
	,@p_province_name			   nvarchar(250)	= null
	,@p_city_code				   nvarchar(50)		= null
	,@p_city_name				   nvarchar(250)	= null
	,@p_zip_code				   nvarchar(50)		= null
	,@p_zip_name				   nvarchar(250)	= null
	,@p_sub_district			   nvarchar(250)	= null
	,@p_village					   nvarchar(250)	= null
	,@p_address					   nvarchar(4000)	= null
	,@p_rt						   nvarchar(5)		= null
	,@p_rw						   nvarchar(5)		= null
	,@p_area_mobile_no			   nvarchar(4)		= null
	,@p_mobile_no				   nvarchar(15)		= null
	,@p_id_no					   nvarchar(50)		= ''
	,@p_npwp_no					   nvarchar(50)		= null
	,@p_shareholder_pct			   decimal(9, 6)	= 0
	,@p_is_officer				   nvarchar(1)		= null
	,@p_officer_signer_type		   nvarchar(10)		= null
	,@p_officer_position_type_code nvarchar(50)		= null
	,@p_order_key				   int				= 0
	,@p_is_emergency_contact	   nvarchar(1)		= null
	,@p_family_type_code		   nvarchar(50)		= null
	,@p_reference_type_code		   nvarchar(50)		= null
	,@p_is_latest				   nvarchar(1)		= '1'
	,@p_counter					   int				= 1
	,@p_shareholder_type		   nvarchar(10)		= null
	,@p_dati_ii_code			   nvarchar(50)		= null
	,@p_dati_ii_ojk_code		   nvarchar(50)		= null
	,@p_dati_ii_name			   nvarchar(250)	= null
	--
	,@p_cre_date				   datetime
	,@p_cre_by					   nvarchar(15)
	,@p_cre_ip_address			   nvarchar(15)
	,@p_mod_date				   datetime
	,@p_mod_by					   nvarchar(15)
	,@p_mod_ip_address			   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into client_relation
		(
			client_code
			,relation_client_code
			,relation_type
			,client_type
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
			,shareholder_pct
			,is_officer
			,officer_signer_type
			,officer_position_type_code
			,order_key
			,is_emergency_contact
			,family_type_code
			,reference_type_code
			,is_latest
			,counter
			,shareholder_type
			,dati_ii_code
			,dati_ii_ojk_code
			,dati_ii_name
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_client_code
			,@p_relation_client_code
			,@p_relation_type
			,@p_client_type
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
			,@p_shareholder_pct
			,@p_is_officer
			,@p_officer_signer_type
			,@p_officer_position_type_code
			,@p_order_key
			,@p_is_emergency_contact
			,@p_family_type_code
			,@p_reference_type_code
			,'1'
			,@p_counter
			,@p_shareholder_type
			,@p_dati_ii_code
			,@p_dati_ii_ojk_code
			,@p_dati_ii_name
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

