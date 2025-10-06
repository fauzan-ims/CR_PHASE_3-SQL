CREATE procedure dbo.xsp_sale_document_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,sale_code
			,file_name
			,path
			,description
	from	sale_document
	where	id = @p_id ;
end ;
