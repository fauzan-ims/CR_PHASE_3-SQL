CREATE PROCEDURE [dbo].[xsp_et_main_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	declare @count		  int
			,@total		  decimal(18, 2)
			,@table_name  nvarchar(250)
			,@sp_name	  nvarchar(250)
			,@rpt_code	  nvarchar(50)
			,@report_name nvarchar(250) ;

	select	@count = count(id)
	from	dbo.et_detail
	where	et_code = @p_code ;

	select	@total = sum(transaction_amount)
	from	dbo.et_transaction
	where	et_code			   = @p_code
			and is_transaction = '1' ;

	select	@table_name	  = table_name
			,@sp_name	  = sp_name
			,@rpt_code	  = code
			,@report_name = name
	from	dbo.sys_report
	where	table_name = 'RPT_EARLY_TERMINATION' ;

	select	etm.code
			,etm.branch_code
			,etm.branch_name
			,etm.agreement_no
			,etm.et_status
			,etm.et_date
			,etm.et_exp_date
			,etm.et_amount
			,etm.et_remarks
			,etm.received_request_code
			,etm.received_voucher_no
			,etm.received_voucher_date
			,amn.agreement_external_no
			,amn.client_name
			,amn.agreement_sub_status
			,@table_name  'table_name'
			,@sp_name	  'sp_name'
			,@rpt_code	  'rpt_code'
			,@report_name 'report_name'
			,@count		  'et_count'
			,@total		  'total_amount'
			,etm.file_name
			,etm.file_path
			,etm.reason
			,etm.refund_amount
			,etm.credit_note_amount
			,etm.bank_code
			,etm.bank_name
			,etm.bank_account_no
			,etm.bank_account_name
			,is_purchase_requirement_after_lease
	from	et_main						 etm
			left join dbo.agreement_main amn on (amn.agreement_no = etm.agreement_no)
	where	etm.code = @p_code ;
end ;
