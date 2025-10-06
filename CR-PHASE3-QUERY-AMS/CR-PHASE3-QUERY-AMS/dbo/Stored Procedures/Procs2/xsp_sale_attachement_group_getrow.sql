CREATE PROCEDURE [dbo].[xsp_sale_attachement_group_getrow]
(
	@p_code			nvarchar(50),
	@p_asset_code	nvarchar(50)
)
as
begin
	select	asset_code 'fixed_asset_no'
			,type_item_name 'fixed_asset_name'
			,plat_no
			,chassis_no
			,engine_no
			,type_item_name'item_name'
	from	dbo.asset_vehicle
	where	asset_code = @p_asset_code
end ;
