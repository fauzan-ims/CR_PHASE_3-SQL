CREATE PROCEDURE [dbo].[xsp_master_region_city_getrow_for_lookup_db]
(
	@p_region_code nvarchar(50)
)
as
begin
	select		id
				,city_code
				,city_name
	from		dbo.master_region_city
	where	region_code = @p_region_code ;
end ;

