
create procedure xsp_ams_interface_document_request_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,code
			,request_branch_code
			,request_branch_name
			,request_type
			,request_location
			,request_from
			,request_to
			,request_to_branch_code
			,request_to_branch_name
			,request_to_agreement_no
			,request_to_client_name
			,request_from_dept_code
			,request_from_dept_name
			,request_to_dept_code
			,request_to_dept_name
			,request_to_thirdparty_type
			,agreement_no
			,collateral_no
			,asset_no
			,request_by
			,request_status
			,request_date
			,remarks
			,document_code
			,process_date
			,process_reff_no
			,process_reff_name
			,job_status
			,failed_remark
	from	ams_interface_document_request
	where	id = @p_id ;
end ;
