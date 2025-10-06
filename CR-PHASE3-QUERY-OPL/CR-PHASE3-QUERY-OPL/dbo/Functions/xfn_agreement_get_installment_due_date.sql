CREATE function dbo.xfn_agreement_get_installment_due_date
(
	@p_agreement_no nvarchar(50)
)
returns datetime
as
begin
	declare @installment_due_date datetime ;
	
	-- Louis Selasa, 03 Oktober 2023 13.46.09 --	change calculate ovd from invoice table
	select	@installment_due_date = min(iv.invoice_due_date)
	from	dbo.invoice iv
			inner join dbo.invoice_detail id on id.invoice_no = iv.invoice_no
	where	iv.invoice_status	= 'POST'
			and id.agreement_no = @p_agreement_no 
			and iv.invoice_type = 'RENTAL'

	--select	@installment_due_date = min(due_date)
	--from	dbo.agreement_invoice ai
	--		inner join dbo.invoice_detail ivd on (ivd.invoice_no = ai.invoice_no)
	--		inner join dbo.invoice iv on (iv.invoice_no = ivd.invoice_no)
	--		outer apply
	--(
	--	select	payment_date
	--	from	dbo.agreement_invoice_payment aip
	--	where	aip.agreement_no = ai.agreement_no
	--) inv
	--where	iv.invoice_status	<> 'PAID'
	--		and ai.agreement_no = @p_agreement_no ;

	return @installment_due_date ;
end ;
