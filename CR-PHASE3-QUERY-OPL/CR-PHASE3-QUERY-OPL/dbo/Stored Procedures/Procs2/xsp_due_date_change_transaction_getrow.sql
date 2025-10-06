CREATE PROCEDURE dbo.xsp_due_date_change_transaction_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,due_date_change_code
			--,gl_link_code
			,transaction_amount
			,order_key
			,is_transaction
	from	due_date_change_transaction
	where	id = @p_id ;
end ;
