
create procedure xsp_asset_document_history_getrow
(
	@p_id			bigint
) as
begin

	select	id
			,asset_code
			,document_code
			,document_no
			,description
			,file_name
			,path
	from	asset_document_history
	where	id	= @p_id
end
