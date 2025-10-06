CREATE PROCEDURE dbo.xsp_sys_company_register
(
	--@p_code						nvarchar(50) --output
	@p_name					nvarchar(100)
	,@p_address					nvarchar(4000)
	,@p_phone_no				nvarchar(25)
	,@p_fax_no					nvarchar(25)
	,@p_email					nvarchar(50)
	,@p_province_code			nvarchar(50)
	,@p_city_code				nvarchar(50)
	,@p_contact_name			nvarchar(100)
	,@p_contact_phone			nvarchar(25)
	--
	,@p_ip_address				nvarchar(15)
	--,@p_cre_date				datetime
	--,@p_cre_by					nvarchar(15)
	--,@p_cre_ip_address			nvarchar(15)
	--,@p_mod_date				datetime
	--,@p_mod_by					nvarchar(15)
	--,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max)
			,@company_code				nvarchar(50)
			,@subscription_start_date	datetime
			,@subscription_type_code	nvarchar(50)
			,@max_user					int
			,@getdate					datetime = getdate();
			
	begin try
		
		set @subscription_start_date = cast(getdate() as date);
		                  
		select	@subscription_type_code = subscription_type_code 
				,@max_user				= max_user
		from	dbo.sys_it_param
		
		exec dbo.xsp_sys_company_insert @p_code						= @company_code output 
										,@p_name					= @p_name
										,@p_address					= @p_address	
										,@p_phone_no				= @p_phone_no
										,@p_fax_no					= @p_fax_no	
										,@p_npwp					= ''
										,@p_email					= @p_email			
										,@p_province_code			= @p_province_code	
										,@p_city_code				= @p_city_code		
										,@p_contact_name			= @p_contact_name	
										,@p_contact_phone			= @p_contact_phone	
										,@p_subscription_type_code	= @subscription_type_code
										,@p_subscription_start_date = @subscription_start_date
										,@p_max_user				= @max_user
										,@p_is_reminder_by_email	= ''
										,@p_reminder_email			= ''
										,@p_is_reminder_by_sms		= ''
										,@p_reminder_sms			= ''
										,@p_is_reminder_by_whatsapp = ''
										,@p_reminder_whatsapp		= ''
										,@p_is_reminder_by_telegram = ''
										,@p_reminder_telegram		= ''
										,@p_remark					= ''
										,@p_is_active				= '1'
										,@p_is_renual				= ''
										--
										,@p_cre_date				= @getdate--@p_cre_date		
										,@p_cre_by					= 'webregis'--@p_cre_by			
										,@p_cre_ip_address			= @p_ip_address--@p_cre_ip_address	
										,@p_mod_date				= @getdate--@p_mod_date		
										,@p_mod_by					= 'webregis'--@p_mod_by			
										,@p_mod_ip_address			= @p_ip_address--@p_mod_ip_address;
		

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


