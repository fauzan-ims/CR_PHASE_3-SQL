CREATE PROCEDURE [dbo].[xsp_insurance_policy_asset_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	ipa.code
			,policy_code
			,fa_code
			,ass.item_name
			,sum_insured_amount
			,depreciation_code
			,md.depreciation_name
			,collateral_type
			,collateral_category_code
			,ipa.occupation_code
			,mo.occupation_name
			,region_code
			,mr.region_name
			,collateral_year
			,is_authorized_workshop
			,is_commercial
			,coverage.buy_amount 'total_premi_amount'
			,ipa.status_asset
			,ipa.accessories
			,ipm.policy_payment_status
	from	insurance_policy_asset ipa
	outer apply (select sum(buy_amount) 'buy_amount' from dbo.insurance_policy_asset_coverage ipac where ipac.register_asset_code = ipa.code) coverage
	left join dbo.asset ass on (ass.code = ipa.fa_code)
	left join dbo.master_depreciation md on (md.code = ipa.depreciation_code)
	left join dbo.master_occupation mo on (mo.code = ipa.occupation_code)
	left join dbo.master_region mr on (mr.code = ipa.region_code)
	inner join dbo.insurance_policy_main ipm on(ipm.code = ipa.policy_code)
	where	ipa.code = @p_code ;
end ;
