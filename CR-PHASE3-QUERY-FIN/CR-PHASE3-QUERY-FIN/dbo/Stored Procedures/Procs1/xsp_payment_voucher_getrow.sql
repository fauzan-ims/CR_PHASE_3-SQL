CREATE PROCEDURE [dbo].[xsp_payment_voucher_getrow]
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
	where	table_name = 'RPT_PAYMENT_VOUCHER' ;

	select	pv.code
			,pv.branch_code
			,pv.branch_name
			,payment_status
			,payment_transaction_date
			,payment_value_date
			,payment_orig_amount
			,payment_orig_currency_code
			,payment_exch_rate
			,payment_base_amount
			,payment_type
			,payment_remarks
			,branch_bank_code
			,branch_bank_name
			,branch_gl_link_code
			,pdc_code
			,pdc_no
			,to_bank_name
			,to_bank_account_name
			,to_bank_account_no
			,is_reconcile
			,reconcile_date
			,reversal_code
			,pv.reversal_date
			,@table_name	'table_name'
			,@sp_name		'sp_name'
			,@rpt_code		'rpt_code'
			,@report_name	'report_name'
			,rm.code 'rev_code' -- (+) Ari 2023-09-08 ket : add view approval for reversal
	from	payment_voucher pv 
	left	join dbo.reversal_main rm on (rm.source_reff_code = pv.code) -- (+) Ari 2023-09-08 ket : add view approval for reversal
	where	pv.code = @p_code ;
end ;
