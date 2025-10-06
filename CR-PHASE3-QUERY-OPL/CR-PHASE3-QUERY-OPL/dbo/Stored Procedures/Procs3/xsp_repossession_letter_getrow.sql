CREATE PROCEDURE dbo.xsp_repossession_letter_getrow
(
	@p_code nvarchar(50)
)
as
begin

	declare	@table_name	nvarchar(50)
			,@sp_name	nvarchar(250)

	select	@table_name = table_name
			,@sp_name	= sp_name
	from	dbo.sys_report
	where	table_name = 'RPT_SKT' ;

	select	rlr.code
			,rlr.branch_code
			,rlr.branch_name
			,rlr.letter_status
			,rlr.letter_date
			,rlr.letter_no
			,rlr.letter_remarks
			,isnull(rlr.letter_proceed_by,'I') as 'letter_proceed_by'
			,rlr.letter_executor_code
			--,me.executor_name 
			,rlr.letter_collector_code
			,rlr.letter_collector_name 
			,rlr.letter_collector_position
			,rlr.letter_signer_collector_code
			,rlr.letter_signer_collector_name 
			,rlr.letter_signer_collector_position 
			,rlr.letter_eff_date
			,rlr.letter_exp_date
			,rlr.agreement_no
			,amn.agreement_external_no
			,amn.client_name
			--,rlr.mak_code
			--,mm.mak_no
			--,rlr.installment_amount
			--,rlr.installment_due_date
			,rlr.companion_name
			,rlr.companion_id_no
			,rlr.companion_job
			,rlr.overdue_period
			,rlr.overdue_days
			,rlr.overdue_penalty_amount
			--,rlr.overdue_installment_amount
			--,rlr.outstanding_installment_amount
			,rlr.outstanding_deposit_amount
			--,rlr.is_wo
			--,rlr.is_remedial
			,rlr.result_status
			,rlr.result_date
			,rlr.result_action
			--,mm.mak_no
			--,rlr.current_overdue_installment_amount
			--,rlr.current_overdue_penalty_amount
			--,rlr.result_received_amount
			,rlr.rental_amount
			,rlr.overdue_invoice_amount
			,rlr.outstanding_rental_amount
			,rlr.rental_due_date
			,@table_name 'table_name'
			,@sp_name	'sp_name'
	from	repossession_letter rlr
			left join dbo.agreement_main amn on (amn.agreement_no = rlr.agreement_no)
			--left join dbo.mak_main mm on (mm.code = rlr.mak_code)
			left join dbo.master_collector mcr on (mcr.code	= rlr.letter_collector_code)
			left join dbo.master_collector mcrs on (mcrs.code = rlr.letter_signer_collector_code)
			--left join dbo.master_executor me on (me.code = rlr.letter_executor_code)
	where	rlr.code = @p_code ;
end ;
