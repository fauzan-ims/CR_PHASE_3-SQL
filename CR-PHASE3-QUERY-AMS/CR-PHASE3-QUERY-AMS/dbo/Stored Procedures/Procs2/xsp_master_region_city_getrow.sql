
CREATE procedure [dbo].[xsp_master_region_city_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,region_code
			,city_code
			,city_name
	from	master_region_city
	where	id = @p_id ;
end ;


