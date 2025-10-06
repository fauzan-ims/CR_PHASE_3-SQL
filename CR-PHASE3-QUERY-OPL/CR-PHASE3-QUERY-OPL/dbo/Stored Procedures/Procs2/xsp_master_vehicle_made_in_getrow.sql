---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE procedure [dbo].[xsp_master_vehicle_made_in_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,description
			,is_active
	from	master_vehicle_made_in
	where	code = @p_code ;
end ;


