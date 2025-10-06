
-- Louis Senin, 25 Maret 2024 10.14.07 --
create function [dbo].[xfn_agreement_get_lra_penalty_amount]
(
	@p_agreement_no nvarchar(50)
)
returns decimal(18, 2)
as
begin
	declare @lar_penalty_amount decimal(18, 2) ;

	select	@lar_penalty_amount = sum(aa.obligation_amount - parsial.payment_amount)
	from	dbo.agreement_obligation aa
			outer apply
	(
		select	isnull(sum(aap.payment_amount), 0) 'payment_amount'
		from	dbo.agreement_obligation_payment aap
		where	aap.obligation_code = aa.code
	) parsial
	where	aa.agreement_no		   = @p_agreement_no
			and aa.obligation_amount > isnull(parsial.payment_amount, 0)
			and aa.obligation_type = 'LRAP' ;

	return isnull(@lar_penalty_amount, 0) ;
end ;
