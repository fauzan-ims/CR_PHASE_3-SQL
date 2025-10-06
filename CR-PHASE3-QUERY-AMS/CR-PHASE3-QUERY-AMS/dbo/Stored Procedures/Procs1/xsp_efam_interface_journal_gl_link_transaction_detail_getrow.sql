
CREATE PROCEDURE dbo.xsp_efam_interface_journal_gl_link_transaction_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,gl_link_transaction_code
			,company_code
			,branch_code
			,branch_name
			,cost_center_code
			,cost_center_name
			,gl_link_code
			,contra_gl_link_code
			,agreement_no
			,facility_code
			,facility_name
			,purpose_loan_code
			,purpose_loan_name
			,purpose_loan_detail_code
			,purpose_loan_detail_name
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
			,remarks
	from	efam_interface_journal_gl_link_transaction_detail
	where	id = @p_id ;
end ;
