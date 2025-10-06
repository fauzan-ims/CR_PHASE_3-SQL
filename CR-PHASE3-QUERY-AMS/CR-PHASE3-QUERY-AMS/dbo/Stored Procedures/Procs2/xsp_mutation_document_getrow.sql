CREATE procedure dbo.xsp_mutation_document_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,mutation_code
			,file_name
			,path
			,description
	from	mutation_document
	where	id = @p_id ;
end ;
