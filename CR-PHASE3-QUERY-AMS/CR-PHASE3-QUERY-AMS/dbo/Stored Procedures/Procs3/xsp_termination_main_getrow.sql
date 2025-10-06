CREATE PROCEDURE dbo.xsp_termination_main_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	tm.code
			,tm.branch_code
			,tm.branch_name
			,tm.policy_code
			,tm.termination_status
			,tm.termination_date
			,tm.termination_amount
			,tm.termination_approved_amount
			,tm.termination_remarks
			,tm.termination_request_code
			,tm.received_request_code
			,ipm.insurance_type
			,mi.insurance_name
			,ipm.policy_eff_date
			,ipm.policy_exp_date
			,ipm.policy_no
			,termination_reason_code
			,ipm.insured_qq_name
			--,ipm.fa_code
			--,ass.item_name 'fa_name'
			,sgs.description 'termination_reason_desc'
	from	termination_main tm
			inner join dbo.insurance_policy_main ipm on (ipm.code = tm.policy_code)
			inner join dbo.master_insurance mi on (mi.code		  = ipm.insurance_code)
			left join dbo.sys_general_subcode sgs on (sgs.code	  = tm.termination_reason_code)
			--left join dbo.asset ass on (ipm.fa_code				  = ass.code)
	where	tm.code = @p_code ;
end ;
