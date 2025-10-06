
CREATE PROCEDURE dbo.xsp_sys_company_update
(
	@p_code						nvarchar(50)
	,@p_name					nvarchar(100)
	,@p_address					nvarchar(4000)
	,@p_phone_no				nvarchar(25)
	,@p_fax_no					nvarchar(25)
	,@p_npwp					nvarchar(50)
	,@p_email					nvarchar(50)
	,@p_province_code			nvarchar(50)
	,@p_city_code				nvarchar(50)
	,@p_contact_name			nvarchar(100)
	,@p_contact_phone			nvarchar(25)
	,@p_subscription_type_code	nvarchar(50)
	,@p_subscription_start_date datetime
	--,@p_subscription_end_date	datetime
	,@p_max_user				int
	,@p_is_reminder_by_email	nvarchar(1)
	,@p_reminder_email			nvarchar(50)
	,@p_is_reminder_by_sms		nvarchar(1)
	,@p_reminder_sms			nvarchar(25)
	,@p_is_reminder_by_whatsapp nvarchar(1)
	,@p_reminder_whatsapp		nvarchar(25)
	,@p_is_reminder_by_telegram nvarchar(1)
	,@p_reminder_telegram		nvarchar(25)
	,@p_remark					nvarchar(4000)
	,@p_is_active				nvarchar(1)
	,@p_is_renual				nvarchar(1)
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max) 
			,@subscription_end_date	datetime
			,@number_of_days		int
			,@company_user_code		nvarchar(50)
			,@email_old				nvarchar(50) ;

	if @p_is_reminder_by_email = 'T'
		set @p_is_reminder_by_email = '1' ;
	else
		set @p_is_reminder_by_email = '0' ;

	if @p_is_reminder_by_sms = 'T'
		set @p_is_reminder_by_sms = '1' ;
	else
		set @p_is_reminder_by_sms = '0' ;

	if @p_is_reminder_by_whatsapp = 'T'
		set @p_is_reminder_by_whatsapp = '1' ;
	else
		set @p_is_reminder_by_whatsapp = '0' ;

	if @p_is_reminder_by_telegram = 'T'
		set @p_is_reminder_by_telegram = '1' ;
	else
		set @p_is_reminder_by_telegram = '0' ;

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	if @p_is_renual = 'T'
		set @p_is_renual = '1' ;
	else
		set @p_is_renual = '0' ;

	begin try

		select  @number_of_days = number_of_days
		from	dbo.sys_subscription_type 
		where	code = @p_subscription_type_code;

		set @subscription_end_date = dateadd(dd,@number_of_days,cast(@p_subscription_start_date as date));
		
		if exists (select 1 from dbo.sys_company where email = @p_email and code <> @p_code)
		begin
			set @msg = 'Email already exist';
			raiserror(@msg, 16, -1) ;
		end
		
		if exists (select 1 from dbo.sys_company where reminder_email = @p_reminder_email  and reminder_email != '' and code <> @p_code)
		begin
			set @msg = 'Email for reminder already exist';
			raiserror(@msg, 16, -1) ;
		end
		
		if exists (select 1 from dbo.sys_company where reminder_sms = @p_reminder_sms and reminder_sms != '' and code <> @p_code)
		begin
			set @msg = 'SMS No. for reminder already exist';
			raiserror(@msg, 16, -1) ;
		end
		
		if exists (select 1 from dbo.sys_company where reminder_telegram = @p_reminder_telegram and reminder_telegram != '' and code <> @p_code)
		begin
			set @msg = 'Telegram No. for reminder already exist';
			raiserror(@msg, 16, -1) ;
		end
		
		if exists (select 1 from dbo.sys_company where reminder_whatsapp = @p_reminder_whatsapp and reminder_whatsapp != '' and code <> @p_code)
		begin
			set @msg = 'Whatsapp No. for reminder already exist';
			raiserror(@msg, 16, -1) ;
		end

		update	sys_company
		set		name						= @p_name
				,address					= @p_address
				,phone_no					= @p_phone_no
				,fax_no						= @p_fax_no
				,npwp						= @p_npwp
				,email						= @p_email
				,province_code				= @p_province_code
				,city_code					= @p_city_code
				,contact_name				= @p_contact_name
				,contact_phone				= @p_contact_phone
				,subscription_type_code		= @p_subscription_type_code
				,subscription_start_date	= @p_subscription_start_date
				,subscription_end_date		= @subscription_end_date
				,max_user					= @p_max_user
				,is_reminder_by_email		= @p_is_reminder_by_email
				,reminder_email				= @p_reminder_email
				,is_reminder_by_sms			= @p_is_reminder_by_sms
				,reminder_sms				= @p_reminder_sms
				,is_reminder_by_whatsapp	= @p_is_reminder_by_whatsapp
				,reminder_whatsapp			= @p_reminder_whatsapp
				,is_reminder_by_telegram	= @p_is_reminder_by_telegram
				,reminder_telegram			= @p_reminder_telegram
				,remark						= @p_remark
				,is_active					= @p_is_active
				,is_renual					= @p_is_renual
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	code = @p_code ;

		update	dbo.sys_company_user_main
		set		email			= @p_email
				,phone_no		= @p_phone_no
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address	= @p_mod_ip_address
		where	company_code	= @p_code;

		select	@company_user_code = code
		from	dbo.sys_company_user_main
		where	company_code = @p_code;

		update	icas.dbo.sys_company_user_main
		set		email			= @p_email
				,phone_no		= @p_phone_no
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address	= @p_mod_ip_address
		where	company_code	= @p_code
		and		code			= @company_user_code;

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
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
