---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[xsp_master_vehicle_merk_getrow]
(
	@p_code			nvarchar(50)
) as
begin

	select		m.code
				,m.description
				,m.vehicle_made_in_code
				,i.description 'vehicle_made_in_name'
				,m.is_active
	from	master_vehicle_merk m
			INNER JOIN dbo.MASTER_VEHICLE_MADE_IN i ON (i.CODE = m.VEHICLE_MADE_IN_CODE)
	where	m.code	= @p_code
end


