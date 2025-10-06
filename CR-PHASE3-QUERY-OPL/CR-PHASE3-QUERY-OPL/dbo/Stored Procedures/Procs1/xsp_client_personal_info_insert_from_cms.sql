CREATE PROCEDURE dbo.xsp_client_personal_info_insert_from_cms
(
	@p_client_code				nvarchar(50) output
	,@p_full_name				nvarchar(250) = null
	,@p_client_no				nvarchar(50)  = null
	,@p_alias_name				nvarchar(250) = null
	,@p_mother_maiden_name		nvarchar(250) = null
	,@p_place_of_birth			nvarchar(250) = null
	,@p_date_of_birth			datetime	  = null
	,@p_religion_type_code		nvarchar(50)  = null
	,@p_gender_code				nvarchar(50)  = null
	,@p_email					nvarchar(50)  = null
	,@p_area_mobile_no			nvarchar(4)	  = null
	,@p_mobile_no				nvarchar(15)  = null
	,@p_nationality_type_code	nvarchar(50)  = null
	,@p_salutation_prefix_code	nvarchar(50)  = null
	,@p_salutation_postfix_code nvarchar(50)  = null
	,@p_education_type_code		nvarchar(50)  = null
	,@p_marriage_type_code		nvarchar(50)  = null
	,@p_dependent_count			int
	,@p_client_group_code       nvarchar(50)	= null
	,@p_client_group_name       nvarchar(250)	= null
	--
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max)
			,@year			nvarchar(2)
			,@month			nvarchar(2)
			,@client_code	nvarchar(50) ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;
	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @client_code output
												,@p_branch_code = ''
												,@p_sys_document_code = ''
												,@p_custom_prefix = 'LCP'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'CLIENT_PERSONAL_INFO'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	begin try
		exec dbo.xsp_client_main_insert @p_code							= @client_code
										,@p_client_no					= @p_client_no
										,@p_client_type					= 'PERSONAL' 
										,@p_client_name					= @p_full_name
										,@p_is_validate					= 'F'
										,@p_status_slik_checking		= ''
										,@p_status_dukcapil_checking	= ''
										,@p_is_existing_client			= '1'
										,@p_client_group_code			= @p_client_group_code
										,@p_client_group_name			= @p_client_group_name
										,@p_cre_date					= @p_cre_date
										,@p_cre_by						= @p_cre_by
										,@p_cre_ip_address				= @p_cre_ip_address
										,@p_mod_date					= @p_mod_date
										,@p_mod_by						= @p_mod_by
										,@p_mod_ip_address				= @p_mod_ip_address

		insert into client_personal_info
		(
			client_code
			,full_name
			,alias_name
			,mother_maiden_name
			,place_of_birth
			,date_of_birth
			,religion_type_code
			,gender_code
			,email
			,area_mobile_no
			,mobile_no
			,nationality_type_code
			,salutation_prefix_code
			,salutation_postfix_code
			,education_type_code
			,marriage_type_code
			,dependent_count
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@client_code
			,upper(@p_full_name)
			,upper(@p_alias_name)
			,upper(@p_mother_maiden_name)
			,upper(@p_place_of_birth)
			,@p_date_of_birth
			,@p_religion_type_code
			,@p_gender_code
			,lower(@p_email)
			,@p_area_mobile_no
			,@p_mobile_no
			,@p_nationality_type_code
			,@p_salutation_prefix_code
			,@p_salutation_postfix_code
			,@p_education_type_code
			,@p_marriage_type_code
			,@p_dependent_count
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_client_code = @client_code ;
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

