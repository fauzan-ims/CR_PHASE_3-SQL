CREATE PROCEDURE dbo.xsp_reverse_disposal_document_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,reverse_disposal_code
			,file_name
			,path
			,description
	from	reverse_disposal_document
	where	id = @p_id ;
end ;
