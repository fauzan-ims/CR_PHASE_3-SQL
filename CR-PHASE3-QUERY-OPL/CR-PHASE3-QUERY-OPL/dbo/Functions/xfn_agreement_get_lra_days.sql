-- Louis Senin, 25 Maret 2024 10.14.07 --
create function [dbo].[xfn_agreement_get_lra_days]
(
	@p_agreement_no nvarchar(50)
)
returns int
as
begin
	declare @lar_days int ;
	 
	select	@lar_days = max(aa.obligation_day)
	from	dbo.agreement_obligation aa
			outer apply
	(
		select	isnull(sum(aap.payment_amount), 0) 'payment_amount'
		from	dbo.agreement_obligation_payment aap
		where	aap.obligation_code = aa.code
	) parsial
	where	aa.agreement_no		   = @p_agreement_no 
			and aa.obligation_type = 'LRAP' 
	having sum(aa.obligation_amount - parsial.payment_amount) > 0

	return isnull(@lar_days, 0) ;
end ;
