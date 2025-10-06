
CREATE FUNCTION dbo.xfn_agreement_get_ol_pph
(
	@p_agreement_no nvarchar(50)
	,@p_date		datetime
)
returns decimal(18, 2)
as
begin

	-- mendapatkan pph yang belum dibayar
	declare @os_installment decimal(18, 2) ;

	select	@os_installment = sum(isnull(aa.pph_amount, 0) - isnull(aap.payment_amount, 0))
	from	dbo.agreement_invoice_pph aa with (nolock)
			outer apply
	(
		select	sum(aap.payment_amount) as 'payment_amount'
		from	dbo.agreement_invoice_pph_settlement aap with (nolock)
		where	(
					aap.agreement_invoice_pph_code = aa.code
				)
	) aap
	where	aa.agreement_no				  = @p_agreement_no

	return isnull(@os_installment, 0) ;
end ;
