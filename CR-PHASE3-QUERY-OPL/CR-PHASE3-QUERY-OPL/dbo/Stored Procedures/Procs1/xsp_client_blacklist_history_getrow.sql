
CREATE procedure [dbo].[xsp_client_blacklist_history_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,client_blacklist_code
			,history_date
			,history_remarks
	from	client_blacklist_history
	where	id = @p_id ;
end ;

