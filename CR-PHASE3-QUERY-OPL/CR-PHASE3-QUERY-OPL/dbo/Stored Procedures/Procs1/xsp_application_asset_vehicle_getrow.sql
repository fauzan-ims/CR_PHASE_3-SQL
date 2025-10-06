CREATE PROCEDURE [dbo].[xsp_application_asset_vehicle_getrow]
(
	@p_asset_no nvarchar(50)
)
as
begin
	select	pcv.asset_no
			,pcv.vehicle_category_code
			,pcv.vehicle_subcategory_code
			,pcv.vehicle_merk_code
			,pcv.vehicle_model_code
			,pcv.vehicle_type_code
			,pcv.vehicle_unit_code
			,pcv.asset_description
			,pcv.plat_no_1
			,pcv.plat_no_2
			,pcv.plat_no_3
			,pcv.cover_note
			,pcv.faktur_no
			,pcv.stnk_no
			,pcv.chassis_no
			,pcv.engine_no
			,pcv.pib_no
			,pcv.bpkb_no
			,pcv.bpkb_date
			,pcv.bpkb_name
			,pcv.bpkb_address
			,pcv.stnk_name
			,isnull(pcv.bpkb_name, pcv.stnk_name) 'bpkb_or_stnk_name'
			,pcv.stnk_expired_date
			,pcv.stnk_tax_date
			,pcv.invoice_type
			,pcv.colour
			,pcv.cylinder
			,pcv.fuel
			,pcv.transmisi
			,pcv.remarks
			,mvc.description 'vehicle_category_desc'
			,mvs.description 'vehicle_subcategory_desc'
			,mvm.description 'vehicle_merk_desc'
			,mvmo.description 'vehicle_model_desc'
			,mvt.description 'vehicle_type_desc'
			,mvu.description 'vehicle_unit_desc'
			,aa.asset_condition
	from	application_asset_vehicle pcv
			left join dbo.master_vehicle_category mvc on (mvc.code	  = pcv.vehicle_category_code)
			left join dbo.master_vehicle_subcategory mvs on (mvs.code = pcv.vehicle_subcategory_code)
			left join dbo.master_vehicle_merk mvm on (mvm.code		  = pcv.vehicle_merk_code)
			left join dbo.master_vehicle_model mvmo on (mvmo.code	  = pcv.vehicle_model_code)
			left join dbo.master_vehicle_type mvt on (mvt.code		  = pcv.vehicle_type_code)
			left join dbo.master_vehicle_unit mvu on (mvu.code		  = pcv.vehicle_unit_code)
			left join dbo.application_asset aa on (aa.asset_no		  = pcv.asset_no)
	where	pcv.asset_no = @p_asset_no ;
end ;

