CREATE PROCEDURE dbo.xsp_ap_invoice_registration_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	air.code
			,air.company_code
			,air.invoice_date
			,air.currency_code
			,air.supplier_code
			,air.supplier_name
			,air.invoice_amount
			,air.file_invoice_no
			,air.ppn
			,air.pph
			,air.bill_type
			,air.discount
			,air.due_date
			,air.purchase_order_code
			,air.tax_invoice_date
			,air.branch_code
			,air.branch_name
			,air.division_code
			,air.division_name
			,air.department_code
			,air.department_name
			,air.to_bank_code
			,air.to_bank_name
			,air.to_bank_account_name
			,air.to_bank_account_no
			,air.payment_by
			,air.status
			,air.remark
			,air.file_name
			,air.paths
			,air.unit_price
			,po.UNIT_FROM
			,air.faktur_no
	from	ap_invoice_registration air
			left join dbo.purchase_order po on (po.code = air.purchase_order_code)
	where	air.code = @p_code ;
end ;
