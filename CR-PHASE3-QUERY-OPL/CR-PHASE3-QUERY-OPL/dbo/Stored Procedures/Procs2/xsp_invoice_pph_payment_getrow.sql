CREATE PROCEDURE dbo.xsp_invoice_pph_payment_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,branch_code
			,branch_name
			,status
			,date
			,remark
			,total_pph_amount
			,process_date
			,process_reff_no
			,process_reff_name
			,currency_code
			,tax_bank_name
			,tax_bank_account_name
			,tax_bank_account_no
	from	invoice_pph_payment
	where	code = @p_code ;
end ;
