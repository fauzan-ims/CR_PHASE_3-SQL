---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[xsp_master_vehicle_type_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	mmt.code
			,mmt.vehicle_model_code
			,mmm.description	'vehicle_model_name'
			,mmc.description	'vehicle_category_name'
			,mms.description	'vehicle_subcategory_name'
			,mmr.description	'vehicle_merk_name'
			,mmc.code	'vehicle_category_code'
			,mms.code	'vehicle_subcategory_code'
			,mmr.code	'vehicle_merk_code'
			,mmt.description
			,mmt.is_active
	from	master_vehicle_type mmt
			inner join dbo.master_vehicle_model mmm on (mmm.code = mmt.vehicle_model_code)
			inner join dbo.master_vehicle_merk mmr on (mmr.code = mmm.vehicle_merk_code)
			inner join dbo.master_vehicle_subcategory mms on (mms.code = mmm.vehicle_subcategory_code)
			inner join dbo.master_vehicle_category mmc on (mmc.code = mms.vehicle_category_code)
	where	mmt.code = @p_code ;
end ;


