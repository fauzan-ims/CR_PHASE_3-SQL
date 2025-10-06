CREATE PROCEDURE dbo.xsp_client_personal_info_update
(
	@p_client_code				nvarchar(50)
	,@p_client_no				nvarchar(50)
	,@p_full_name				nvarchar(250)
	,@p_alias_name				nvarchar(250)
	,@p_mother_maiden_name		nvarchar(250)
	,@p_place_of_birth			nvarchar(250)
	,@p_date_of_birth			datetime
	,@p_religion_type_code		nvarchar(50)
	,@p_gender_code				nvarchar(50)
	,@p_email					nvarchar(50) = ''
	,@p_area_mobile_no			nvarchar(4)
	,@p_mobile_no				nvarchar(15)
	,@p_nationality_type_code	nvarchar(50)
	,@p_salutation_prefix_code	nvarchar(50) = null
	,@p_salutation_postfix_code nvarchar(50) = null
	,@p_education_type_code		nvarchar(50) = null
	,@p_marriage_type_code		nvarchar(50)
	,@p_dependent_count			int
	,@p_client_group_code		nvarchar(50) = null
	,@p_client_group_name		nvarchar(250) = null
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if (@p_date_of_birth > dbo.xfn_get_system_date())
		begin
			set @msg = 'Date of Birth must be less or equal than System Date';
			raiserror(@msg, 16, -1) ;
		end 

		exec [dbo].[xsp_client_update_invalid] @p_client_code	  = @p_client_code  
											   ,@p_mod_date		  = @p_mod_date
											   ,@p_mod_by		  = @p_mod_by
											   ,@p_mod_ip_address = @p_mod_ip_address

		update	client_personal_info
		set		full_name					= UPPER(@p_full_name)
				,alias_name					= upper(@p_alias_name)
				,mother_maiden_name			= UPPER(@p_mother_maiden_name)
				,place_of_birth				= upper(@p_place_of_birth)
				,date_of_birth				= @p_date_of_birth
				,religion_type_code			= @p_religion_type_code
				,gender_code				= @p_gender_code
				,email						= LOWER(@p_email)
				,area_mobile_no				= @p_area_mobile_no
				,mobile_no					= @p_mobile_no
				,nationality_type_code		= @p_nationality_type_code
				,salutation_prefix_code		= @p_salutation_prefix_code
				,salutation_postfix_code	= @p_salutation_postfix_code
				,education_type_code		= @p_education_type_code
				,marriage_type_code			= @p_marriage_type_code
				,dependent_count			= @p_dependent_count
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	client_code					= @p_client_code ;
		
		update	dbo.client_main
		set		client_name			= upper(@p_full_name)
				,client_group_code	= @p_client_group_code
				,client_group_name	= @p_client_group_name
		where	code				= @p_client_code ;
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

