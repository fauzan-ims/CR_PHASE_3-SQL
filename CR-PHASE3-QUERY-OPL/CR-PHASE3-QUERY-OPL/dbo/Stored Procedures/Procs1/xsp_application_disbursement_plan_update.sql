CREATE PROCEDURE [dbo].[xsp_application_disbursement_plan_update]
(
	@p_code					nvarchar(50)
	,@p_application_no		nvarchar(50)
	,@p_calculate_by		nvarchar(10)
	,@p_disbursement_pct	decimal(9, 6)  = 0
	,@p_disbursement_amount decimal(18, 2) = 0
	,@p_plan_date			datetime
	,@p_remarks				nvarchar(4000)
	,@p_bank_code			nvarchar(50)
	,@p_bank_name			nvarchar(250)
	,@p_bank_account_no		nvarchar(50)
	,@p_bank_account_name	nvarchar(250)
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg						 nvarchar(max)
			,@loan_amount				 decimal(18, 2)
			,@dp_amount					 decimal(18, 2)
			,@fee_reduce_disburse_amount decimal(18, 2)
			,@disbursement_amount		 decimal(18, 2)
			,@total_disbursement_amount	 decimal(18, 2)
			,@total_allocation_disbursement decimal(18, 2)
			,@total_allocation_pct		 decimal(9,6)
			,@dp_received_by			 nvarchar(1) ;

	begin try

		if (@p_plan_date < dbo.xfn_get_system_date())
		begin
			set @msg = 'Plan Date must be greater or equal than System Date';
			raiserror(@msg, 16, -1) ;
		end 

		if (@p_disbursement_pct < 0)
		begin
			set @msg = 'Disbursement PCT must be greater than 0' ;
			raiserror(@msg, 16, 1) ;
		end ;

		select	@dp_amount = am.dp_amount
				,@dp_received_by = at.dp_received_by
				,@loan_amount = am.loan_amount
		from	dbo.application_main am
				inner join dbo.application_tc at on (at.application_no = am.application_no)
		where	am.application_no = @p_application_no ;

		select	@fee_reduce_disburse_amount = isnull(sum(fee_reduce_disburse_amount), 0)
		from	dbo.application_fee
		where	application_no = @p_application_no ;

		select	@total_disbursement_amount = isnull(sum(disbursement_amount), 0) + @p_disbursement_amount
		from	dbo.application_disbursement_plan
		where	application_no = @p_application_no
				and code <> @p_code ;
		
		if (@dp_received_by = 'M')
		begin
			set @disbursement_amount = @loan_amount + @dp_amount - @fee_reduce_disburse_amount ;
			select @disbursement_amount
			if (@total_disbursement_amount > @disbursement_amount)
			begin
				set @msg = 'Total Disbursement Amount must be less or equal to Loan Amount + DP Amount - Reduce Disburse Fee Amount, Maximum amount ' + convert(varchar, cast((@disbursement_amount - (@total_disbursement_amount- @p_disbursement_amount) ) as money), 1) ;

				raiserror(@msg, 16, 1) ;
			end ;
		end ;
		else
		begin
			set @disbursement_amount = @loan_amount - @fee_reduce_disburse_amount ;
			if (@total_disbursement_amount > @disbursement_amount)
			begin
				set @msg = 'Total Disbursement Amount must be less or equal with Loan Amount - Reduce Disburse Fee Amount, Maximum amount ' + convert(varchar, cast((@disbursement_amount - (@total_disbursement_amount- @p_disbursement_amount) ) as money), 1) ;

				raiserror(@msg, 16, 1) ;
			end ;
		end ;

		if @p_calculate_by = 'AMOUNT'
		begin
			select	@p_disbursement_pct = (@p_disbursement_amount / @disbursement_amount) * 100
			from	dbo.application_main
			where	application_no = @p_application_no ;
		end ;
		else
		begin
			select	@p_disbursement_amount = (@p_disbursement_pct / 100) * @disbursement_amount
			from	dbo.application_main
			where	application_no = @p_application_no ;

		end ;
		update	application_disbursement_plan
		set		application_no			= @p_application_no
				,calculate_by			= @p_calculate_by
				,disbursement_pct		= isnull(@p_disbursement_pct, 0)
				,disbursement_amount	= isnull(@p_disbursement_amount, 0)
				,plan_date				= @p_plan_date
				,remarks				= @p_remarks
				,bank_code				= @p_bank_code
				,bank_name				= @p_bank_name
				,bank_account_no		= @p_bank_account_no
				,bank_account_name		= @p_bank_account_name
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	code					= @p_code ;


		-- untuk menghendle jika prosestase 100% namun nilai alokasi belum semua
		select	@total_allocation_pct = sum(disbursement_pct)
				,@total_allocation_disbursement = sum(disbursement_amount)
		from	application_disbursement_plan
		where	application_no = @p_application_no		
		if (@total_allocation_pct = 100  )
		begin  
			if (@total_allocation_disbursement) <> @disbursement_amount
				begin
					update	application_disbursement_plan
					set		disbursement_amount	= disbursement_amount + ( @disbursement_amount - @total_allocation_disbursement)
					where	code					= @p_code ;
				end
		end ;

		if (@p_disbursement_amount <= 0)
		begin
			set @msg = 'Disbursement Amount must be greater than 0' ;
			raiserror(@msg, 16, 1) ;
		end ;

		if ((
				select	sum(disbursement_pct)
				from	application_disbursement_plan
				where	application_no = @p_application_no
			) > 100 or @p_disbursement_pct > 100
		   )
		begin
			set @msg = 'Disbursement PCT must be less or equal than 100' ;

			raiserror(@msg, 16, 1) ;
		end ;
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
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;



