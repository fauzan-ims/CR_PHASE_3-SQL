CREATE PROCEDURE dbo.xsp_procurement_request_document_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,procurement_request_code
			,file_path
			,file_name
			,remark
	from	procurement_request_document
	where	id = @p_id ;
end ;
