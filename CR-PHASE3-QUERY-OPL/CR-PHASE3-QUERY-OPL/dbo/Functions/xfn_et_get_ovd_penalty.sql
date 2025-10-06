CREATE FUNCTION dbo.xfn_et_get_ovd_penalty
(
	@p_reff_no		 nvarchar(50)
	,@p_agreement_no nvarchar(50)
	,@p_date		 datetime
)
returns decimal(18, 2)
as
begin
	--(+) Rinda 11/01/202111:06:29 notes :	
	declare @ovd_penalty		 decimal(18, 2)
			,@obligation_payment decimal(18, 2)
			,@amount_calculate	 decimal(18, 2) = 0
			,@amount_obligation	 decimal(18, 2)
			,@invoice_no		 nvarchar(50)
			,@asset_no			 nvarchar(50) ;

	declare curr_install cursor local fast_forward read_only for
	select		invoice_no
				,asset_no
	from		dbo.agreement_asset_amortization with (nolock)
	where		agreement_no			   = @p_agreement_no
				and asset_no in
					(
						select	asset_no
						from	dbo.et_detail with (nolock)
						where	et_code			 = @p_reff_no
								and is_terminate = '1'
					)
				and cast(due_date as date) < cast(@p_date as date)
				and billing_no			   <> 0
	order by	billing_no desc ;

	open curr_install ;

	fetch curr_install
	into @invoice_no
		 ,@asset_no ;

	while @@fetch_status = 0
	begin
		set @amount_calculate = @amount_calculate + isnull(dbo.xfn_calculate_penalty_per_agreement(@p_agreement_no, @p_date, @invoice_no, @asset_no), 0) ;

		fetch curr_install
		into @invoice_no
			 ,@asset_no ;
	end ;

	close curr_install ;
	deallocate curr_install ;

	select	@obligation_payment = isnull(sum(aop.payment_amount), 0)
	from	agreement_obligation_payment aop with (nolock)
			left join agreement_obligation ao on (aop.obligation_code = ao.code)
	where	aop.agreement_no	   = @p_agreement_no
			and aop.asset_no in
				(
					select	asset_no
					from	dbo.et_detail with (nolock)
					where	et_code			 = @p_reff_no
							and is_terminate = '1'
				)
			and ao.obligation_type = 'OVDP' ;

	set @ovd_penalty = isnull(@amount_calculate, 0) - @obligation_payment ;

	return isnull(@ovd_penalty, 0) ;
end ;
