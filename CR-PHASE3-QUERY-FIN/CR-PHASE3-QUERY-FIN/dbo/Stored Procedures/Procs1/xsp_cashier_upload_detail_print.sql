CREATE procedure dbo.xsp_cashier_upload_detail_print
	@p_cashier_upload_code nvarchar(50)
as
begin
	select	reff_loan_no 'loan_no'
			,total_installment_amount
			,total_obligation_amount
	from	dbo.cashier_upload_detail
	where	cashier_upload_code = @p_cashier_upload_code ;
end ;
