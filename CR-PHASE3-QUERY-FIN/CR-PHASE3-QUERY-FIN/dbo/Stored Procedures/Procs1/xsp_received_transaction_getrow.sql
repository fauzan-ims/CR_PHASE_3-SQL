CREATE PROCEDURE [dbo].[xsp_received_transaction_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	rt.code
			,rt.branch_code
			,rt.branch_name
			,rt.received_status
			,rt.received_from
			,rt.received_transaction_date
			,rt.received_value_date
			,rt.received_orig_amount
			,rt.received_orig_currency_code
			,rt.received_exch_rate
			,rt.received_base_amount
			,rt.received_remarks
			,rt.bank_gl_link_code
			,rt.branch_bank_code
			,rt.branch_bank_name
			,jgl.gl_link_name 'bank_gl_link_name'
			,rt.is_reconcile
			,rt.reconcile_date
			,rt.reversal_code
			,rt.reversal_date
			,rt.is_fix_bank
			,rm.code 'rev_code' -- (+) Ari 2023-09-08 ket : add reversal code
	from	received_transaction rt
			left join dbo.journal_gl_link jgl on (jgl.code = rt.bank_gl_link_code)
			left join dbo.reversal_main rm on (rm.source_reff_code = rt.code) -- (+) Ari 2023-09-08 ket : add reversal code
	where	rt.code = @p_code ;
end ;

