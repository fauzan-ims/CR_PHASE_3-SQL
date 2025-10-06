CREATE PROCEDURE [dbo].[xsp_ap_payment_request_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	pr.code
			,pr.invoice_date
			,pr.currency_code
			,pr.supplier_code
			,pr.supplier_name
			,sum(apr.payment_amount) 'invoice_amount'
			,pr.ppn
			,pr.pph
			,pr.fee
			,sum(pr.discount) 'discount'
			,pr.due_date
			,pr.tax_invoice_date
			,pr.branch_code
			,pr.branch_name
			,pr.to_bank_code
			,pr.to_bank_name
			,pr.to_bank_account_name
			,pr.to_bank_account_no
			,pr.payment_by
			,pr.status
			,pr.remark
			,pr.payment_date
	from	ap_payment_request pr
			left join dbo.purchase_order po on (po.code = pr.purchase_order_code)
			left join dbo.ap_payment_request_detail apr on (pr.code = apr.payment_request_code)
	where	pr.code = @p_code 
	group by pr.code
			,pr.invoice_date
			,pr.currency_code
			,pr.supplier_code
			,pr.supplier_name
			,pr.invoice_amount
			,pr.ppn
			,pr.pph
			,pr.fee
			,pr.due_date
			,pr.tax_invoice_date
			,pr.branch_code
			,pr.branch_name
			,pr.to_bank_code
			,pr.to_bank_name
			,pr.to_bank_account_name
			,pr.to_bank_account_no
			,pr.payment_by
			,pr.status
			,pr.remark
			,pr.payment_date
end ;
