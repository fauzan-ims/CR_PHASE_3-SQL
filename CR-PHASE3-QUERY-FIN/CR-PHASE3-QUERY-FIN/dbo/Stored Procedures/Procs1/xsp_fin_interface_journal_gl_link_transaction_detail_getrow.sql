CREATE PROCEDURE dbo.xsp_fin_interface_journal_gl_link_transaction_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,gl_link_transaction_code
			,branch_code
			,branch_name
			,gl_link_code
			,contra_gl_link_code
			,agreement_no
			,orig_currency_code
			,orig_amount_db
			,orig_amount_cr
			,exch_rate
			,base_amount_db
			,base_amount_cr
			,remarks
			,division_code
			,division_name
			,department_code
			,department_name
	from	fin_interface_journal_gl_link_transaction_detail
	where	id = @p_id ;
end ;
