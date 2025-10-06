
CREATE PROCEDURE [dbo].[xsp_master_workflow_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,description
			,screen_name
			,sp_check_name
			,is_active
	from	master_workflow
	where	code = @p_code ;
end ;
