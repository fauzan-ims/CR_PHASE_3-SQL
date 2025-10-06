
create procedure xsp_mutation_document_history_getrow
(
	@p_id			bigint
) as
begin

	select	id
			,mutation_code
			,file_name
			,path
			,description
	from	mutation_document_history
	where	id	= @p_id
end
