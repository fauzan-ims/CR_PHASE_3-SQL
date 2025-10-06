CREATE PROCEDURE dbo.xsp_bank_mutation_history_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,bank_mutation_code
			,transaction_date
			,source_reff_code
			,source_reff_name
			,orig_amount
			,orig_currency_code
			,exch_rate
			,base_amount
			,remarks
	from	bank_mutation_history
	where	id = @p_id ;
end ;
