CREATE procedure dbo.xsp_efam_interface_asset_furniture_getrow
(
	@p_asset_code nvarchar(50)
)
as
begin
	select	asset_code
			,merk_code
			,merk_name
			,type_code
			,type_name
			,model_code
			,model_name
			,remark
	from	efam_interface_asset_furniture
	where	asset_code = @p_asset_code ;
end ;
