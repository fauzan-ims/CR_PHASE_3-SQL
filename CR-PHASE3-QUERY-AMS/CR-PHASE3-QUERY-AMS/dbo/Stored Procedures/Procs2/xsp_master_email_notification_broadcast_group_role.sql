CREATE PROCEDURE dbo.xsp_master_email_notification_broadcast_group_role
(
	@p_field				nvarchar(100)
	,@p_doc_code			nvarchar(100)
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
	
	declare @sql				nvarchar(2000)
			,@param				nvarchar(2000)
			,@value				nvarchar(10)
			,@table				nvarchar(100)
			,@email_subject		nvarchar(100)
			,@email_body		nvarchar(4000)
			,@reply_to			nvarchar(100)
			,@user_email		nvarchar(100)
			,@field_lookup		nvarchar(100)
			,@table_name		nvarchar(4000)
			,@field_name		nvarchar(100)
			,@query_script		nvarchar(4000) = ''
			,@emp_code			nvarchar(50)
			,@regional_center	nvarchar(50)
			,@area_office		nvarchar(50)
			,@griya				nvarchar(50)
			,@condition_script	nvarchar(4000)
			,@flag				int
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
			
	select	@email_subject	= email_subject
			,@email_body	= email_body	
			,@reply_to		= ''
			,@mail_subject	= email_subject
			,@mail_body		= email_body	
	from	eprocbase.dbo.master_email_reminder_notification
	where	email_notification_type	= @p_code
	and		company_code = @p_company_code
	and		is_active = '1'
	
	select	@mail_sender = value
	from	eprocbase.dbo.sys_global_param
	where	company_code = @p_company_code
	and		code = 'MSD'
	
	if isnull(@reply_to,'') <> ''
		set @reply_to = '' + @reply_to + ''
	else 
		set @reply_to = 'null'
	
	set @mail_body = @email_body
	
	if @p_attachment_flag = 1
	begin
	    select	@mail_file_name = @p_attachment_file
				,@mail_file_path = @p_attachment_path
				,@generate_status = 'PENDING'
	end
		
	if @p_code in ('APRQTR','PSRQTR','RJRQTR','RTRQTR','MUTATN')	-- transaction process
		set @mail_subject += ' ' + @p_trx_type + ' FOR ' + @p_trx_no
		
	declare c_mail cursor fast_forward read_only for
	select	sem.code, isnull(sem.email,email2)
	from	eprocbase.dbo.sys_employee_main sem
			inner join eprocbase.dbo.sys_company_user_main scum on scum.code = sem.code
			left join eprocbase.dbo.sys_company_user_main_group_sec sumgc on scum.code = sumgc.user_code
	where	sumgc.role_group_code = @p_field
	    								
	open c_mail
	fetch next from c_mail
	into @emp_code, @user_email
	    							
	while @@fetch_status = 0
	begin
	    		
		set	@mail_to = @user_email
	    	
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


	    								
	    fetch next from c_mail
	    into @emp_code, @user_email
	    							
	end
	    							
	close c_mail
	deallocate c_mail 
	
end
