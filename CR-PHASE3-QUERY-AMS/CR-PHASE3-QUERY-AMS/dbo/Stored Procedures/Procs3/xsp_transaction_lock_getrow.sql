CREATE PROCEDURE [dbo].[xsp_transaction_lock_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,user_id
			,user_name
			,reff_code
			,reff_name
			,access_date
			,is_active
	from	transaction_lock
	where	id = @p_id ;
end ;
