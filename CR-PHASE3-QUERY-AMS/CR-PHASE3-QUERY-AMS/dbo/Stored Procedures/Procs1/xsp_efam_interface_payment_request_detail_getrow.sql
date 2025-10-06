
CREATE procedure xsp_efam_interface_payment_request_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,payment_request_code
			,company_code
			,branch_code
			,branch_name
			,gl_link_code
			,agreement_no
			,facility_code
			,facility_name
			,purpose_loan_code
			,purpose_loan_name
			,purpose_loan_detail_code
			,purpose_loan_detail_name
			,orig_currency_code
			,orig_amount
			,division_code
			,division_name
			,department_code
			,department_name
			,remarks
	from	efam_interface_payment_request_detail
	where	id = @p_id ;
end ;
