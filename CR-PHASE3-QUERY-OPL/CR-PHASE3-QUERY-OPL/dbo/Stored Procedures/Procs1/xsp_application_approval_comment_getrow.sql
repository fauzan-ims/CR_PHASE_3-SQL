
CREATE procedure [dbo].[xsp_application_approval_comment_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,application_no
			,last_status
			,level_status
			,remarks
	from	application_approval_comment
	where	id = @p_id ;
end ;

