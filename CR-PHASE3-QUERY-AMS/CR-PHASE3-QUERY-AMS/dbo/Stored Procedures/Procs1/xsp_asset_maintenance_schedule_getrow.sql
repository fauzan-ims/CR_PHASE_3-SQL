CREATE PROCEDURE dbo.xsp_asset_maintenance_schedule_getrow
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
	from	asset_maintenance_schedule
	where	ID = @p_id ;
end ;
