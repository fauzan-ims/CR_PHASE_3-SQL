
CREATE function dbo.xfn_agreement_get_doubful_allowance
(
	@p_agreement_no nvarchar(50)
	,@p_date		datetime
)
returns decimal(18, 2)
as
begin
	--- untuk mendapatkan nilai WO
	-- factoring murni fund in used selain itu dari amortization (principal)
	declare @os_principal		   decimal(18, 2)
			,@factoring_type	   nvarchar(10)
			,@agreement_sub_status nvarchar(20) ;

	select	@agreement_sub_status = agreement_sub_status
			--,@factoring_type = factoring_type
	from	dbo.agreement_main
	where	agreement_no = @p_agreement_no ;

	if (@agreement_sub_status = 'WO ACC')
	begin
		select	@os_principal = wo_amount - wo_recovery_amount
		from	dbo.agreement_wo_ledger_main
		where	agreement_no = @p_agreement_no ;
	end ;
	--else
	--begin
	--	if @factoring_type = 'STANDARD' -- factoring murni
	--	begin
	--		select	@os_principal = sum(aa.charges_amount)
	--		from	dbo.agreement_fund_in_used_main aa with (nolock)
	--		where	aa.agreement_no = @p_agreement_no ;
	--	end ;
	--	else -- factoring by invoice dan consumer
	--	begin
	--		select	@os_principal = sum(isnull(aa.installment_principal_amount, 0) - isnull(aap.principal_amount, 0))
	--		from	dbo.agreement_amortization aa with (nolock)
	--				left join dbo.agreement_amortization_payment aap with (nolock) on (
	--																					  aap.agreement_no		  = aa.agreement_no
	--																					  and  aap.installment_no = aa.installment_no
	--																				  )
	--		where	aa.agreement_no		  = @p_agreement_no
	--				and aa.installment_no <> 0 ;
	--	end ;
	--end ;

	return isnull(@os_principal, 0) ;
end ;
