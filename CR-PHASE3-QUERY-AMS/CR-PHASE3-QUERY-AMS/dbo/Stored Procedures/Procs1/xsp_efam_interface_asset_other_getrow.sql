CREATE procedure dbo.xsp_efam_interface_asset_other_getrow
(
	@p_asset_code nvarchar(50)
)
as
begin
	select	asset_code
			,remark
	from	efam_interface_asset_other
	where	asset_code = @p_asset_code ;
end ;
