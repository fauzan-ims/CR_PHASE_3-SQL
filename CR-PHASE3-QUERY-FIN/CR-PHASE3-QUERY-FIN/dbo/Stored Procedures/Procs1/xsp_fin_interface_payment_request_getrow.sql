CREATE PROCEDURE dbo.xsp_fin_interface_payment_request_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	id
			,code
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
			,process_date
			,process_reff_no
			,process_reff_name
			,manual_upload_status
			,manual_upload_remarks
			,job_status
			,failed_remarks
	from	fin_interface_payment_request
	where	code = @p_code ;
end ;
