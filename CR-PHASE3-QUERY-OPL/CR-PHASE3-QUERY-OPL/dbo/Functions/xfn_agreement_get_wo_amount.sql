
CREATE FUNCTION dbo.xfn_agreement_get_wo_amount
(
	@p_agreement_no nvarchar(50)
	,@p_date		datetime
)
returns decimal(18, 2)
as
begin
	-- Hari - 17.Jul.2023 12:15 PM --	mendapatkan nilai ar yang due, invoice payment always full
	declare @os_installment decimal(18, 2) ;

	select	@os_installment = isnull(sum(ar_amount - isnull(payment_amount, 0)),0)
	from	dbo.agreement_invoice  ai
			inner join dbo.invoice inv on ai.invoice_no = inv.invoice_no
			outer apply -- Louis Rabu, 27 Maret 2024 17.11.45 -- menambahkan logic outer apply ke payment karena bisa saja invoice memiliki credit note
			(
				select	isnull(sum(isnull(aip.payment_amount, 0)), 0) payment_amount
				from	dbo.agreement_invoice_payment aip
				where	aip.agreement_invoice_code = ai.code
			) aip
	where	ai.agreement_no					= @p_agreement_no
			and inv.invoice_status			= 'POST'

	return isnull(@os_installment, 0) ;
end ;
