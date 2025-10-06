CREATE PROCEDURE [dbo].[xsp_application_asset_doc_upload_file_update]
(
	@p_id			bigint
	,@p_file_name	nvarchar(250)
	,@p_file_paths	nvarchar(250)
)
as
begin
	update	application_asset_doc
	set		filename		= upper(@p_file_name)
			,paths			= upper(@p_file_paths)
	where	id				= @p_id;
end ;

