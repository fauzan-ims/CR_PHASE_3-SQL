--BEGIN TRANSACTION 
CREATE PROCEDURE [dbo].[xsp_client_corporate_info_insert_from_cms]
(
	@p_client_code					 nvarchar(50) = '' output
	,@p_full_name					 nvarchar(50)
	,@p_client_no					 nvarchar(50)
	,@p_est_date					 datetime
	,@p_corporate_status_code		 nvarchar(50)
	,@p_business_line_code			 nvarchar(50)
	,@p_sub_business_line_code		 nvarchar(50)
	,@p_corporate_type_code			 nvarchar(50)
	,@p_business_experience_year	 int
	,@p_email						 nvarchar(50) = null
	,@p_website						 nvarchar(50) = null
	,@p_area_mobile_no				 nvarchar(4)
	,@p_mobile_no					 nvarchar(15)
	,@p_area_fax_no					 nvarchar(4)   = null
	,@p_fax_no						 nvarchar(15)  = null
	,@p_contact_person_name			 nvarchar(250)
	,@p_contact_person_area_phone_no nvarchar(4)
	,@p_contact_person_phone_no		 nvarchar(15)
	,@p_client_group_code			 nvarchar(50)  = null
	,@p_client_group_name			 nvarchar(250) = null
	--
	,@p_cre_date					 datetime
	,@p_cre_by						 nvarchar(15)
	,@p_cre_ip_address				 nvarchar(15)
	,@p_mod_date					 datetime
	,@p_mod_by						 nvarchar(15)
	,@p_mod_ip_address				 nvarchar(15)
)
as
begin
	declare @msg					   nvarchar(max)
			,@year					   nvarchar(2)
			,@month					   nvarchar(2)
			,@client_code			   nvarchar(50)
			,@business_experience_year int ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @client_code output
												,@p_branch_code = ''
												,@p_sys_document_code = ''
												,@p_custom_prefix = 'LCC'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'CLIENT_CORPORATE_INFO'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	begin try
		set @business_experience_year = datediff(yy, @p_est_date, getdate()) ;
	
		exec dbo.xsp_client_main_insert @p_code							= @client_code
										,@p_client_no					= @p_client_no
										,@p_client_type					= 'CORPORATE' 
										,@p_client_name					= @p_full_name
										,@p_is_validate					= 'F'
										,@p_status_slik_checking		= '0'
										,@p_status_dukcapil_checking	= '0'
										,@p_is_existing_client			= '1'
										,@p_client_group_code			= @p_client_group_code
										,@p_client_group_name			= @p_client_group_name
										,@p_cre_date					= @p_cre_date
										,@p_cre_by						= @p_cre_by
										,@p_cre_ip_address				= @p_cre_ip_address
										,@p_mod_date					= @p_mod_date
										,@p_mod_by						= @p_mod_by
										,@p_mod_ip_address				= @p_mod_ip_address

		insert into client_corporate_info
		(
			client_code
			,full_name
			,est_date
			,corporate_status_code
			,business_line_code
			,sub_business_line_code
			,corporate_type_code
			,business_experience_year
			,email
			,website
			,area_mobile_no
			,mobile_no
			,area_fax_no
			,fax_no
			,contact_person_name
			,contact_person_area_phone_no
			,contact_person_phone_no
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
			,@p_est_date
			,@p_corporate_status_code
			,@p_business_line_code
			,@p_sub_business_line_code
			,@p_corporate_type_code
			,@p_business_experience_year
			,lower(@p_email)
			,lower(@p_website)
			,@p_area_mobile_no
			,@p_mobile_no
			,@p_area_fax_no
			,@p_fax_no
			,upper(@p_contact_person_name)
			,@p_contact_person_area_phone_no
			,@p_contact_person_phone_no
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
		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;



