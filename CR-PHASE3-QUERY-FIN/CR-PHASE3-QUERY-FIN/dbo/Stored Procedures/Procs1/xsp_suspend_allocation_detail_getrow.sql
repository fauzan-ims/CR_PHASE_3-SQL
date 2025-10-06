CREATE procedure xsp_suspend_allocation_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,suspend_allocation_code
			,transaction_code
			,received_request_code
			,is_paid
			,innitial_amount
			,orig_amount
			,orig_currency_code
			,exch_rate
			,base_amount
			,installment_no
			,remarks
	from	suspend_allocation_detail
	where	id = @p_id ;
end ;
