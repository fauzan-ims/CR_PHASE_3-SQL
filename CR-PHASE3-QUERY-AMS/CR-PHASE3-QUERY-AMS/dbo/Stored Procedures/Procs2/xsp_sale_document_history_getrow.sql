
create procedure xsp_sale_document_history_getrow
(
	@p_id			bigint
) as
begin

	select	id
			,sale_code
			,file_name
			,path
			,description
	from	sale_document_history
	where	id	= @p_id
end
