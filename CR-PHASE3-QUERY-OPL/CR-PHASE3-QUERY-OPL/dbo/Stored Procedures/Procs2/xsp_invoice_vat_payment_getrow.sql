CREATE PROCEDURE dbo.xsp_invoice_vat_payment_getrow
(
	@p_code			nvarchar(50)
) as
begin

	select	ivp.code
            ,ivp.branch_code
            ,ivp.branch_name
            ,ivp.status
            ,ivp.date
            ,ivp.remark
            ,ivp.total_ppn_amount
			,ivp.currency_code
			,ivp.tax_bank_name
			,ivp.tax_bank_account_name
			,ivp.tax_bank_account_no
	from	invoice_vat_payment ivp
	where	ivp.code	= @p_code
end
