CREATE procedure [dbo].[xsp_email_notif_transaction_getrow]
(
	@p_id	bigint
) as
begin

	select	id
			,mail_sender
			,mail_to
			,mail_cc
			,mail_bcc
			,mail_subject
			,mail_body
			,mail_file_name
			,mail_file_path
			,generate_file_status
			,mail_status
			,mail_file_path + mail_file_name 'mail_attachment'
	from	email_notif_transaction
	where id = @p_id
	end
