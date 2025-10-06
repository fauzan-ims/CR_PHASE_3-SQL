CREATE PROCEDURE dbo.xsp_handover_asset_doc_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,handover_code
			,document_code
			,file_name
			,file_path
	from	handover_asset_doc
	where	id = @p_id ;
end ;
