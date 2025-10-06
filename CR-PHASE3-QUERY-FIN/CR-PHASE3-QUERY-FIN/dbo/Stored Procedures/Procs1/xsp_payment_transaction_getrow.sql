CREATE PROCEDURE dbo.xsp_payment_transaction_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	ptn.code
			,ptn.branch_code
			,ptn.branch_name
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
			,bank_gl_link_code
			,ptn.branch_bank_account_no
			,pdc_code
			,pdc_no
			,to_bank_name
			,to_bank_account_name
			,to_bank_account_no
			,is_reconcile
			,reconcile_date
			,reversal_code
			,ptn.reversal_date
			,jgl.gl_link_name 'bank_gl_link_name'
			,ptn.total_tax_amount
			,rm.code 'rev_code' -- (+) Ari 2023-09-08 ket : 
	from	payment_transaction ptn
			left join dbo.journal_gl_link jgl on (jgl.code = ptn.bank_gl_link_code)
			left join dbo.reversal_main rm on (rm.source_reff_code = ptn.code)
	where	ptn.code = @p_code ;
end ;
