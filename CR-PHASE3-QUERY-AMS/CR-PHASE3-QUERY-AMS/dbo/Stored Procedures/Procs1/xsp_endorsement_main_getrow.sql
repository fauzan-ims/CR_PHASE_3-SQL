CREATE PROCEDURE dbo.xsp_endorsement_main_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	em.code
			,em.branch_code
			,em.branch_name
			,em.endorsement_status
			,em.endorsement_date
			,em.policy_code
			,em.endorsement_type
			,em.endorsement_remarks
			,em.currency_code
			,em.endorsement_payment_amount
			,em.endorsement_received_amount
			,em.payment_request_code
			,em.received_request_code
			,mi.insurance_name
			,ipm.policy_no
			--,ipm.collateral_type
			,ipm.insurance_type
			,ipm.policy_eff_date
			,ipm.policy_exp_date
			,em.endorsement_reason_code
			,sgs.description 'endorsement_reason_desc'
			--,ipm.fa_code
			--,aa.item_name 'fa_name'
			,ipm.insured_qq_name
	from	endorsement_main em
			inner join dbo.insurance_policy_main ipm on (ipm.code = em.policy_code)
			--inner join asset aa on (aa.code						  = ipm.fa_code)
			left join dbo.master_insurance mi on (mi.code		  = ipm.insurance_code)
			left join dbo.sys_general_subcode sgs on (sgs.code	  = em.endorsement_reason_code)
	where	em.code = @p_code ;
end ;
