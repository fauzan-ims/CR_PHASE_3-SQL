create PROCEDURE dbo.xsp_ams_interface_cashier_received_request_getrow
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
			,crr.fa_code
			,pdc_code
			,pdc_no
			,doc_ref_code
			,doc_ref_name
			,process_date
			,process_reff_no
			,process_reff_name
			,job_status
			,failed_remarks
	from	ams_interface_cashier_received_request crr
	where	code = @p_code ;
end ;
