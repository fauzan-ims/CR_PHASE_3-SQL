
create procedure [dbo].[xsp_transaction_lock_history_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,user_id
			,user_name
			,reff_name
			,reff_code
			,access_date
			,is_active
	from	transaction_lock_history
	where	id = @p_id ;
end ;
