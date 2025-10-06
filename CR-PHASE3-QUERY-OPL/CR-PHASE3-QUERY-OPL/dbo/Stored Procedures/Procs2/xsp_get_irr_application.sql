create PROCEDURE [dbo].[xsp_get_irr_application]
(
	@p_application_no  nvarchar(50)
	--,@irr_return	   decimal(18, 8) output
	--
	,@p_mod_by		   nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @pvprev					   float
			,@residual_value		   numeric(18, 2)
			,@rv_type				   nvarchar(50)
			,@irr_return			   decimal(18, 8)
			,@total_interest		   decimal(18, 2)
			,@rate_flat_after_rounding decimal(18, 15)
			,@tenor					   decimal(3, 0)
			,@eff_rate				   decimal(9, 6)
			,@interest_type			   nvarchar(10)
			,@flat_rate				   decimal(9, 6)
			,@ndimuka				   numeric(1)	  = 0
			,@first_principal		   numeric(18, 2)
			,@first_payment_schedule   nvarchar(10)
			,@installment_amount	   numeric(18, 2)
			,@payment_schedule		   nvarchar(10)
			,@schedule_month		   int ;

	select top 1
			@residual_value = isnull(aatc.residual_value_amount, 0)
			,@rv_type = aatc.residual_value_type
			,@tenor = aatc.tenor
			,@first_payment_schedule = first_payment_type
			,@installment_amount = aa.installment_amount
			,@first_principal = am.financing_amount
			,@payment_schedule = aatc.payment_schedule_type_code
			,@eff_rate = aatc.interest_eff_rate
			,@interest_type = aatc.interest_rate_type
			,@flat_rate = aatc.interest_flat_rate 
	from	dbo.application_tc aatc
			inner join dbo.application_amortization aa on (aatc.application_no = aa.application_no)
			inner join dbo.application_main am on (aatc.application_no		   = am.application_no)
	where	aatc.application_no = @p_application_no
			and installment_no	= '1' ;

	select	@schedule_month = multiplier
	from	dbo.master_payment_schedule
	where	code = @payment_schedule ;

	if (@payment_schedule = 'day')
		set @schedule_month = 360.0 ;
	else if (@payment_schedule = 'wky')
		set @schedule_month = 52.0 ;

	set @pvPrev = @first_principal ;

	if (@rv_type = 'NOTIONAL')
		set @residual_value = 0 ;

	if @first_payment_schedule = 'ADV'
	begin
		select	@pvPrev = @first_principal - @residual_value - @installment_amount ;

		select	@ndimuka = 1 ;
	end ;
	else
	begin
		set @pvprev = @first_principal - @residual_value ;
	end ;

	select		installment_amount
				,os_principal_amount
				,installment_no
	into		#ls_appliamor_curr
	from		dbo.application_amortization
	where		application_no	   = @p_application_no
				and installment_no >= @ndimuka
	order by	installment_no ;

	update	#ls_appliamor_curr
	set		installment_amount = @pvprev * -1
	where	installment_no = @ndimuka ;

	select	@irr_return = [dbo].irr(installment_no, installment_amount) * 100.0 / @schedule_month
	from	#ls_appliamor_curr ;

	-- mencari total interest
	select	@total_interest = sum(installment_interest_amount)
	from	application_amortization
	where	application_no = @p_application_no ;

	if (@eff_rate > 0)
	begin
		if @interest_type = 'EFFECTIVE'
		begin
			set @installment_amount = dbo.fn_get_pmt(@eff_rate / 12, @tenor, @first_principal, @residual_value, @ndimuka) * -1 ;
			set @flat_rate = dbo.xfn_get_flat_rate(@installment_amount, @tenor, @first_principal, @total_interest) ;
		end ;
	end ;
	else
	begin
		set @eff_rate = dbo.xfn_get_effective_rate(@tenor, @first_principal, @flat_rate, @ndimuka) ;
	end ;

	set @rate_flat_after_rounding = (@total_interest / @first_principal * 100) / ((@tenor / 12)) ;

	-- mengupdate rate flat dan eff after rounding
	update	dbo.application_tc
	set		interest_flat_rate					= isnull(@flat_rate, 0)
			,interest_eff_rate					= isnull(@eff_rate, 0)
			,interest_flat_rate_after_rounding	= isnull(@rate_flat_after_rounding, 0)
			,interest_eff_rate_after_rounding	= isnull(@irr_return, 0)
			,mod_by								= @p_mod_by
			,mod_date							= @p_mod_date
			,mod_ip_address						= @p_mod_ip_address
	where	application_no						= @p_application_no ;
end ;
