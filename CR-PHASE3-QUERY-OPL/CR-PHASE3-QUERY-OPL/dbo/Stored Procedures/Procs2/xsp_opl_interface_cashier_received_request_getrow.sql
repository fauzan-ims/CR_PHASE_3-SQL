create PROCEDURE dbo.xsp_opl_interface_cashier_received_request_getrow
(
	@p_code	nvarchar(50)
)
as
begin
	select	id
			,code
			,crr.branch_code
			,crr.branch_name
			,request_status
			,request_currency_code
			,request_date
			,request_amount
			,request_remarks
			,crr.agreement_no
			,am.agreement_external_no
			,am.client_name
			,pdc_code
			,pdc_no
			,doc_reff_code
			,doc_reff_name
			,process_date
			,process_reff_no
			,process_reff_name
			,job_status
			,failed_remarks
	from	opl_interface_cashier_received_request crr
			left join dbo.agreement_main am on (am.agreement_no = crr.agreement_no)
	where	code = @p_code ;
end ;
