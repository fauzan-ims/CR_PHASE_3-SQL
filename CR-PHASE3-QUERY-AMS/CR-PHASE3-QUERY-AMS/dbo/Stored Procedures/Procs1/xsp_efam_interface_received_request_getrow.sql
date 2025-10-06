CREATE PROCEDURE dbo.xsp_efam_interface_received_request_getrow
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
			,settle_date
			,job_status
			,failed_remarks
			,mod_date
	from	efam_interface_received_request
	where	code = @p_code ;
end ;
