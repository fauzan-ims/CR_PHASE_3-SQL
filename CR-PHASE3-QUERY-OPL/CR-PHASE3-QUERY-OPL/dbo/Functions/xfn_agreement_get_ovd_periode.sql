CREATE function dbo.xfn_agreement_get_ovd_periode
(
	@p_agreement_no nvarchar(50)
)
returns int
as
begin
	declare @ovd_periode int ;

	-- hari - 25.sep.2023 09:21 am --	change calculate ovd from invoice table
	select @ovd_periode = count(distinct id.billing_no) from dbo.invoice iv 
	inner join dbo.invoice_detail id on id.invoice_no = iv.invoice_no
	where	iv.invoice_status = 'POST'
			and id.agreement_no = @p_agreement_no ;

	----select	@ovd_periode = count(distinct ai.billing_no)
	----from	dbo.agreement_invoice ai
	----		outer apply
	----(
	----	select	payment_date
	----	from	dbo.agreement_invoice_payment aip
	----	where	aip.agreement_no   = ai.agreement_no
	----			and aip.invoice_no = ai.invoice_no
	----			and aip.asset_no   = ai.asset_no
	----) aip
	----where	ai.due_date			< dbo.xfn_get_system_date()
	----		and aip.payment_date is null
	----		and ai.agreement_no = @p_agreement_no ;

	return isnull(@ovd_periode, 0) ;
end ;

