
create procedure xsp_cashier_transaction_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,cashier_transaction_code
			,transaction_code
			,received_request_code
			,is_paid
			,orig_amount
			,orig_currency_code
			,exch_rate
			,base_amount
			,installment_no
			,remarks
	from	cashier_transaction_detail
	where	id = @p_id ;
end ;
