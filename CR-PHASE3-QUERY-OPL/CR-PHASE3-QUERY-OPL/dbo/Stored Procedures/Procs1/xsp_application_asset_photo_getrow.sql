
CREATE procedure [dbo].[xsp_application_asset_photo_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,asset_no
			,remarks
			,file_name
			,paths
			,latitude
			,longitude
			,geo_address
	from	application_asset_photo
	where	id = @p_id ;
end ;

