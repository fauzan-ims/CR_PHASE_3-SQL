
CREATE procedure [dbo].[xsp_master_region_plate_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,region_code
			,plate_code
	from	master_region_plate
	where	id = @p_id ;
end ;


