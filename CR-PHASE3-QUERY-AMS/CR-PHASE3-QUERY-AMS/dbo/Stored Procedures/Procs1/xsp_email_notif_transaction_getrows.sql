
CREATE procedure [dbo].[xsp_email_notif_transaction_getrows]
(
	@p_keywords	nvarchar(50)
)
as
begin

	select	top 10
			id
			,mail_sender
			,mail_to
			,mail_cc
			,mail_bcc
			,mail_subject
			,mail_body
			,mail_file_name
			,mail_status
	from	email_notif_transaction
	where	mail_status in ('PENDING','PROCESS')
	and		(mail_sender	like 	'%'+@p_keywords+'%'
		or	mail_to			like 	'%'+@p_keywords+'%'
		or	mail_cc			like 	'%'+@p_keywords+'%'
		or	mail_bcc		like 	'%'+@p_keywords+'%'
		or	mail_subject	like 	'%'+@p_keywords+'%'
		or	mail_body		like 	'%'+@p_keywords+'%'
		or	mail_file_name	like 	'%'+@p_keywords+'%'
		or	mail_status		like 	'%'+@p_keywords+'%')
	order by cre_date asc

end
