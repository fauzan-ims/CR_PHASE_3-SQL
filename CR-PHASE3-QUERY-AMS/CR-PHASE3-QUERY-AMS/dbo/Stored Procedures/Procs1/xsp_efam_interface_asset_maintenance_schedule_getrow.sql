CREATE procedure dbo.xsp_efam_interface_asset_maintenance_schedule_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,asset_code
			,maintenance_no
			,maintenance_date
			,maintenance_status
			,last_status_date
			,reff_trx_no
	from	efam_interface_asset_maintenance_schedule
	where	id = @p_id ;
end ;
