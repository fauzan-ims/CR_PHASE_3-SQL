CREATE procedure dbo.xsp_fin_interface_agreement_retention_history_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,branch_code
			,branch_name
			,agreement_no
			,transaction_date
			,orig_amount
			,orig_currency_code
			,exch_rate
			,base_amount
			,source_reff_code
			,source_reff_name
	from	fin_interface_agreement_retention_history
	where	id = @p_id ;
end ;
