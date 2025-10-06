
CREATE procedure xsp_adjustment_document_history_getrow
(
	@p_id			bigint
) as
begin

	select	id
			,adjustment_code
			,file_name
			,path
			,description
	from	adjustment_document_history
	where	id	= @p_id
end
