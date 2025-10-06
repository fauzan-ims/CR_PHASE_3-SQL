CREATE PROCEDURE dbo.xsp_efam_interface_asset_electronic_getrow
(
	@p_asset_code nvarchar(50)
)
as
begin
	select	asset_code
			,merk_code
			,merk_name
			,type_item_code
			,type_item_name
			,model_code
			,model_name
			,serial_no
			,dimension
			,hdd
			,processor
			,ram_size
			,domain
			,imei
			,remark
	from	efam_interface_asset_electronic
	where	asset_code = @p_asset_code ;
end ;
