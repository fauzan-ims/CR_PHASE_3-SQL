
CREATE procedure [dbo].[xsp_application_log_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,application_no
			,log_date
			,log_description
	from	application_log
	where	id = @p_id ;
end ;

