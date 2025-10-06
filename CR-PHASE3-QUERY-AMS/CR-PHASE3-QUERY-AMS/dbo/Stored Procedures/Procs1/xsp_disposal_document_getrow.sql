CREATE PROCEDURE dbo.xsp_disposal_document_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,disposal_code
			,file_name
			,path
			,description
	from	disposal_document
	where	id = @p_id ;
end ;
