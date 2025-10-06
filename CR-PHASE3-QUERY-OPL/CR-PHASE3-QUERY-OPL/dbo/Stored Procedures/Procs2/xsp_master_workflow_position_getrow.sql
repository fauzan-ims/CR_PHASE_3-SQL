
create PROCEDURE [dbo].[xsp_master_workflow_position_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,workflow_code
			,position_code
			,position_name
	from	master_workflow_position
	where	id = @p_id ;
end ;
