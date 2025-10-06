create procedure xsp_document_request_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,branch_code
			,branch_name
			,request_type
			,request_location
			,request_from
			,request_to
			,request_by
			,request_status
			,request_date
			,remarks
	from	document_request
	where	code = @p_code ;
end ;
