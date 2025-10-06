CREATE PROCEDURE [dbo].[xsp_master_insurance_rate_non_life_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	mirnl.code
			,mirnl.insurance_code
			,mirnl.collateral_type_code
			,mirnl.collateral_category_code
			,mirnl.coverage_code
			,mirnl.day_in_year
			,mirnl.region_code
			,mirnl.occupation_code
			,mirnl.is_active
			,mi.insurance_name
			,sgs.description
			,mc.coverage_name
			,mcc.category_name
			,mr.region_name
			,mo.occupation_name
			,mc.currency_code
	from	master_insurance_rate_non_life mirnl
			inner join dbo.master_insurance mi on (mi.code			   = mirnl.insurance_code)
			inner join dbo.sys_general_subcode sgs on (sgs.code		   = mirnl.collateral_type_code)
			inner join dbo.master_coverage mc on (mc.code			   = mirnl.coverage_code)
			inner join dbo.master_collateral_category mcc on (mcc.code = mirnl.collateral_category_code)
			left join dbo.master_region mr on (mr.code				   = mirnl.region_code)
			left join dbo.master_occupation mo on (mo.code			   = mirnl.occupation_code)
	where	mirnl.code = @p_code ;
end ;



