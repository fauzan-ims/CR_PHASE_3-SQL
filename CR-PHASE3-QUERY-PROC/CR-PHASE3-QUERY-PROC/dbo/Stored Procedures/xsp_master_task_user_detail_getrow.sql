CREATE PROCEDURE dbo.xsp_master_task_user_detail_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,main_task_user_code
			,role_group_code
	from	master_task_user_detail
	where	code = @p_code ;
end ;
