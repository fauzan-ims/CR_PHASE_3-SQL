
-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_daily_overdue_getrow]
(@p_user_id nvarchar(50))
as
begin
	select	convert(varchar, max(as_of_date), 0)
			--,max(is_disable) 'is_disable'
	--SELECT max(cre_date)
	from	dbo.RPT_DAILY_OVERDUE
			--join dbo.RPT_DAILY_OVERDUE_BUTTON_DISABLE on RPT_DAILY_OVERDUE_BUTTON_DISABLE.user_id = RPT_DAILY_OVERDUE.USER_ID
	--where RPT_DAILY_OVERDUE.USER_ID = @p_user_id 
end ;
