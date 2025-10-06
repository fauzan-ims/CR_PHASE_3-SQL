
-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_daily_overdue_update_disable]
(@p_user_id nvarchar(50))
as
BEGIN
	declare @msg			nvarchar(max)
	IF EXISTS (SELECT 1 FROM RPT_DAILY_OVERDUE_BUTTON_DISABLE WHERE is_disable = '1')
	BEGIN
	    	set @msg = 'Generate already proceed';
			raiserror(@msg, 16, 1) ; 
	END
	insert into RPT_DAILY_OVERDUE_BUTTON_DISABLE
	select	CODE
			,''
	from	IFINSYS.dbo.SYS_EMPLOYEE_MAIN
	where CODE not in
			(
				select user_id from		RPT_DAILY_OVERDUE_BUTTON_DISABLE
			) ;
	update	RPT_DAILY_OVERDUE_BUTTON_DISABLE
	set is_disable = '1'
	--where user_id = @p_user_id ;
end ;
