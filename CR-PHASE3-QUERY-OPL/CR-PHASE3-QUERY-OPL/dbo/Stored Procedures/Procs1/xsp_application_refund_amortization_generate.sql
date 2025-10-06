CREATE PROCEDURE dbo.xsp_application_refund_amortization_generate
(
	@p_application_no  nvarchar(50)
	,@p_refund_code	   nvarchar(15)
	,@p_refund_amount  decimal(18, 2)
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
			,@refund_name		   nvarchar(250) 
			,@metode_calculate	   nvarchar(50)
			,@msg				   nvarchar(max) ;
	begin try		
		select	@metode_calculate = value
		from	dbo.sys_global_param
		where	code = 'MTPE' ;

		-- mencari faktor pengali berdasarkan payment schedule dan interest rate
		select	@schedule_month = sps.multiplier
				,@tenor = aatc.tenor
		from	application_tc aatc with (nolock)
				inner join dbo.master_payment_schedule sps with (nolock) on (aatc.payment_schedule_type_code = sps.code)
		where	aatc.application_no = @p_application_no ;

		delete dbo.application_refund_amortization
		where	application_no	= @p_application_no
				and refund_code = @p_refund_code ;

		select	@refund_name = description
		from	dbo.master_refund
		where	code = @p_refund_code ;

		declare @total_installment_interest decimal(18, 2)
				,@amort_amount				decimal(18, 2) ;

		-- mencari total interest
		--select	@total_installment_interest = sum(installment_interest_amount)
		--from	dbo.application_amortization with (nolock)
		--where	application_no = @p_application_no ;

		declare c_amort_table cursor read_only for
		select		installment_no
					,due_date
					--,installment_interest_amount
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
					set @amort_amount = @installment_interest / @total_installment_interest * @p_refund_amount ;
				end ;
				else
				begin
					set @amort_amount = 0;
				end ;
			end
			else
			begin
				set @amort_amount = @p_refund_amount / (@tenor / @schedule_month) ;
			end ;

			exec dbo.xsp_application_refund_amortization_insert @p_application_no	= @p_application_no
																,@p_installment_no	= @installment_no
																,@p_refund_code		= @p_refund_code
																,@p_refund_name		= @refund_name
																,@p_amort_due_date	= @due_date
																,@p_amort_amount	= @amort_amount
																,@p_cre_by			= @p_cre_by
																,@p_cre_date		= @p_cre_date
																,@p_cre_ip_address	= @p_cre_ip_address
																,@p_mod_by			= @p_cre_by
																,@p_mod_date		= @p_cre_date
																,@p_mod_ip_address	= @p_cre_ip_address ;

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
		from	dbo.application_refund_amortization with (nolock)
		where	application_no	   = @p_application_no
				and refund_code	   = @p_refund_code
				and installment_no < @installment_no ;

		if abs(@p_refund_amount - @total_amount_psak) <> 0
		begin
			set @amort_amount = (@p_refund_amount - @total_amount_psak) ;

			--optimise order
			update	application_refund_amortization
			set		amortization_amount = @amort_amount
			where	application_no	   = @p_application_no
					and refund_code	   = @p_refund_code
					and installment_no = @installment_no
		end ;

		set nocount off ;
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
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

