CREATE PROCEDURE [dbo].[xsp_application_asset_machine_getrow]
(
	@p_asset_no nvarchar(50)
)
as
begin
	select	asm.asset_no
			,mmc.description 'machinery_category_desc'
			,mms.description 'machinery_subcategory_desc'
			,mmr.description 'machinery_merk_desc'
			,mml.description 'machinery_model_desc'
			,mmt.description 'machinery_type_desc'
			,mmu.description 'machinery_unit_desc'
			,asm.machinery_category_code
			,asm.machinery_subcategory_code
			,asm.machinery_merk_code
			,asm.machinery_model_code
			,asm.machinery_type_code
			,asm.machinery_unit_code
			,asm.asset_description
			,asm.invoice_no
			,asm.invoice_date
			,asm.chassis_no
			,asm.engine_no
			,asm.serial_no
			,asm.certificate_no
			,asm.faktur_no
			,asm.pib_no
			,asm.colour
			,asm.dimension
			,asm.hour_meter
			,asm.bill_of_landing
			,asm.remarks
			,aa.asset_condition
	from	application_asset_machine asm
			left join master_machinery_category mmc on (mmc.code	 = asm.machinery_category_code)
			left join master_machinery_subcategory mms on (mms.code = asm.machinery_subcategory_code)
			left join master_machinery_merk mmr on (mmr.code		 = asm.machinery_merk_code)
			left join master_machinery_model mml on (mml.code		 = asm.machinery_model_code)
			left join master_machinery_type mmt on (mmt.code		 = asm.machinery_type_code)
			left join master_machinery_unit mmu on (mmu.code		 = asm.machinery_unit_code)
			left join dbo.application_asset aa on (aa.asset_no		 = asm.asset_no)
	where	asm.asset_no = @p_asset_no ;
end ;

