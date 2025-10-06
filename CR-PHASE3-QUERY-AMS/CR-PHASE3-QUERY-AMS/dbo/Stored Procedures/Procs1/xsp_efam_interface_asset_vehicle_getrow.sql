CREATE PROCEDURE dbo.xsp_efam_interface_asset_vehicle_getrow
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
			,plat_no
			,chassis_no
			,engine_no
			,bpkb_no
			,colour
			,cylinder
			,stnk_no
			,stnk_expired_date
			,stnk_tax_date
			,stnk_renewal
			,built_year
			,remark
	from	efam_interface_asset_vehicle
	where	asset_code = @p_asset_code ;
end ;
