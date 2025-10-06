CREATE PROCEDURE [dbo].[xsp_application_fee_amortization_generate]
(
	@p_application_no  nvarchar(50)
	,@p_fee_code	   nvarchar(50)
	,@p_fee_amount	   decimal(18, 2)
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
)
as
begin
	set nocount on ;

	declare @installment_no		   int
			,@due_date			   datetime
			,@installment_interest decimal(18, 2)
			,@tenor				   int
			,@schedule_month	   int
			,@fee_name			   nvarchar(250)
			,@metode_calculate	   nvarchar(50) ;
			
	select	@metode_calculate = value
	from	dbo.sys_global_param
	where	code = 'MTPE' ;

	-- mencari faktor pengali berdasarkan payment schedule dan interest rate
	select	@schedule_month			= sps.multiplier
			,@tenor = aatc.tenor
	from	application_tc aatc with (nolock)
			inner join dbo.master_payment_schedule sps with (nolock) on (aatc.payment_schedule_type_code = sps.code)
	where	aatc.application_no		= @p_application_no ;

	delete dbo.application_fee_amortization
		where	application_no = @p_application_no
				and fee_code   = @p_fee_code ;
		select	@fee_name = description
		from	dbo.master_fee
		where	code = @p_fee_code ;

	declare @total_installment_interest decimal(18, 2)
			,@amort_amount				decimal(18, 2) ;

	-- mencari total interest
	--index ok
	select	@total_installment_interest = sum(installment_interest_amount)
	from	dbo.application_amortization with (nolock)
	where	application_no = @p_application_no ;

	declare c_amort_table cursor read_only for
	select		installment_no
				,due_date
				,installment_interest_amount
	from		dbo.application_amortization with (nolock)
	where		application_no = @p_application_no
				and installment_no > 0
	order by	installment_no ;

	open c_amort_table ;

	fetch c_amort_table
	into @installment_no
		 ,@due_date
		 ,@installment_interest ;

	while @@fetch_status = 0
	begin
		
		if (@metode_calculate = 'SCHEDULE' )
		begin
			if (@total_installment_interest <> 0)
			begin
				set @amort_amount = @installment_interest / @total_installment_interest * @p_fee_amount ;
			end ;
			else
			begin
				set @amort_amount = 0;
			end ;
		end
		else
		begin
			set @amort_amount = @p_fee_amount / (@tenor / @schedule_month) ;
		end ;

		exec dbo.xsp_application_fee_amortization_insert @p_application_no		= @p_application_no
														 ,@p_installment_no		= @installment_no
														 ,@p_fee_code			= @p_fee_code
														 ,@p_fee_name			= @fee_name
														 ,@p_amort_due_date		= @due_date
														 ,@p_amort_amount		= @amort_amount
														 ,@p_cre_date			= @p_cre_date
														 ,@p_cre_by				= @p_cre_by
														 ,@p_cre_ip_address		= @p_cre_ip_address
														 ,@p_mod_date			= @p_cre_date
														 ,@p_mod_by				= @p_cre_by
														 ,@p_mod_ip_address		= @p_cre_ip_address ;

		fetch c_amort_table
		into @installment_no
			 ,@due_date
			 ,@installment_interest ;
	end ;

	close c_amort_table ;
	deallocate c_amort_table ;

	-- last checking
	declare @total_amount_psak decimal(18, 2) ;

	select	@total_amount_psak = sum(amortization_amount)
	from	dbo.application_fee_amortization with (nolock)
	where	application_no	   = @p_application_no
			and fee_code	   = @p_fee_code
			and installment_no < @installment_no ;

	if abs(@p_fee_amount - @total_amount_psak) <> 0
	begin
		set @amort_amount = (@p_fee_amount - @total_amount_psak) ;

		--optimise order
		update	application_fee_amortization
		set		amortization_amount = @amort_amount
		where	application_no		= @p_application_no
				and fee_code		= @p_fee_code
				and installment_no	= (@tenor / @schedule_month) ;
	end ;

	set nocount off ;
end ;

