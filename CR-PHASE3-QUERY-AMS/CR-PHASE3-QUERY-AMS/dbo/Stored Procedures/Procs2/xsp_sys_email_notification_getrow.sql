/*
	Created : Yunus Muslim, 21 Desember 2018
*/
CREATE PROCEDURE dbo.xsp_sys_email_notification_getrow
(
	@p_code			nvarchar(50)
) as
begin

	select	*
	from	sys_email_notification
	where	code	= @p_code
end
