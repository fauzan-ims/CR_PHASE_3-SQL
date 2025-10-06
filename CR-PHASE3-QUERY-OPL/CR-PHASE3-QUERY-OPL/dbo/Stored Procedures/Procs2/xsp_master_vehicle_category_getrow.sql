---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE procedure [dbo].[xsp_master_vehicle_category_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	mvc.code
			,mvc.description
			,mvc.is_active
	from	master_vehicle_category mvc
	where	mvc.code = @p_code ;
end ;


