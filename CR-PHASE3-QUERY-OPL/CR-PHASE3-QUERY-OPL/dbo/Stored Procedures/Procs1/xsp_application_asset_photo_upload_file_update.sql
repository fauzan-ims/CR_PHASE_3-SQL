CREATE procedure [dbo].[xsp_application_asset_photo_upload_file_update]
(
	@p_id			bigint
	,@p_file_name	nvarchar(250)
	,@p_file_paths	nvarchar(250)
)
as
begin
	update	application_asset_photo
	set		file_name		= upper(@p_file_name)
			,paths			= upper(@p_file_paths)
	where	id				= @p_id;
end ;

