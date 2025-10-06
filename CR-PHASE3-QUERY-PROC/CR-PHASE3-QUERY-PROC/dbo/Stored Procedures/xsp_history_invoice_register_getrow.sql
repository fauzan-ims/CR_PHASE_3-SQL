CREATE PROCEDURE [dbo].[xsp_history_invoice_register_getrow]
(
	@p_from_date datetime
	,@p_to_date	 datetime
)
as
begin
	select	code					   'Invoice Code'
			,air.supplier_name		   'Supplier'
			,air.invoice_date		   'Invoice Receive Date'
			,air.due_date			   'Due Date'
			,air.tax_invoice_date	   'Tax Invoice Date'
			,air.file_invoice_no	   'Invoice No'
			,air.discount			   'Discount Amount'
			,air.ppn				   'PPN'
			,air.pph				   'PPH'
			,air.invoice_amount		   'Total Amount'
			,air.remark				   'Remark'
			,air.to_bank_name		   'To Bank Name'
			,air.to_bank_account_no	   'To Bank Acoount No'
			,air.to_bank_account_name  'To Bank Account Name'
			,invoice_detail.total_data 'Total GRN'
			,air.status
	from	dbo.ap_invoice_registration air
			outer apply
	(
		select		count(1) 'total_data'
					,aird.grn_code
		from		dbo.ap_invoice_registration_detail aird
		where		aird.invoice_register_code = air.code
		group by	aird.grn_code
	)									invoice_detail
	where	air.tax_invoice_date
	between @p_from_date and @p_to_date ;
end ;
