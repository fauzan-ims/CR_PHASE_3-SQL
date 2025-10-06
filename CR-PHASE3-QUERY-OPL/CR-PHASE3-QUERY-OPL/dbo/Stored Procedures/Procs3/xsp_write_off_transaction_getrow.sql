
CREATE procedure [dbo].[xsp_write_off_transaction_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,wo_code 
			,transaction_amount
			,is_transaction
			,order_key
	from	write_off_transaction
	where	id = @p_id ;
end ;

