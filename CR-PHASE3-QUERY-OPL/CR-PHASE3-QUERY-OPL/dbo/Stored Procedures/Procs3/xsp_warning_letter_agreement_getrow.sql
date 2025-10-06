-- Stored Procedure

CREATE procedure [dbo].[xsp_warning_letter_agreement_getrow]
(
	@p_keywords nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage int
	,@p_order_by int
	,@p_sort_by nvarchar(5)
	,@p_code nvarchar(50)
	,@agreement_no nvarchar(50)
)
as
begin
	select	AGREEMENT_MAIN.AGREEMENT_NO
			,AGREEMENT_OBLIGATION.ASSET_NO
			,1							'billing_no'
			,DESCRIPTION				'description'
			,MONTHLY_RENTAL_ROUNDED_AMOUNT
			,5000.00					'billing_amount'
			,TOTAL_PPN_AMOUNT			'ppn_amount'
			,TOTAL_PPH_AMOUNT			'pph_amount'
	from	WARNING_LETTER
			join dbo.AGREEMENT_OBLIGATION on AGREEMENT_OBLIGATION.AGREEMENT_NO			= WARNING_LETTER.AGREEMENT_NO
			join dbo.AGREEMENT_MAIN on AGREEMENT_MAIN.AGREEMENT_NO					= AGREEMENT_OBLIGATION.AGREEMENT_NO
			join dbo.INVOICE on INVOICE.INVOICE_NO										= AGREEMENT_OBLIGATION.INVOICE_NO
			join dbo.AGREEMENT_ASSET on AGREEMENT_ASSET.AGREEMENT_NO					= AGREEMENT_MAIN.AGREEMENT_NO
			join dbo.AGREEMENT_ASSET_AMORTIZATION on AGREEMENT_ASSET_AMORTIZATION.INVOICE_NO = dbo.AGREEMENT_OBLIGATION.INVOICE_NO
													and AGREEMENT_ASSET_AMORTIZATION.BILLING_NO = dbo.AGREEMENT_OBLIGATION.INSTALLMENT_NO
	where AGREEMENT_MAIN.CLIENT_NO	= @p_code
		and AGREEMENT_MAIN.AGREEMENT_NO = @agreement_no
		and OBLIGATION_DAY				=
			(
				select	max(OBLIGATION_DAY)
				from	WARNING_LETTER
						join dbo.AGREEMENT_OBLIGATION on AGREEMENT_OBLIGATION.AGREEMENT_NO = WARNING_LETTER.AGREEMENT_NO
						join dbo.AGREEMENT_MAIN on AGREEMENT_MAIN.AGREEMENT_NO = AGREEMENT_OBLIGATION.AGREEMENT_NO
				where WARNING_LETTER.CLIENT_NO = @p_code
			) ;
end ;

