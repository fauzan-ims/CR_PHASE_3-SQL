CREATE PROCEDURE [dbo].[xsp_insurance_policy_main_getrow_general]
(
	@p_agreement_no nvarchar(50)
	,@p_date		datetime
)
as
begin
	select	*
	from	dbo.insurance_policy_main
	where	 cast(@p_date as date)
			between cast(policy_eff_date as date) and cast(policy_exp_date as sql_variant)
			and policy_status = 'ACTIVE' ;
end ;

