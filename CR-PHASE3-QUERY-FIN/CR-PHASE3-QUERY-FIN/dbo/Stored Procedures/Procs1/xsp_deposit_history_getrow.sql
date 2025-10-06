
CREATE procedure xsp_deposit_history_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,branch_code
			,branch_name
			,deposit_code
			,transaction_date
			,orig_amount
			,orig_currency_code
			,exch_rate
			,base_amount
			,source_reff_code
			,source_reff_name
	from	deposit_history
	where	id = @p_id ;
end ;
