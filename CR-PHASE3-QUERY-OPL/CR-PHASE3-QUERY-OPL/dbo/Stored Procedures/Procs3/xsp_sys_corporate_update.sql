CREATE PROCEDURE dbo.xsp_sys_corporate_update
(
	@p_client_code					 nvarchar(50)
	,@p_full_name					 nvarchar(50)
	,@p_tax_file_no					 nvarchar(50)
	,@p_est_date					 datetime
	,@p_corporate_status			 nvarchar(50)
	,@p_business_type				 nvarchar(50)
	,@p_subbusiness_type			 nvarchar(50)
	,@p_corporate_type				 nvarchar(50)
	,@p_business_experience			 int
	,@p_email						 nvarchar(50)
	,@p_contact_person_name			 nvarchar(100)
	,@p_contact_person_area_phone_no nvarchar(4)
	,@p_contact_person_phone_no		 nvarchar(15)
	--
	,@p_mod_date					 datetime
	,@p_mod_by						 nvarchar(15)
	,@p_mod_ip_address				 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	sys_corporate
		set		full_name						= @p_full_name
				,tax_file_no					= @p_tax_file_no
				,est_date						= @p_est_date
				,corporate_status				= @p_corporate_status
				,business_type					= @p_business_type
				,subbusiness_type				= @p_subbusiness_type
				,corporate_type					= @p_corporate_type
				,business_experience			= @p_business_experience
				,email							= @p_email
				,contact_person_name			= @p_contact_person_name
				,contact_person_area_phone_no	= @p_contact_person_area_phone_no
				,contact_person_phone_no		= @p_contact_person_phone_no
				--
				,mod_date						= @p_mod_date
				,mod_by							= @p_mod_by
				,mod_ip_address					= @p_mod_ip_address
		where	client_code						= @p_client_code ;
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

