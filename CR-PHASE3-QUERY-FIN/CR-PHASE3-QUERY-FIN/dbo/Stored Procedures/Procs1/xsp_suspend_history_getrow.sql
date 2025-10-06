
CREATE procedure xsp_suspend_history_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,branch_code
			,branch_name
			,suspend_code
			,transaction_date
			,orig_amount
			,orig_currency_code
			,exch_rate
			,base_amount
			,agreement_no
			,source_reff_code
			,source_reff_name
	from	suspend_history
	where	id = @p_id ;
end ;
