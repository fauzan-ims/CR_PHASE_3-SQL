
create procedure xsp_disposal_document_history_getrow
(
	@p_id			bigint
) as
begin

	select	id
			,disposal_code
			,file_name
			,path
			,description
	from	disposal_document_history
	where	id	= @p_id
end
