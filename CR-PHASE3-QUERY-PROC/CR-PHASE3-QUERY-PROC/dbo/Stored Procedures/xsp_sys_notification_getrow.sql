/*
	Created : Yunus Muslim, 19 Desember 2018
*/
CREATE procedure dbo.xsp_sys_notification_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,description
			,is_active
	from	sys_notification
	where	code = @p_code ;
end ;
