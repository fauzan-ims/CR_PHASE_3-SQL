
create procedure xsp_xxxxjournal_gl_link_transaction_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,branch_code
			,branch_name
			,transaction_status
			,transaction_date
			,transaction_value_date
			,transaction_code
			,transaction_name
			,reff_module_code
			,reff_source_no
			,reff_source_name
			,gl_link_code
			,contra_gl_link_code
			,agreement_no
			,orig_currency_code
			,orig_amount_db
			,orig_amount_cr
			,exch_rate
			,base_amount_db
			,base_amount_cr
			,division_code
			,division_name
			,department_code
			,department_name
	from	xxxxjournal_gl_link_transaction
	where	id = @p_id ;
end ;
