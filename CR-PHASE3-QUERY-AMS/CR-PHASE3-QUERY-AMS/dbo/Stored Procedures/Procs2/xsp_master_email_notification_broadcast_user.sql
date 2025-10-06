CREATE PROCEDURE dbo.xsp_master_email_notification_broadcast_user
(
	@p_user_id				nvarchar(50)
	,@p_email_profile		nvarchar(100)
	,@p_code				nvarchar(15)
	,@p_attachment_flag		int = 0
	,@p_attachment_file		nvarchar(4000) = ''
	,@p_attachment_path		nvarchar(4000) = ''
	,@p_company_code		nvarchar(50)
	,@p_trx_no				nvarchar(50)
	,@p_trx_type			nvarchar(50)
) as
begin

	
	declare	@user_email			nvarchar(100)
			,@email_subject		nvarchar(100)
			,@email_body		nvarchar(4000)
			,@reply_to			nvarchar(100)
			,@msg				nvarchar(max)
			--
			,@mail_sender			nvarchar(200)
			,@mail_to				nvarchar(200)
			,@mail_cc				nvarchar(100)	= ''
			,@mail_bcc				nvarchar(100)	= ''
			,@mail_subject			nvarchar(200)
			,@mail_body				nvarchar(4000)
			,@mail_file_name		nvarchar(100)	= '-'
			,@mail_file_path		nvarchar(100)	= '-'
			,@generate_status		nvarchar(50)	= 'NONE'
			,@mail_status			nvarchar(50)	= 'PENDING'
			,@cre_date				datetime		= getdate()
			,@cre_by				nvarchar(15)	= 'SYSTEM'
			,@cre_ip_address		nvarchar(15)	= '127.0.0.1'
			,@approval_no			nvarchar(50)	= ''
	begin try
	
	select	@user_email = isnull(email,email2)
			,@mail_to = isnull(email,email2)
	from	ifinbam.dbo.sys_employee_main
	where	code = @p_user_id
	
	select	@email_subject	= email_subject
			,@email_body	= email_body	
			,@reply_to		= ''
			,@mail_subject	= email_subject
			,@mail_body		= email_body	
	from	ifinbam.dbo.master_email_reminder_notification
	where	email_notification_type	= @p_code
	and		company_code = @p_company_code
	and		is_active = '1'
	
	select	@mail_sender = value
	from	ifinbam.dbo.sys_global_param
	where	company_code = @p_company_code
	and		code = 'MSD'
	
	if @p_attachment_flag = 1
	begin
	    select	@mail_file_name = @p_attachment_file
				,@mail_file_path = @p_attachment_path
				,@generate_status = 'PENDING'
	end
		
	if @p_code in ('APRQTR','PSRQTR','RJRQTR','RTRQTR','MUTATN')	-- transaction process
		set @mail_subject += ' ' + @p_trx_type + ' FOR ' + @p_trx_no
		
	exec dbo.xsp_email_notif_transaction_insert @p_mail_sender			 = @mail_sender
												,@p_mail_to				 = @mail_to
												,@p_mail_cc				 = @mail_cc
												,@p_mail_bcc			 = @mail_bcc
												,@p_mail_subject		 = @mail_subject
												,@p_mail_body			 = @mail_body
												,@p_mail_file_name		 = @mail_file_name
	                                            ,@p_mail_file_path		 = @mail_file_path
	                                            ,@p_generate_file_status = @generate_status
												,@p_mail_status			 = @mail_status
												,@p_cre_date			 = @cre_date
												,@p_cre_by				 = @cre_by
												,@p_cre_ip_address		 = @cre_ip_address
												,@p_mod_date			 = @cre_date
												,@p_mod_by				 = @cre_by
												,@p_mod_ip_address		 = @cre_ip_address
												,@p_approval_no			 = @approval_no
	

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
end
