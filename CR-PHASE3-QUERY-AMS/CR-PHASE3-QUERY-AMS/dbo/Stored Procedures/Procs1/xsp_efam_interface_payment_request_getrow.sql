CREATE PROCEDURE dbo.xsp_efam_interface_payment_request_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	id
			,code
			,company_code
			,branch_code
			,branch_name
			,payment_branch_code
			,payment_branch_name
			,payment_source
			,payment_request_date
			,payment_source_no
			,payment_status
			,payment_currency_code
			,payment_amount
			,payment_remarks
			,to_bank_account_name
			,to_bank_name
			,to_bank_account_no
			,tax_type
			,tax_file_no
			,tax_payer_reff_code
			,tax_file_name
			,process_date
			,process_reff_no
			,process_reff_name
			,settle_date
			,job_status
			,failed_remarks
			,mod_date
	from	efam_interface_payment_request
	where	code = @p_code ;
end ;
