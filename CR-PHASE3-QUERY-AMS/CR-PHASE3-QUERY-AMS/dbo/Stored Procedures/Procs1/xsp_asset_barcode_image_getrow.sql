CREATE PROCEDURE dbo.xsp_asset_barcode_image_getrow
(
	@p_asset_code nvarchar(50)
)
as
begin
	select	asset_code
			,barcode as 'barcode_detail'
			,barcode_image
	from	asset_barcode_image
	where	asset_code = @p_asset_code ;
end ;
