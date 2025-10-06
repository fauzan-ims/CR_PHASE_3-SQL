CREATE procedure dbo.xsp_efam_interface_asset_document_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,asset_code
			,description
			,file_name
			,path
	from	efam_interface_asset_document
	where	id = @p_id ;
end ;
