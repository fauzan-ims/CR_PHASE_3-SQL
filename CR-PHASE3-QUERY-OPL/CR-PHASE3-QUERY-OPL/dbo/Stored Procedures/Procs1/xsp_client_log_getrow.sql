
CREATE procedure [dbo].[xsp_client_log_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,client_code
			,log_date
			,log_remarks
	from	client_log
	where	id = @p_id ;
end ;

