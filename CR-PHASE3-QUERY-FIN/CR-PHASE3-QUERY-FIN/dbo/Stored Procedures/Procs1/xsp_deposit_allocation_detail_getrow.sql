
CREATE procedure xsp_deposit_allocation_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,deposit_allocation_code
			,transaction_code
			,received_request_code
			,is_paid
			,orig_amount
			,orig_currency_code
			,exch_rate
			,base_amount
			,installment_no
			,remarks
	from	deposit_allocation_detail
	where	id = @p_id ;
end ;
