
create procedure xsp_efam_interface_asset_barcode_image_getrow
(
	@p_asset_code			nvarchar(50)
) as
begin

	select		asset_code
		,barcode
		,barcode_image
	from	efam_interface_asset_barcode_image
	where	asset_code	= @p_asset_code
end
