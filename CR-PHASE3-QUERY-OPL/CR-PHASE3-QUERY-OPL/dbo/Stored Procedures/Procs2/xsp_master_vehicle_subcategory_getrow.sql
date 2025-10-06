---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE procedure [dbo].[xsp_master_vehicle_subcategory_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	mvs.code
			,vehicle_category_code
			,mvc.description 'vehicle_category_name'
			,mvs.description
			,mvs.is_active
	from	master_vehicle_subcategory mvs
			inner join dbo.master_vehicle_category mvc on (mvc.code = mvs.vehicle_category_code)
	where	mvs.code = @p_code ;
end ;


