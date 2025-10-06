create function [dbo].[xfn_client_get_ovd_days]
(
	@p_client_no nvarchar(50)
)
returns int
as
begin
	declare @ovd_days int ;

	-- hari - 25.sep.2023 09:21 am --	change calculate ovd from invoice table
	select	@ovd_days = datediff(day, min(iv.invoice_due_date), dbo.xfn_get_system_date())
	from	dbo.invoice iv
			inner join dbo.invoice_detail id on id.invoice_no = iv.invoice_no
	where	iv.invoice_status	= 'POST'
			and id.agreement_no = @p_client_no ;

	--select	@ovd_days = datediff(day, min(due_date), dbo.xfn_get_system_date())
	--from	dbo.agreement_invoice ai
	--		outer apply
	--(
	--	select	payment_date
	--	from	dbo.agreement_invoice_payment aip
	--	where	aip.agreement_invoice_code = ai.code
	--) aip
	--where	aip.payment_date is null
	--		and ai.agreement_no = @p_agreement_no ;
	return isnull(@ovd_days, 0) ;
end ;
