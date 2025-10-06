
create procedure xsp_reconcile_transaction_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,reconcile_code
			,transaction_source
			,transaction_no
			,transaction_reff_no
			,transaction_value_date
			,transaction_amount
			,is_system
			,is_reconcile
	from	reconcile_transaction
	where	id = @p_id ;
end ;
