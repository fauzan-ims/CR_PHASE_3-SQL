CREATE PROCEDURE dbo.xsp_application_main_return_notification
(
	@p_application_no  nvarchar(50)
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@id					bigint
			,@email					nvarchar(250)
			,@area_phone_no			nvarchar(4)
			,@phone_no				nvarchar(15)
			,@staff_email			nvarchar(250)
			,@staff_phone_no		nvarchar(250)
			,@staff_area_phone_no	nvarchar(250)
			,@vendor_name			nvarchar(250)
			,@vendor_email			nvarchar(250)
			,@vendor_area_phone_no	nvarchar(4)
			,@vendor_phone_no		nvarchar(15)
			,@recipient_name		nvarchar(250)
			,@marketing_name		nvarchar(250)
			,@reference_no_1		nvarchar(50) = ''
			,@reference_no_2		nvarchar(50) = ''
			,@header_message		nvarchar(250)
			,@body_message_1		nvarchar(4000)
			,@body_message_2		nvarchar(4000)
			,@body_message_3		nvarchar(4000)
			,@reference_amount_1	decimal(18, 2)
			,@reference_amount_2	decimal(18, 2)
			,@company_name			nvarchar(250)
			,@company_address		nvarchar(4000)
			,@media_code			nvarchar(50)
			,@request_date			datetime = getdate()
			,@request_sent_date		datetime = getdate()
			,@facility_name			nvarchar(250)
			,@client_name			nvarchar(250) ;

	begin try
		select	@company_name = value
		from	dbo.sys_global_param
		where	code = 'COMP' ;

		select	@company_address = value
		from	dbo.sys_global_param
		where	code = 'COMPADD' ;

		select	@media_code = value
		from	dbo.sys_global_param
		where	code = 'NTFEMAIL' ;

		select	@email					= 'chaprir4@gmail.com' --isnull(cci.email, cpi.email)
				,@area_phone_no			= isnull(cci.area_fax_no, cpi.area_mobile_no)
				,@phone_no				= isnull(cci.fax_no, cpi.mobile_no)
				,@staff_email			= '' --sementara
				,@staff_area_phone_no	= ''
				,@staff_phone_no		= ''
				,@vendor_name			= ''
				,@vendor_email			= ''
				,@vendor_area_phone_no	= ''
				,@vendor_phone_no		= ''
				,@recipient_name		= isnull(am.client_name, isnull(cci.full_name, cpi.full_name))
				,@client_name			= isnull(am.client_name, isnull(cci.full_name, cpi.full_name))
				,@marketing_name		= am.marketing_name
				,@reference_no_1		= am.application_external_no
				,@reference_no_2		= am.branch_name
				,@body_message_1		= am.application_remarks
				,@body_message_2		= ''
				,@body_message_3		= cast(am.application_date as date)
				,@reference_amount_1	= am.rental_amount
				,@facility_name			= mf.description
		from	dbo.application_main am
				left join dbo.client_main cm on cm.code				   = am.client_code 
				left join dbo.client_corporate_info cci on cci.client_code = am.client_code
				left join dbo.client_personal_info cpi on cpi.client_code  = am.client_code
				inner join dbo.master_facility mf on mf.code			   = am.facility_code
		where	am.application_no = @p_application_no ;

		set @header_message = 'Application Return to Entry No. ' + @p_application_no + ' - ' + ' Facility ' + @facility_name ;

		exec dbo.xsp_opl_interface_notification_request_insert @p_id						 = @id output -- bigint
															   ,@p_code						 = @p_application_no -- nvarchar(50)
															   ,@p_request_status			 = N'NEW' -- nvarchar(250)
															   ,@p_request_date				 = @request_date		
															   ,@p_request_sent_date		 = @request_sent_date
															   ,@p_header_message			 = @header_message
															   ,@p_body_message_1			 = @body_message_1
															   ,@p_body_message_2			 = @body_message_2
															   ,@p_body_message_3			 = @body_message_3
															   ,@p_reference_amount_1		 = @reference_amount_1
															   ,@p_reference_amount_2		 = @reference_amount_2
															   ,@p_reference_no_1			 = @reference_no_1
															   ,@p_reference_no_2			 = @reference_no_2
															   ,@p_reference_name_1			 = @marketing_name
															   ,@p_reference_name_2			 = @client_name
															   ,@p_sender_company_name		 = @company_name
															   ,@p_sender_address			 = @company_address
															   ,@p_sender_position			 = N'' -- nvarchar(250)
															   ,@p_sender_name				 = N'' -- nvarchar(250)
															   ,@p_sender_department		 = N'' -- nvarchar(250)
															   ,@p_recipient_name			 = @recipient_name
															   ,@p_email					 = @email -- nvarchar(250)
															   ,@p_email_cc					 = N'' -- nvarchar(250)
															   ,@p_email_bcc				 = N'' -- nvarchar(250)
															   ,@p_area_phone_no			 = @area_phone_no
															   ,@p_phone_no					 = @phone_no
															   ,@p_third_party_email		 = @vendor_email -- nvarchar(250)
															   ,@p_third_party_email_cc		 = N'' -- nvarchar(250)
															   ,@p_third_party_email_bcc	 = N'' -- nvarchar(250)
															   ,@p_third_party_area_phone_no = @vendor_area_phone_no
															   ,@p_third_party_phone_no		 = @vendor_phone_no
															   ,@p_staff_email				 = @staff_email -- nvarchar(250)
															   ,@p_staff_email_cc			 = N'' -- nvarchar(250)
															   ,@p_staff_email_bcc			 = N'' -- nvarchar(250)
															   ,@p_staff_area_phone_no		 = @staff_area_phone_no
															   ,@p_staff_phone_no			 = @staff_phone_no
															   ,@p_media_code				 = @media_code				
															   ,@p_transaction_type_code	 = N'APP.BTE' -- nvarchar(50)
															   ,@p_module_code				 = N'IFINOPL' -- nvarchar(50)
															   ,@p_cre_date					 = @p_cre_date
															   ,@p_cre_by					 = @p_cre_by
															   ,@p_cre_ip_address			 = @p_cre_ip_address
															   ,@p_mod_date					 = @p_mod_date
															   ,@p_mod_by					 = @p_mod_by
															   ,@p_mod_ip_address			 = @p_mod_ip_address ;
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



