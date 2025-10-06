CREATE PROCEDURE [dbo].[xsp_received_voucher_getrow]
(
	@p_code nvarchar(50)
)
as
begin

	declare @table_name		nvarchar(250)
			,@sp_name		nvarchar(250)
			,@rpt_code		nvarchar(50)
			,@report_name	nvarchar(250);

	select	@table_name		= table_name
			,@sp_name		= sp_name
			,@rpt_code		= code
			,@report_name	= name
	from	dbo.sys_report
	where	table_name = 'RPT_RECEIVED_VOUCHER' ;

	select	rvr.code
			,rvr.branch_code
			,rvr.branch_name
			,rvr.received_status
			,rvr.received_from
			,rvr.received_transaction_date
			,rvr.received_value_date
			,rvr.received_orig_amount
			,rvr.received_orig_currency_code
			,rvr.received_exch_rate
			,rvr.received_base_amount
			,rvr.received_remarks
			,rvr.branch_bank_code
			,rvr.branch_bank_name
			,rvr.branch_gl_link_code
			,jgl.gl_link_name 'branch_gl_link_name'
			,rvr.is_reconcile
			,rvr.reconcile_date
			,rvr.reversal_code
			,rvr.reversal_date
			,@table_name	'table_name'
			,@sp_name		'sp_name' 
			,@rpt_code		'rpt_code'
			,@report_name	'report_name'
			,rm.code 'rev_code' -- (+) Ari 2023-09-08 ket : add view approval fo reversal
	from	received_voucher rvr
			left join dbo.journal_gl_link jgl on (jgl.code = rvr.branch_gl_link_code)
			left join dbo.reversal_main rm on (rm.source_reff_code = rvr.code) -- (+) Ari 2023-09-08 ket : add view approval fo reversal
	where	rvr.code = @p_code ;
end ;

