CREATE FUNCTION dbo.xfn_agreement_get_invoice_amount
(
	@p_agreement_no nvarchar(50)
	,@p_date		datetime
)
returns decimal(18, 2)
as
begin

	-- mendapatkan angsuran - pph
	declare @ar_amount decimal(18, 2)
			,@pph	   decimal(18, 2) ;

	select	@ar_amount = dbo.xfn_agreement_get_invoice_ar_amount(@p_agreement_no, @p_date) ;

	select	@pph = dbo.xfn_agreement_get_ol_pph(@p_agreement_no, @p_date) ;

	return isnull(@ar_amount - @pph, 0) ;
end ;
