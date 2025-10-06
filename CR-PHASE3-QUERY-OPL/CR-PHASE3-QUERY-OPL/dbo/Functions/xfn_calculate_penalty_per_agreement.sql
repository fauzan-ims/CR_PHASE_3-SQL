CREATE FUNCTION dbo.xfn_calculate_penalty_per_agreement
(
	@p_agreement_no nvarchar(50)
	,@p_system_date datetime
	,@p_invoice_no	nvarchar(50)
	,@p_asset_no	nvarchar(50)
)
returns decimal(18, 2)
as
begin
	declare @billing_amount			 decimal(18, 2)
			,@duedate				 datetime
			,@total_days			 int
			,@charges_pct			 decimal(9, 6)
			,@charges_amount		 decimal(18, 2)
			,@default_flag			 nvarchar(20)
			,@billing_to_faktur_type nvarchar(3)
			,@total_charges			 decimal(18, 2) = 0
			,@date					 datetime
			,@id_payment			 int
			,@graceperiod			 int
			,@total_installment		 decimal(18, 2)
			,@installment_payment	 decimal(18, 2)
			,@payment_date_first	 datetime
			,@date_before			 datetime ;

	if @p_agreement_no is not null
	   and	@p_system_date is not null
	   and	@p_invoice_no is not null
	begin

		--masa tenggang
		select	@graceperiod = isnull(value, 0)
		from	dbo.sys_global_param with (nolock)
		where	code = 'GCP' ;

		select top 1
				@charges_pct		= ac.charges_rate / 100
				,@charges_amount	= ac.charges_amount
				,@default_flag		= ac.calculate_by
		from	agreement_charges ac with (nolock)
		where	ac.agreement_no		= @p_agreement_no
				and ac.charges_code = 'OVDP' ;

		select	@duedate = aiv.invoice_due_date
				,@billing_to_faktur_type = aiv.billing_to_faktur_type
		from	dbo.invoice aiv with (nolock)
		where	aiv.invoice_no = @p_invoice_no ; 

		select	@total_installment = sum(aid.billing_amount - isnull(cnd.adjustment_amount, 0) - aid.discount_amount) --case when @billing_to_faktur_type = '01' then sum(aid.billing_amount - aid.discount_amount + aid.ppn_amount) else sum(aid.billing_amount - aid.discount_amount) end
		from	dbo.invoice_detail aid  with (nolock)
				left join dbo.credit_note cn with (nolock) ON  (cn.invoice_no = aid.invoice_no and cn.status = 'POST')
				left join dbo.credit_note_detail cnd with (nolock) on (cnd.credit_note_code = cn.code and cnd.invoice_detail_id = aid.id)
		where	aid.agreement_no   = @p_agreement_no
				and aid.asset_no   = @p_asset_no
				and aid.invoice_no = @p_invoice_no ;

		if @default_flag is not null
		begin
			set @charges_pct = isnull(@charges_pct, 0) ;
			set @charges_amount = isnull(@charges_amount, 0) ;

			--tidak ada partial payment
			--if exists
			--(
			--	select	1
			--	from	dbo.agreement_invoice_payment with (nolock)
			--	where	agreement_no				 = @p_agreement_no
			--			and invoice_no				 = @p_invoice_no
			--			and asset_no				 = @p_asset_no
			--			and cast(payment_date as date) <= cast(@p_system_date as date)
			--)
			--begin
			--	select	@payment_date_first = min(payment_date)
			--	from	dbo.agreement_invoice_payment with (nolock)
			--	where	agreement_no   = @p_agreement_no
			--			and asset_no   = @p_asset_no
			--			and invoice_no = @p_invoice_no ;

			--	set @total_days = dbo.xfn_calculate_overdue_days_for_penalty(@duedate, @payment_date_first) ;
			--	set @total_days = isnull(@total_days, 0) ;

			--	if (@total_days - @graceperiod) > 0 -- jika total days kurang dari 0 tidak hitung denda
			--	begin
			--		if @default_flag = 'PCT'
			--			set @total_charges += @total_installment * @total_days * (@charges_pct / 100) ;
			--		else if @default_flag = 'AMOUNT'
			--			set @total_charges += @total_days * @charges_amount ;
			--	end ;

			--	declare c_payment cursor local fast_forward read_only for
			--	select		cast(payment_date as date)
			--				,sum(payment_amount)
			--	from		dbo.agreement_invoice_payment with (nolock)
			--	where		agreement_no				 = @p_agreement_no
			--				and asset_no				 = @p_asset_no
			--				and invoice_no				 = @p_invoice_no
			--				and cast(payment_date as date) <= cast(@p_system_date as date)
			--	group by	cast(payment_date as date) ;

			--	open c_payment ;

			--	fetch c_payment
			--	into @date
			--		 ,@installment_payment ;

			--	while @@fetch_status = 0
			--	begin 
			--		set @total_days = dbo.xfn_calculate_overdue_days_for_penalty(@date_before, @date) ;
			--		set @total_days = isnull(@total_days, 0) ;

			--		if @total_days - @graceperiod > 0 -- jika total days kurang dari 0 tidak hitung denda
			--		begin
			--			if @default_flag = 'PCT'
			--				set @total_charges += @total_installment * @total_days * (@charges_pct / 100) ;
			--			else if @default_flag = 'AMOUNT'
			--				set @total_charges += @total_days * @charges_amount ;
			--		end ;

			--		set @total_installment = @total_installment - @installment_payment ;
			--		set @date_before = @date ;

			--		fetch c_payment
			--		into @date
			--			 ,@installment_payment ;
			--	end ;

			--	close c_payment ;
			--	deallocate c_payment ;

			--	if (cast(@date_before as date) <> cast(@p_system_date as date))
			--	begin
			--		set @total_days = dbo.xfn_calculate_overdue_days_for_penalty(@date_before, @p_system_date) ;
			--		set @total_days = isnull(@total_days, 0) ;

			--		if (@total_days - @graceperiod) > 0 -- jika total days kurang dari 0 tidak hitung denda
			--		begin
			--			if @default_flag = 'PCT'
			--				set @total_charges += @total_installment * @total_days * (@charges_pct / 100) ;
			--			else if @default_flag = 'AMOUNT'
			--				set @total_charges += @total_days * @charges_amount ;
			--		end ;
			--	end ;
			--end ;
			--else
			begin
				set @total_days = dbo.xfn_calculate_overdue_days_for_penalty(@duedate, @p_system_date) ;
				set @total_days = isnull(@total_days, 0) ;

				if (@total_days - @graceperiod) > 0 -- jika total days kurang dari 0 tidak hitung denda
				begin
					if @default_flag = 'PCT'
						set @total_charges = @total_installment * @total_days * @charges_pct ;
					else if @default_flag = 'AMOUNT'
						set @total_charges = @total_days * @charges_amount ;
				end ;
			end ; 
		end ;
	end ;

	return round(@total_charges, 0) ;
end ;



