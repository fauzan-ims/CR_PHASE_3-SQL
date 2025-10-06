CREATE procedure dbo.xsp_asset_maintenance_temp_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,service_code
	from	asset_maintenance_temp
	where	id = @p_id ;
end ;
