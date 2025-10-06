CREATE function dbo.xfn_agreement_get_ovd_rental_amount
(
	@p_agreement_no nvarchar(50)
	,@p_asset_no	nvarchar(50) = null
)
returns decimal(18, 2)
as
begin
	declare @ovd_rental_amount decimal(18, 2) ;

	-- Louis Selasa, 03 Oktober 2023 13.46.09 --	change calculate ovd from invoice table
	select	@ovd_rental_amount = sum(id.billing_amount)
	from	dbo.invoice iv
			inner join dbo.invoice_detail id on id.invoice_no = iv.invoice_no
	where	iv.invoice_due_date	  < dbo.xfn_get_system_date()
			and iv.invoice_status = 'POST'
			and id.agreement_no	  = @p_agreement_no
			and iv.invoice_type	  = 'RENTAL' ;

	--select	@ovd_rental_amount = sum(ai.ar_amount)
	--from	dbo.agreement_invoice ai
	--		outer apply
	--(
	--	select	payment_date
	--	from	dbo.agreement_invoice_payment aip
	--	where	aip.agreement_invoice_code = ai.code
	--) aip
	--where	ai.due_date			< dbo.xfn_get_system_date()
	--		and aip.payment_date is null
	--		and ai.agreement_no = @p_agreement_no
	--		and ai.asset_no		= isnull(@p_asset_no, ai.asset_no) ;
	return isnull(@ovd_rental_amount, 0) ;
end ;

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xfn_agreement_get_ovd_rental_amount] TO [lina]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xfn_agreement_get_ovd_rental_amount] TO [DSF\LINA TISNATA]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xfn_agreement_get_ovd_rental_amount] TO [dsf_lina]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xfn_agreement_get_ovd_rental_amount] TO [aryo.budi]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xfn_agreement_get_ovd_rental_amount] TO [eddy.rakhman]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xfn_agreement_get_ovd_rental_amount] TO [bsi-miki.maulana]
    AS [dbo];

