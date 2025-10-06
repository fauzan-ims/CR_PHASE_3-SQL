CREATE PROCEDURE dbo.xsp_asset_delivery_detail_upload_file_update
(
	@p_id			bigint
	,@p_file_name	nvarchar(250)
	,@p_file_paths	nvarchar(250)
)
as
begin
	update	dbo.asset_delivery_detail
	set		file_name		= upper(@p_file_name)
			,file_path		= upper(@p_file_paths)
	where	id				= @p_id;
end ;

