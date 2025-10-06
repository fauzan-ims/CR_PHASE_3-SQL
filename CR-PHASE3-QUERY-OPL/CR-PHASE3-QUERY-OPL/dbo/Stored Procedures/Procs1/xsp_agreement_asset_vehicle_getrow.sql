CREATE PROCEDURE dbo.xsp_agreement_asset_vehicle_getrow
(
	@p_asset_no nvarchar(50)
)
as
begin
	select	pcv.asset_no
			,pcv.colour
			,pcv.transmisi
			,pcv.remarks
			,mvc.description 'vehicle_category_desc'
			,mvs.description 'vehicle_subcategory_desc'
			,mvm.description 'vehicle_merk_desc'
			,mvmo.description 'vehicle_model_desc'
			,mvt.description 'vehicle_type_desc'
			,mvu.description 'vehicle_unit_desc'
			,aa.asset_condition
	from	agreement_asset_vehicle pcv
			inner join dbo.agreement_asset aa				on (aa.asset_no		  = pcv.asset_no)
			left join dbo.master_vehicle_category mvc		on (mvc.code	  = pcv.vehicle_category_code)
			left join dbo.master_vehicle_subcategory mvs	on (mvs.code = pcv.vehicle_subcategory_code)
			left join dbo.master_vehicle_merk mvm			on (mvm.code		  = pcv.vehicle_merk_code)
			left join dbo.master_vehicle_model mvmo			on (mvmo.code	  = pcv.vehicle_model_code)
			left join dbo.master_vehicle_type mvt			on (mvt.code		  = pcv.vehicle_type_code)
			left join dbo.master_vehicle_unit mvu			on (mvu.code		  = pcv.vehicle_unit_code)
	where	pcv.asset_no = @p_asset_no ;
end ;
