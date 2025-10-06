CREATE PROCEDURE dbo.xsp_master_task_user_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,company_code
			,description
			,is_active
	from	master_task_user
	where	code = @p_code ;
end ;
