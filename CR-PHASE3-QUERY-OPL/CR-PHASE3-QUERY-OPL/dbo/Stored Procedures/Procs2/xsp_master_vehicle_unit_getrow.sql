---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE procedure [dbo].[xsp_master_vehicle_unit_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	mvu.code
			,mvu.vehicle_category_code
			,c.description 'vehicle_category_name'
			,mvu.vehicle_subcategory_code
			,s.description 'vehicle_subcategory_name'
			,mvu.vehicle_merk_code
			,m.description 'vehicle_merk_name'
			,mvu.vehicle_model_code
			,mo.description 'vehicle_model_name'
			,mvu.vehicle_type_code
			,t.description 'vehicle_type_name'
			,mvu.vehicle_name
			,mvu.description
			,is_cbu
			,is_karoseri
			,mvu.is_active
	from	master_vehicle_unit mvu
			inner join dbo.master_vehicle_category c on (c.code	   = mvu.vehicle_category_code)
			inner join dbo.master_vehicle_subcategory s on (s.code = mvu.vehicle_subcategory_code)
			inner join dbo.master_vehicle_merk m on (m.code		   = mvu.vehicle_merk_code)
			inner join dbo.master_vehicle_model mo on (mo.code	   = mvu.vehicle_model_code)
			inner join dbo.master_vehicle_type t on (t.code		   = mvu.vehicle_type_code)
	where	mvu.code = @p_code ;
end ;


