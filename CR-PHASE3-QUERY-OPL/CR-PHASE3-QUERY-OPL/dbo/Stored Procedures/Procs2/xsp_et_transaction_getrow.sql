
CREATE PROCEDURE dbo.xsp_et_transaction_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,et_code
			,transaction_code
			,transaction_amount
			,disc_pct
			,disc_amount
			,total_amount
			,order_key
			,is_amount_editable
			,is_discount_editable
			,is_transaction
	from	et_transaction
	where	id = @p_id ;
end ;
