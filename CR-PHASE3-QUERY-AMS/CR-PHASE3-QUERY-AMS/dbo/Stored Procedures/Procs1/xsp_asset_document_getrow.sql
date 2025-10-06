CREATE PROCEDURE dbo.xsp_asset_document_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,asset_code
			,document_code
			,document_no
			,description
			,file_name
			,path
	from	asset_document
	where	ID = @p_id ;
end ;
