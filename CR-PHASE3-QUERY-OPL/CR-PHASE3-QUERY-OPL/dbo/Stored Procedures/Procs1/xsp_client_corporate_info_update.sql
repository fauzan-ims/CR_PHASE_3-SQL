CREATE PROCEDURE dbo.xsp_client_corporate_info_update
(
	@p_client_code					 nvarchar(50)
	,@p_client_no					 nvarchar(50)
	,@p_full_name					 nvarchar(50)
	,@p_est_date					 datetime
	,@p_corporate_status_code		 nvarchar(50)
	,@p_business_line_code			 nvarchar(50)
	,@p_sub_business_line_code		 nvarchar(50)
	,@p_corporate_type_code			 nvarchar(50)
	,@p_email						 nvarchar(50)  = null
	,@p_website						 nvarchar(50)  = null
	,@p_area_mobile_no				 nvarchar(4)
	,@p_mobile_no					 nvarchar(15)
	,@p_area_fax_no					 nvarchar(4)   = null
	,@p_fax_no						 nvarchar(15)  = null
	,@p_contact_person_name			 nvarchar(250)
	,@p_contact_person_area_phone_no nvarchar(4)
	,@p_contact_person_phone_no		 nvarchar(15)
	,@p_client_group_code			 nvarchar(50)  = null
	,@p_client_group_name			 nvarchar(50)  = null
	--
	,@p_mod_date					 datetime
	,@p_mod_by						 nvarchar(15)
	,@p_mod_ip_address				 nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max)
			,@business_experience_year	int ;

	begin try
		if (@p_est_date > dbo.xfn_get_system_date())
		begin
			set @msg = 'Established Date must be less or equal than System Date';
			raiserror(@msg, 16, -1) ;
		end 

		set @business_experience_year = datediff(yy, @p_est_date, getdate())

		exec [dbo].[xsp_client_update_invalid] @p_client_code	  = @p_client_code  
											   ,@p_mod_date		  = @p_mod_date
											   ,@p_mod_by		  = @p_mod_by
											   ,@p_mod_ip_address = @p_mod_ip_address

		update	client_corporate_info
		set		full_name						= upper(@p_full_name)
				,est_date						= @p_est_date
				,corporate_status_code			= @p_corporate_status_code
				,business_line_code				= @p_business_line_code
				,sub_business_line_code			= @p_sub_business_line_code
				,corporate_type_code			= @p_corporate_type_code
				,business_experience_year		= @business_experience_year
				,email							= lower(@p_email)
				,website						= lower(@p_website)
				,area_mobile_no					= @p_area_mobile_no
				,mobile_no						= @p_mobile_no
				,area_fax_no					= @p_area_fax_no
				,fax_no							= @p_fax_no
				,contact_person_name			= upper(@p_contact_person_name)
				,contact_person_area_phone_no	= @p_contact_person_area_phone_no
				,contact_person_phone_no		= @p_contact_person_phone_no
				--
				,mod_date						= @p_mod_date
				,mod_by = @p_mod_by
				,mod_ip_address					= @p_mod_ip_address
		where	client_code						= @p_client_code ;

		update	dbo.client_main
		set		client_name		   = upper(@p_full_name)
				,client_group_code = @p_client_group_code
				,client_group_name = @p_client_group_name
		where	code			   = @p_client_code ;

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


