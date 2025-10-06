CREATE FUNCTION dbo.xfn_get_interim_rental_by_asset
(
	@p_asset_no nvarchar(50)
	, @p_date	datetime
)
returns decimal(18, 2)
as
begin
	-- mengambil nilai pokok hutang yang belum dibayar
	declare @propotional_days		decimal(18, 2)
			, @total_days			decimal(18, 2)
			, @due_date				datetime
			, @total_billing_amount decimal(18, 2) = 0
			, @billing_amount		decimal(18, 2) = 0
			, @interim_rental		decimal(18, 0) -- sepria 16nov23: ini diganti jadi 18,0 supaya auto round jika ada nilai dibelakang koma.
			, @next_duedate			datetime 
			, @billing_no			int
			, @billing_no_max			int

	select @billing_no_max = max(BILLING_NO)
	from	dbo.agreement_asset_amortization with (nolock)
	where	asset_no = @p_asset_no ;

	select top 1 
			@billing_no = BILLING_NO
	from	dbo.agreement_asset_amortization with (nolock)
	where	asset_no = @p_asset_no
	and		billing_date	>= @p_date 
	order by BILLING_NO asc

	select	@total_billing_amount = isnull(sum(isnull(billing_amount, 0)), 0)
	from	dbo.agreement_asset_amortization aaa with (nolock)
			left join invoice inv with (nolock) on inv.invoice_no = aaa.invoice_no
									 and   inv.invoice_status not in
															(
																'NEW', 'CANCEL'
															)
	where	asset_no		 = @p_asset_no
			and inv.invoice_no is null
			and billing_date <= @p_date ;

	if (@p_date <
		(
			select	billing_date
			from	dbo.agreement_asset_amortization with (nolock)
			where	asset_no = @p_asset_no
			and		billing_no	= 1
		)
	)
	begin
		select	@due_date = handover_bast_date
				--,@billing_amount = aa.LEASE_ROUNDED_AMOUNT
		from	dbo.agreement_asset_amortization aaa with (nolock)
				inner join dbo.agreement_asset aa with (nolock) on (aa.asset_no = aaa.asset_no)
		where aaa.asset_no = @p_asset_no

		-- mengambil data next duedate dan next billing amount
		select	top 1
				@next_duedate = due_date
				,@billing_amount	= aaa.billing_amount -- (sepria 30032025: ambil billing amount dalam periode berjalan)
		from	dbo.agreement_asset_amortization aaa with (nolock)
				left join invoice inv with (nolock) on inv.invoice_no = aaa.invoice_no
									and		inv.invoice_status not in ('NEW', 'CANCEL')
		where	asset_no	= @p_asset_no
		and		billing_date	>= @p_date
		order by billing_no asc;

		-- mengambil total days dari duedate ke tgl next duedate
		--select	@total_days = day(@next_duedate)
		select	@total_days = datediff(day, @due_date,@next_duedate)-- (sepria 30032025: ambil jumlah hari ke next duedate dalam periode berjalan)
	end
	else if @billing_no = @billing_no_max
	begin
		--select	@billing_amount = aa.LEASE_ROUNDED_AMOUNT
		--from	dbo.agreement_asset_amortization aaa
		--		inner join dbo.agreement_asset aa on (aa.asset_no = aaa.asset_no)
		--where aaa.asset_no = @p_asset_no

		-- duedate sebelum tgl jatuh tempo
		select	top 1
				@due_date			= due_date
		from	dbo.agreement_asset_amortization aaa with (nolock)
				left join invoice inv with (nolock) on inv.invoice_no = aaa.invoice_no
									and		inv.invoice_status not in ('NEW', 'CANCEL')
		where	asset_no	= @p_asset_no
		and		billing_date	<= @p_date
		order by billing_no desc;

		-- mengambil data next duedate dan next billing amount
		select	top 1
				@next_duedate = due_date
				,@billing_amount	= aaa.billing_amount -- (sepria 30032025: ambil billing amount dalam periode berjalan)
		from	dbo.agreement_asset_amortization aaa with (nolock)
				left join invoice inv with (nolock) on inv.invoice_no = aaa.invoice_no
									and		inv.invoice_status not in ('NEW', 'CANCEL')
		where	asset_no	= @p_asset_no
		and		billing_date	>= @p_date
		order by billing_no asc;

		-- mengambil total days dari duedate ke tgl next duedate
		--select	@total_days = day(eomonth(@next_duedate))
		select	@total_days = datediff(day, @due_date,@next_duedate)-- (sepria 30032025: ambil jumlah hari ke next duedate dalam periode berjalan)
	end
	else
	begin
		-- duedate sebelum tgl jatuh tempo
		select	top 1
				@due_date = due_date
				--,@billing_amount = aaa.billing_amount
		from	dbo.agreement_asset_amortization aaa with (nolock)
				left join invoice inv with (nolock) on inv.invoice_no = aaa.invoice_no
									and		inv.invoice_status not in ('NEW', 'CANCEL')
		where	asset_no	= @p_asset_no
		and		billing_date	<= @p_date
		order by billing_no desc;

		-- mengambil data next duedate dan next billing amount
		select	top 1
				@next_duedate = due_date
				,@billing_amount = aaa.billing_amount
		from	dbo.agreement_asset_amortization aaa with (nolock)
				left join invoice inv with (nolock) on inv.invoice_no = aaa.invoice_no
									and		inv.invoice_status not in ('NEW', 'CANCEL')
		where	asset_no	= @p_asset_no
		and		billing_date	>= @p_date
		order by billing_no asc;

		-- mengambil total days dari duedate ke tgl next duedate
		select	@total_days = datediff(day, @due_date,@next_duedate)

	end;

	set @propotional_days = datediff(day, @due_date, @p_date) ;

	if (@propotional_days > 0)
	BEGIN
		-- mengambil total days dari duedate ke tgl next duedate
		--select	@total_days = datediff(day, @due_date,@next_duedate)

		set @interim_rental = dbo.fn_get_floor(@total_billing_amount + (((@propotional_days+1.00) / @total_days) * @billing_amount), 1) ;
	end ;
	else
	begin
		set @interim_rental = @total_billing_amount ;
	end ;

	--if (@p_date <
	--	(
	--		select	billing_date
	--		from	dbo.agreement_asset_amortization
	--		where	asset_no = @p_asset_no
	--		and		billing_no	= 1
	--	)
	--)
	--begin
	--	--select	@due_date = handover_bast_date
	--	--		,@billing_amount = aaa.billing_amount
	--	--from	dbo.agreement_asset_amortization aaa
	--	--		inner join dbo.agreement_asset aa on (aa.asset_no = aaa.asset_no)
	--	--where aaa.asset_no = @p_asset_no and aaa.billing_no = 1
	--	select	@due_date = handover_bast_date
	--			,@billing_amount = aa.LEASE_ROUNDED_AMOUNT
	--	from	dbo.agreement_asset_amortization aaa
	--			inner join dbo.agreement_asset aa on (aa.asset_no = aaa.asset_no)
	--	where aaa.asset_no = @p_asset_no
	--end;
	--else
	--begin
	--	select	top 1
	--			@due_date = due_date
	--			,@billing_amount = aaa.billing_amount
	--	from	dbo.agreement_asset_amortization aaa
	--			left join invoice inv on inv.invoice_no = aaa.invoice_no
	--								and		inv.invoice_status not in ('NEW', 'CANCEL')
	--	where	asset_no	= @p_asset_no
	--	--and inv.invoice_no is null
	--	and		billing_date	<= @p_date
	--	order by billing_no desc;
	--end;

	--set @propotional_days = datediff(day, @due_date, @p_date) ;

	--if (@propotional_days > 0)
	--begin
	--	--select	@total_days = (bt.multiplier * day(eomonth(@p_date)))
	--	select	@total_days = datediff(day, @due_date, dateadd(month, bt.multiplier, @due_date))

	--	from	dbo.master_billing_type		   bt
	--			inner join dbo.agreement_main  am on am.billing_type = bt.code
	--			inner join dbo.agreement_asset aa on aa.agreement_no = am.agreement_no
	--	where	aa.asset_no = @p_asset_no ;

	--	set @interim_rental = dbo.fn_get_floor(@total_billing_amount + ((@propotional_days / @total_days) * @billing_amount), 1) ;
	--end ;
	--else
	--begin
	--	set @interim_rental = @total_billing_amount ;
	--end ;

	return isnull(@interim_rental, 0) ;
end ;
