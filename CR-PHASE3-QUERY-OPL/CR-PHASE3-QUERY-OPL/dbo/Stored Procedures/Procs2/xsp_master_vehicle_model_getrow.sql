---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[xsp_master_vehicle_model_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	mvm.code
			,vehicle_merk_code
			,mv.description 'vehicle_merk_name'
			,vehicle_subcategory_code
			,mvs.description 'vehicle_subcategory_name'
			,mmc.code 'vehicle_category_code'
			,mmc.description 'vehicle_category_name'
			,mvm.description
			,mvm.is_active
	from	master_vehicle_model mvm
			inner join dbo.master_vehicle_merk mv on (mv.code			 = mvm.vehicle_merk_code)
			inner join dbo.master_vehicle_subcategory mvs on (mvs.code = mvm.vehicle_subcategory_code)
			inner join dbo.master_vehicle_category mmc on (mmc.code	 = mvs.vehicle_category_code)
	where	mvm.code = @p_code ;
end ;

