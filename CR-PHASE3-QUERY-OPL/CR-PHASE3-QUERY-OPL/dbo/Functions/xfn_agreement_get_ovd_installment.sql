
CREATE function dbo.xfn_agreement_get_ovd_installment
(
	@p_agreement_no nvarchar(50)
	,@p_date		datetime
)
returns decimal(18, 2)
as
begin
	--(+) Rinda 11/01/202111:06:29 notes :	
	declare @ovd_installment	   decimal(18, 2)
			,@agreement_sub_status nvarchar(20) ;

	select	@agreement_sub_status = agreement_sub_status
	from	dbo.agreement_main
	where	agreement_no = @p_agreement_no ;

	select	@ovd_installment = sum(isnull(aa.installment_amount, 0) - isnull(aap.payment_amount, 0))
	from	dbo.agreement_amortization aa with (nolock)
			outer apply
	(
		select	sum(aap.payment_amount) as 'payment_amount'
		from	dbo.agreement_amortization_payment aap with (nolock)
		where	(
					aap.agreement_no = aa.agreement_no
					and aap.installment_no = aa.installment_no
					and cast(aap.payment_date as date) <= cast(@p_date as date)
				)
	) aap
	where	aa.agreement_no												= @p_agreement_no
			and (aa.installment_amount - isnull(aap.payment_amount, 0)) > 0
			and cast(aa.due_date as date)								<= cast(@p_date as date) ;

	return isnull(@ovd_installment, 0) ;
end ;
