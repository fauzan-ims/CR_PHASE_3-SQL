CREATE procedure [dbo].[xsp_claim_main_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	cm.code
			,cm.branch_code
			,cm.branch_name
			,cm.policy_code
			,cm.claim_status
			,cm.claim_progress_status
			,cm.claim_amount
			,cm.claim_remarks
			,cm.claim_reff_external_no
			,cm.claim_loss_type
			,sgs.description	'claim_loss_type_desc'
			,cm.claim_request_code
			,cm.loss_date
			,cm.customer_report_date
			,cm.finance_report_date
			,cm.result_report_date
			,cm.received_request_code
			,cm.received_voucher_no
			,cm.received_voucher_date
			,ipm.insured_name
			,insurance_name
			,mi.insurance_type
			,ipm.policy_eff_date
			,ipm.policy_exp_date
			,ipm.policy_no
			,is_policy_terminate
			,cm.is_ex_gratia
			,cm.claim_reason_code
			--,ipm.fa_code
			--,ass.item_name 'fa_name'
			,sgs1.description	'claim_reason_desc'
			,cm.file_name
			,cm.file_path
	from	claim_main							 cm
			inner join dbo.insurance_policy_main ipm on (ipm.code	= cm.policy_code)
			left join dbo.master_insurance		 mi on (mi.code		= ipm.insurance_code)
			left join dbo.sys_general_subcode	 sgs on (sgs.code	= cm.claim_loss_type)
			left join dbo.sys_general_subcode	 sgs1 on (sgs1.code = cm.claim_reason_code)
	--left join dbo.asset ass on (ipm.fa_code = ass.code)
	where	cm.code = @p_code ;
end ;
