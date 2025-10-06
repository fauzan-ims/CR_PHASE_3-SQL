CREATE procedure [dbo].[xsp_insurance_register_asset_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	ira.code
			,register_code
			,fa_code
			,ass.item_name
			,sum_insured_amount
			,depreciation_code
			,md.depreciation_name
			,collateral_type
			,collateral_category_code
			,mcc.category_name		 'collateral_category_name'
			,ira.occupation_code
			,mo.occupation_name
			,region_code
			,mr.region_name
			--,collateral_year
			,is_authorized_workshop
			,is_commercial
			,av.plat_no
			,av.engine_no
			,av.chassis_no
			,ira.insert_type
			,ira.accessories
			,av.built_year			 'collateral_year'
	from	insurance_register_asset				 ira
			left join dbo.asset						 ass on (ass.code		= ira.fa_code)
			left join dbo.asset_vehicle				 av on (av.asset_code	= ass.code)
			left join dbo.master_collateral_category mcc on (mcc.code		= ira.collateral_category_code)
			left join dbo.master_region				 mr on (ira.region_code = mr.code)
			left join dbo.master_depreciation		 md on (md.code			= ira.depreciation_code)
			left join dbo.master_occupation			 mo on (mo.code			= ira.occupation_code)
	where	ira.code = @p_code ;
end ;
