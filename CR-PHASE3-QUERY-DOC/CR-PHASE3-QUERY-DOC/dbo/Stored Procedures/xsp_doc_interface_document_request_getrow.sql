create procedure xsp_doc_interface_document_request_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,request_branch_code
			,request_branch_name
			,request_type
			,request_location
			,request_from
			,request_to
			,request_by
			,request_status
			,request_date
			,remarks
			,process_date
			,process_reff_no
			,process_reff_name
	from	doc_interface_document_request
	where	code = @p_code ;
end ;
