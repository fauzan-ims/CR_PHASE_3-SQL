CREATE procedure [dbo].[xsp_master_insurance_depreciation_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,insurance_code
			,collateral_type_code
			,sgs.description
			,depreciation_code
			,md.depreciation_name
			,is_default
	from	master_insurance_depreciation mid
			inner join dbo.master_depreciation md on (md.code = mid.depreciation_code)
			inner join dbo.sys_general_subcode sgs on (sgs.code = mid.collateral_type_code)
	where	id = @p_id ;
end ;


