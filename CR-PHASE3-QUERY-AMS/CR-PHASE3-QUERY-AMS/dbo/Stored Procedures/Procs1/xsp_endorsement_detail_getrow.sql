CREATE PROCEDURE dbo.xsp_endorsement_detail_getrow
(
	@p_endorsement_code nvarchar(50)
	,@p_old_or_new		nvarchar(3)
)
as
begin
	select	ed.id
			,ed.old_or_new 'old'
			,ed.old_or_new 'new'
			,ed.occupation_code 'occupation_code_old'
			,ed.occupation_code 'occupation_code_new'
			,ed.region_code 'region_code_old'
			,ed.region_code 'region_code_new'
			,ed.collateral_category_code 'collateral_category_code_old'
			,ed.collateral_category_code 'collateral_category_code_new'
			,ed.object_name 'object_name_old'
			,ed.object_name 'object_name_new'
			,ed.insured_name 'insured_name_old'
			,ed.insured_name 'insured_name_new'
			,ed.insured_qq_name 'insured_qq_name_old'
			,ed.insured_qq_name 'insured_qq_name_new'
			,ed.eff_date 'eff_date_old'
			,ed.eff_date 'eff_date'
			,ed.exp_date 'exp_date_old'
			,ed.exp_date 'exp_date'
			--,ipm.collateral_type 'collateral_type_old'
			--,ipm.collateral_type 'collateral_type_new'
			--,sg.description 'collateral_type_name_old'
			--,sg.description 'collateral_type_name_new'
			,mcca.collateral_type_code 'collateral_type_code_old'
			,mcca.collateral_type_code 'collateral_type_code_new'
			,mcc.category_name 'category_name_old'
			,mcc.category_name 'category_name_new'
			,mo.occupation_name	 'occupation_name_old'
			,mo.occupation_name	 'occupation_name_new'
			,mr.region_name	 'region_name_old'
			,mr.region_name	 'region_name_new'
	from	endorsement_detail ed
			inner join dbo.endorsement_main em on (em.code			   = ed.endorsement_code)
			inner join dbo.insurance_policy_main ipm on (ipm.code	   = em.policy_code)
			left join dbo.master_collateral_category mcc on (mcc.code = ed.collateral_category_code)
			left join dbo.master_collateral_category mcca on (mcca.code = ed.collateral_category_code)
			left join dbo.master_occupation mo on (mo.code			   = ed.occupation_code)
			left join dbo.master_region mr on (mr.code				   = ed.region_code)
			--left join dbo.sys_general_subcode sg on (sg.code		   = ipm.collateral_type)
	where	endorsement_code = @p_endorsement_code
			and old_or_new	 = @p_old_or_new ;
end ;

