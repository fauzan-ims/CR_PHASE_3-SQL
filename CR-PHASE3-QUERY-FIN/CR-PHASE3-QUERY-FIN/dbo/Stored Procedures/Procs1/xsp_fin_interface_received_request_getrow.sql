CREATE PROCEDURE dbo.xsp_fin_interface_received_request_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	id
		   ,code
		   ,branch_code
		   ,branch_name
		   ,received_source
		   ,received_request_date
		   ,received_source_no
		   ,received_status
		   ,received_currency_code
		   ,received_amount
		   ,received_remarks
		   ,process_date
		   ,process_reff_no
		   ,process_reff_name
		   ,manual_upload_status
		   ,manual_upload_remarks
		   ,job_status
		   ,failed_remarks
	from	dbo.fin_interface_received_request
	where	code = @p_code ;
end ;
