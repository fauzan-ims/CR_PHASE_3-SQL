CREATE FUNCTION dbo.xfn_et_get_os_principal_new
(
	@p_reff_no		 nvarchar(50)
	,@p_agreement_no nvarchar(50)
	,@p_date		 datetime
)
returns decimal(18, 2)
as
begin
	-- mengambil nilai pokok hutang yang belum dibayar
	declare @os_principal	 decimal(18, 2)
			,@residual_value decimal(18, 2) = 0 
			--
			,@billing_amount			decimal(18, 2)
			,@os_principal_days			decimal(18, 2)
			,@propotional_days			decimal(18, 2)
			,@total_days				decimal(18, 2)
			,@duedate					datetime
			,@duedate_before			datetime
			,@total_asset				int

	select top 1 
			@duedate = aa.DUE_DATE 
	from dbo.AGREEMENT_ASSET_AMORTIZATION aa with (nolock)
	where	aa.agreement_no				  = @p_agreement_no
	and		isnull(aa.invoice_no, '') = ''
			and aa.asset_no in
				(
					select	asset_no
					from	dbo.et_detail with (nolock)
					where	et_code			 = @p_reff_no
							and is_terminate = '1'
				)
			and cast(aa.due_date as date) >= cast(@p_date as date) 
	order by aa.BILLING_NO asc

	select	top 1
			@duedate_before = aa.DUE_DATE
			,@billing_amount = aa.BILLING_AMOUNT
	from	dbo.agreement_asset_amortization aa with (nolock)
	where	aa.agreement_no				  = @p_agreement_no
	--and		isnull(aa.invoice_no, '') = ''
			and aa.asset_no in
				(
					select	asset_no
					from	dbo.et_detail with (nolock)
					where	et_code			 = @p_reff_no
							and is_terminate = '1'
				)
			and cast(aa.due_date as date) < cast(@p_date as date) 
	order by aa.BILLING_NO desc

	set @propotional_days = datediff(day, @p_date, @duedate)
	if isnull(@propotional_days,0) > 0
	begin
		set @p_date = dateadd(day,@propotional_days,@p_date)
		set @total_days = datediff(day,@duedate_before,@p_date)
		set @os_principal_days = dbo.fn_get_floor(((@propotional_days / @total_days) * @billing_amount),1)
	end

	select distinct
			@total_asset = count(ed.ASSET_NO)
	from dbo.ET_MAIN em with (nolock)
	INNER JOIN dbo.ET_DETAIL ed on ed.ET_CODE = em.CODE
	where em.AGREEMENT_NO = @p_agreement_no

	select	@os_principal = sum(isnull(aa.billing_amount, 0) ) 
	from	dbo.agreement_asset_amortization aa with (nolock)
	where	aa.agreement_no				  = @p_agreement_no
	and		isnull(aa.invoice_no, '') = ''
			and aa.asset_no in
				(
					select	asset_no
					from	dbo.et_detail with (nolock)
					where	et_code			 = @p_reff_no
							and is_terminate = '1'
				)
			and cast(aa.due_date as date) > cast(@p_date as date) ;

	set @os_principal_days = @os_principal_days * @total_asset

	set @os_principal = isnull(@os_principal, 0) + isnull(@os_principal_days,0)
 
	---- Hari - 14.Jul.2023 05:31 PM --	perhitunfan penalty dari nilai yang belum di buat invoice nya
	--select	@os_principal = sum(isnull(aa.billing_amount, 0) ) 
	--from	dbo.agreement_asset_amortization aa with (nolock)
	----left join invoice inv on inv.invoice_no = aa.invoice_no   and inv.invoice_status  not in ('NEW','CANCEL')
	--where	aa.agreement_no				  = @p_agreement_no
	--and		isnull(aa.invoice_no, '') = ''
	--		and aa.asset_no in
	--			(
	--				select	asset_no
	--				from	dbo.et_detail
	--				where	et_code			 = @p_reff_no
	--						and is_terminate = '1'
	--			)
	--		and cast(aa.due_date as date) > cast(@p_date as date) ;

	--set @os_principal = isnull(@os_principal, 0) ;

	return @os_principal ;
end ;


