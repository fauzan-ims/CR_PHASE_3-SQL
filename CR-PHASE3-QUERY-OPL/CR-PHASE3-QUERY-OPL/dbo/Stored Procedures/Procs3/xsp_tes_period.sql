CREATE PROCEDURE dbo.xsp_tes_period
(
	@p_asset_no nvarchar(50)
	,@p_billing_no	int
)
as
begin
	declare @msg nvarchar(max) ;

	begin try

		declare @due_date				datetime
				--,@agreement_no			nvarchar(50)
				,@no					int
				--,@tenor					int
				,@schedule_month		int
				,@first_duedate			datetime
				,@billing_date			datetime
				--,@billing_mode			nvarchar(10)
				--,@billing_mode_date		int
				--,@lease_rounded_amount	decimal(18, 2)
				--,@description				nvarchar(4000)
				,@billing_date_schedule datetime
				,@first_payment			nvarchar(50)
				,@period_due_date		datetime
				,@due_date_next			datetime
				,@due_date_before		datetime
				,@period				int
				,@due_date_max_adv		datetime
				,@handover_date			datetime
				,@max_billing_no		int;

        -- mengambil multipier di master payment schedule
		select	@schedule_month = multiplier
				--,@agreement_no = aa.agreement_no
				,@handover_date = aa.handover_bast_date
				--,@lease_rounded_amount = aa.lease_round_amount
				--,@tenor = aa.periode
				,@first_payment = aa.first_payment_type
				,@period = am.periode
				--,@billing_mode_date = aa.billing_mode_date
		from	dbo.master_billing_type mbt with(nolock)
				inner join dbo.agreement_asset aa with(nolock) on (aa.billing_type = mbt.code)
				inner join dbo.agreement_main am with(nolock) on (am.agreement_no  = aa.agreement_no)
		where	aa.asset_no = @p_asset_no ;

		select	@max_billing_no = max(billing_no)
		from	dbo.agreement_asset_amortization
		where	asset_no = @p_asset_no ;

		--begin
		select	@billing_date_schedule = due_date
		from	dbo.agreement_asset_amortization with(nolock)
		where	asset_no	   = @p_asset_no
				and billing_no = @p_billing_no ;

		if @first_payment = 'ARR'
		select	@due_date_before = due_date
		from	dbo.agreement_asset_amortization with(nolock)
		where	asset_no	   = @p_asset_no
				and billing_no = @p_billing_no - 1 
		else
		select	@due_date_before = due_date
		from	dbo.agreement_asset_amortization with(nolock)
		where	asset_no	   = @p_asset_no
				and billing_no = @p_billing_no

		if @due_date_before is null
			set @billing_date_schedule = @billing_date_schedule
		else if @due_date_before <> @billing_date_schedule
			set @billing_date_schedule = @due_date_before
		else
			set @billing_date_schedule = @billing_date_schedule

		set @due_date = @billing_date_schedule;
		--end;
	
		set @no = @p_billing_no - 1 ;
		set @first_duedate = @due_date ;

		if @first_payment = 'ARR' and @p_billing_no = 1
		begin
			set @billing_date = dateadd(month, @schedule_month * -1, @first_duedate) ;
			select @first_duedate,@billing_date,@handover_date,@schedule_month
			if @billing_date <> @handover_date
			begin
				set @first_duedate = @handover_date
			end
			if @billing_date=@handover_date
				set @first_duedate = @handover_date;
		end ;

		set @due_date = dateadd(month, (@schedule_month * 1), @first_duedate) ;
		set @no = @no + 1 ;

		--set @period_due_date = dateadd(month, @schedule_month * 1, @first_duedate) ;
		if @first_payment = 'ARR'
		begin
			select	@due_date_next = due_date
			from	dbo.agreement_asset_amortization with (nolock)
			where	asset_no	   = @p_asset_no
					and billing_no = @no;
		end
		else
		begin
			select	@due_date_next = due_date
			from	dbo.agreement_asset_amortization with (nolock)
			where	asset_no	   = @p_asset_no
					and billing_no = @no+1;
		end;

		if @due_date_next <> @due_date
			set @due_date = isnull(@due_date_next, @due_date) ;
		else
			set @due_date = @due_date ;

		if @max_billing_no = @p_billing_no and @first_payment='ADV'
		begin
			if @handover_date is null
				select	@handover_date = period_date
				from	dbo.xfn_due_date_period(@p_asset_no, 1) ;

			set @due_date_max_adv = dateadd(month, @period, @handover_date) ;
			set @due_date = @due_date_max_adv ;
		end

		select @p_asset_no, @p_billing_no, @first_duedate, @due_date;

	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;
		else if (@error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used() ;
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ; 	
end ;
