CREATE procedure dbo.xsp_send_email
(
	@p_email		nvarchar(200) 
	,@p_cc			nvarchar(100) = null
	,@p_bcc			nvarchar(100) = null
	,@p_body		nvarchar(4000)
	,@p_subject		nvarchar(200)
	,@p_file_name	nvarchar(100) = null
) as
begin

	declare	@email_profile		nvarchar(50)
			
	select	@email_profile		= db_mail_profile
	from	sys_it_param 
	
	if len(@p_cc) < 1
		set @p_cc = null

	if len(@p_bcc) < 1
		set @p_bcc = null

	
	exec	msdb.dbo.sp_send_dbmail 
			@profile_name			= @email_profile
			,@recipients			= @p_email
			,@copy_recipients		= @p_cc
			,@blind_copy_recipients	= @p_bcc
			,@body					= @p_body
			,@subject				= @p_subject
			,@body_format			= 'HTML'
			,@file_attachments		= @p_file_name
end




