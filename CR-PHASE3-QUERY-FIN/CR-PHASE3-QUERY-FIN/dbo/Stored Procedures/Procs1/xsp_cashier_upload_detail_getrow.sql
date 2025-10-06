
create procedure xsp_cashier_upload_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,cashier_upload_code
			,reff_loan_no
			,agreement_no
			,client_name
			,total_installment_amount
			,total_obligation_amount
	from	cashier_upload_detail
	where	id = @p_id ;
end ;
