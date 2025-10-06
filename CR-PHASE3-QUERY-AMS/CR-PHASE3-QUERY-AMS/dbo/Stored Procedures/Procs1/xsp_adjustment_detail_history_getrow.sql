
create procedure xsp_adjustment_detail_history_getrow
(
	@p_id			bigint
) as
begin

	select	id
			,adjustment_code
			,adjusment_transaction_code
			,amount
			,currency_code
	from	adjustment_detail_history
	where	id	= @p_id
end
