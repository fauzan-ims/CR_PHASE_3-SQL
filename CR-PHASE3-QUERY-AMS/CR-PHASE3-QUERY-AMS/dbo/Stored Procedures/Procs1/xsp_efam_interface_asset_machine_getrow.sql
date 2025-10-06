CREATE PROCEDURE dbo.xsp_efam_interface_asset_machine_getrow
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
			,built_year
			,chassis_no
			,engine_no
			,colour
			,serial_no
			,remark
	from	efam_interface_asset_machine
	where	asset_code = @p_asset_code ;
end ;
