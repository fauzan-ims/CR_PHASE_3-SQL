
create procedure xsp_cashier_receipt_allocated_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,cashier_code
			,receipt_code
			,receipt_status
			,receipt_use_date
			,receipt_use_trx_code
	from	cashier_receipt_allocated
	where	id = @p_id ;
end ;
