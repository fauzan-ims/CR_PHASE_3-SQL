CREATE function [dbo].[xfn_agreement_get_ol_ar]
(
	@p_client_no	 nvarchar(50)
	,@p_date		datetime
)
returns decimal(18, 2)
as
begin

	-- mendapatkan rental yang sudah jatuh tempo da belum dibayar
	declare @os_installment decimal(18, 2)
			,@client_no nvarchar(50);

	select	@os_installment = sum(isnull(aa.ar_amount, 0) - isnull(aap.payment_amount, 0))
	from	dbo.agreement_invoice aa --with (nolock)
			outer apply
			(
				select	sum(aap.payment_amount) as 'payment_amount'
				from	dbo.agreement_invoice_payment aap with (nolock)
				where	(
							aap.agreement_invoice_code = aa.code
						)
			) aap
	inner	join dbo.invoice inv on (inv.invoice_no = aa.invoice_no) -- (+) Ari 2023-11-24 ket : get invoice due date
	where	inv.CLIENT_NO			  = @p_client_no
	and		inv.invoice_due_date < dbo.xfn_get_system_date() -- (+) Ari 2023-11-24 ket : lebih kecil dari invoice due date

	return isnull(@os_installment, 0) ;
end ;
