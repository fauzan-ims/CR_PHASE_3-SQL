CREATE procedure [dbo].[xsp_warning_letter_invoice_getrow]
(
	@p_keywords nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage int
	,@p_order_by int
	,@p_sort_by nvarchar(5)
	,@p_code nvarchar(50)
	,@invoice_no nvarchar(50)
)
as
begin
	select	WARNING_LETTER.CODE			'sp_no'
			,AGREEMENT_OBLIGATION.INVOICE_NO
			,INVOICE_TYPE
			,BILLING_DATE			'billing_date'
			,'2025-07-21'			'new_billing_date'
			,'2025-07-21'			'billing_due_date'
			,BILLING_AMOUNT			'billing_amount'
			,500000.00				'os_invoice_amount'
			,OVERDUE_DAYS
			,INVOICE_STATUS			'status'
			,'2025-07-21'			'paid_date'
			,'2025-07-21'			'promise_date'
			,TOTAL_PPN_AMOUNT		'ppn_amount'
			,TOTAL_PPH_AMOUNT		'pph_amount'
			,0						'partial_billing_amount'
			,0						'partial_ppn_amount'
			,0						'partial_pph_amount'
			,0						'os_billing_amount'
			,0						'os_ppn_amount'
			,0						'os_pph_amount'
			,'2025-07-21'			'last_partial_payment_date'
			----------------------------------------------------
			,AGREEMENT_MAIN.BRANCH_NAME
			,LETTER_DATE			'sp_date'
			,case
				when OVERDUE_DAYS > 60 then
					'SOMASI'
			end						'sp'
			,GENERATE_TYPE
			,AGREEMENT_MAIN.CLIENT_NAME
			,OVERDUE_PENALTY_AMOUNT 'total_overdue_amount'
			,50						'total_agreement'
			,50						'totaal_asset'
			,500000.00				'total_monthly_rental_amount'
	from	WARNING_LETTER
			join dbo.AGREEMENT_OBLIGATION on AGREEMENT_OBLIGATION.AGREEMENT_NO			= WARNING_LETTER.AGREEMENT_NO
			join dbo.AGREEMENT_MAIN on AGREEMENT_MAIN.AGREEMENT_NO					= AGREEMENT_OBLIGATION.AGREEMENT_NO
			join dbo.INVOICE on INVOICE.INVOICE_NO										= AGREEMENT_OBLIGATION.INVOICE_NO
			join dbo.AGREEMENT_ASSET_AMORTIZATION on AGREEMENT_ASSET_AMORTIZATION.INVOICE_NO = dbo.AGREEMENT_OBLIGATION.INVOICE_NO
													and AGREEMENT_ASSET_AMORTIZATION.BILLING_NO = dbo.AGREEMENT_OBLIGATION.INSTALLMENT_NO
	where AGREEMENT_MAIN.CLIENT_NO		= @p_code
		and AGREEMENT_OBLIGATION.INVOICE_NO = @invoice_no
		and OBLIGATION_DAY					=
			(
				select	max(OBLIGATION_DAY)
				from	WARNING_LETTER
						join dbo.AGREEMENT_OBLIGATION on AGREEMENT_OBLIGATION.AGREEMENT_NO = WARNING_LETTER.AGREEMENT_NO
						join dbo.AGREEMENT_MAIN on AGREEMENT_MAIN.AGREEMENT_NO = AGREEMENT_OBLIGATION.AGREEMENT_NO
				where CLIENT_NO = @p_code
			) ;
end ;

