
-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_daily_overdue_button_disable_getrow]
(@p_user_id NVARCHAR(50))
AS
BEGIN
    SELECT is_disable
    --SELECT max(cre_date)
    FROM dbo.RPT_DAILY_OVERDUE_BUTTON_DISABLE
    --WHERE user_id = @p_user_id;
END;
