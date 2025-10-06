/*
	Created : Yunus Muslim, 21 Desember 2018
*/
CREATE PROCEDURE [dbo].[xsp_sys_email_notification_getrows]
(	
	@p_keywords				nvarchar(50)
)as
begin

	select	code
			,email_subject
			,email_body
			,reply_to
	from	sys_email_notification
	where	(		
					code					like 	'%' + @p_keywords + '%'
				or	email_subject			like 	'%' + @p_keywords + '%'
				or	email_body				like 	'%' + @p_keywords + '%'
				or	reply_to				like 	'%' + @p_keywords + '%'
			)							

end