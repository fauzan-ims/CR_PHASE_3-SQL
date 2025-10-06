CREATE PROCEDURE dbo.xsp_insurance_register_existing_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	ire.code
			,ire.register_no
			,ire.policy_code
			,ire.branch_code
			,ire.branch_name
			,ire.policy_name
			,ire.policy_qq_name
			,ire.register_status
			,ire.policy_object_name
			,ire.sum_insured_amount
			,ire.insurance_code
			,ire.insurance_type
			,ire.collateral_category_code
			,ire.depreciation_code
			,ire.occupation_code
			,ire.collateral_type
			,sgs.description 'collateral_desc'
			,ire.currency_code
			,ire.policy_no
			,ire.policy_eff_date
			,ire.policy_exp_date
			,ire.file_name
			,ire.paths
			,ire.region_code
			,ire.from_year
			,ire.to_year
			,ire.total_premi_sell_amount 'total_premi_amount'
			,ire.total_premi_buy_amount
			,ire.collateral_year
			,mi.insurance_name
			,mcc.category_name
			,md.depreciation_name
			,mo.occupation_name
			,mr.region_name
			,ire.source_type
			--,ass.item_name 'fa_name'
			,ire.fa_code
			,sgs.description 'collateral_type_desc'
	from	insurance_register_existing ire
			--inner join asset ass on (ass.code						  = ire.fa_code)
			left join dbo.master_insurance mi on (mi.code			  = ire.insurance_code)
			left join dbo.sys_general_subcode sgs on (sgs.code		  = ire.collateral_type)
			left join dbo.master_collateral_category mcc on (mcc.code = ire.collateral_category_code)
			left join dbo.master_depreciation md on (md.code		  = ire.depreciation_code)
			left join dbo.master_occupation mo on (mo.code			  = ire.occupation_code)
			left join dbo.master_region mr on (mr.code				  = ire.region_code)
	where	ire.code = @p_code ;
end ;
