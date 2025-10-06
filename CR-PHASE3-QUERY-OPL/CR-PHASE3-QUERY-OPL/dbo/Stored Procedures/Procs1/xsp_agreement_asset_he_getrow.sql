
create procedure dbo.xsp_agreement_asset_he_getrow
(
	@p_asset_no nvarchar(50)
)
as
begin
	select	ash.asset_no
			,ash.he_category_code
			,ash.he_subcategory_code
			,ash.he_merk_code
			,ash.he_model_code
			,ash.he_type_code
			,ash.he_unit_code
			,ash.colour
			,ash.remarks
			,mmc.description 'he_category_desc'
			,mms.description 'he_subcategory_desc'
			,mmr.description 'he_merk_desc'
			,mml.description 'he_model_desc'
			,mmt.description 'he_type_desc'
			,mmu.description 'he_unit_desc'
			,aa.asset_condition
	from	agreement_asset_he ash
			inner join dbo.agreement_asset aa on (aa.asset_no		= ash.asset_no)
			left join master_he_category mmc on (mmc.code			= ash.he_category_code)
			left join master_he_subcategory mms on (mms.code		= ash.he_subcategory_code)
			left join master_he_merk mmr on (mmr.code				= ash.he_merk_code)
			left join master_he_model mml on (mml.code				= ash.he_model_code)
			left join master_he_type mmt on (mmt.code				= ash.he_type_code)
			left join master_he_unit mmu on (mmu.code				= ash.he_unit_code)
	where	ash.asset_no = @p_asset_no ;
end ;
