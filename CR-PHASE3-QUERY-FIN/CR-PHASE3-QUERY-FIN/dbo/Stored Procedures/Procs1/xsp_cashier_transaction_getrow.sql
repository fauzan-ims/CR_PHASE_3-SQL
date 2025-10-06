CREATE PROCEDURE [dbo].[xsp_cashier_transaction_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 
			,@countcashier	bigint;
	
	select	@rows_count = count(1)
	from	dbo.cashier_transaction_detail
	where	cashier_transaction_code = @p_code

	select	@countcashier	= count(1)
	from	dbo.cashier_transaction_detail
	where	cashier_transaction_code = @p_code
		
	select	ct.code
			,ct.branch_code
			,ct.branch_name
			,ct.cashier_main_code
			,ct.cashier_status
			,ct.cashier_trx_date
			,ct.cashier_value_date
			,ct.cashier_type
			,ct.cashier_orig_amount
			,ct.cashier_currency_code
			,ct.cashier_exch_rate
			,ct.cashier_base_amount
			,ct.cashier_remarks
			,case when @countcashier > 1 then ''
				else am.agreement_external_no 
			end	'agreement_external_no'			-- raffyanda 2025/08/30 agreement no dikosongkan jika cashier bisa multiple agreement 
			,ct.deposit_amount
			,ct.is_use_deposit
			,ct.deposit_used_amount
			,ct.received_amount
			,ct.receipt_code
			,ct.is_received_request
			,ct.card_receipt_reff_no
			,ct.card_bank_name
			,ct.card_account_name
			,ct.branch_bank_code
			,ct.branch_bank_name
			,ct.bank_gl_link_code
			,jgl.gl_link_name 'bank_gl_link_name'
			,ct.pdc_code
			,ct.pdc_no
			,ct.received_from
			,ct.received_collector_code
			,ct.received_collector_name
			,ct.received_payor_name
			,ct.received_payor_area_no_hp
			,ct.received_payor_no_hp
			,ct.received_request_code
			,ct.reversal_code
			,ct.reversal_date
			,ct.print_count
			,ct.print_max_count
			,ct.reff_no
			,ct.is_reconcile
			,ct.reconcile_date
			,ct.received_request_code
			--,am.client_name -- Louis Kamis, 26 Juni 2025 10.22.18 -- 
			,ct.client_no -- Louis Kamis, 26 Juni 2025 10.22.43 -- 
			,ct.client_name -- Louis Kamis, 26 Juni 2025 10.22.46 -- 
			,ct.agreement_no
			,am.currency_code
			,rm.receipt_no
			,cm.employee_name 'cashier_name'
			,ct.cre_date
			,am.factoring_type
			,ct.bank_account_name
			,ct.bank_account_no
			,rev.code 'rev_code'  -- (+) Ari 2023-09-08 ket : add view approval for reversal
	from	cashier_transaction ct
			left join dbo.agreement_main am on (am.agreement_no = ct.agreement_no)
			left join dbo.journal_gl_link jgl on (jgl.code = ct.bank_gl_link_code)
			left join dbo.receipt_main rm on (rm.code = ct.receipt_code)
			left join dbo.cashier_main cm on (cm.code = ct.cashier_main_code)
			--left join dbo.reversal_main rev on (rev.source_reff_code = ct.code) -- (+) Ari 2023-09-08 ket : add view approval for reversal
			outer apply -- (+) Ari 2023-10-23 ket : change, ambil latest reversal
			(
				select	top 1 rev.code 
				from	reversal_main rev
				where	rev.source_reff_code = ct.code
				order	by rev.cre_date desc
			) rev
	where	ct.code = @p_code ;
end ;
