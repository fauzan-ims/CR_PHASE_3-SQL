CREATE PROCEDURE [dbo].[xsp_cashier_main_close]
(
	@p_code				nvarchar(50)
	--,@p_approval_reff		nvarchar(250)
	--,@p_approval_remark	nvarchar(4000)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare	@msg				nvarchar(max)
			,@receipt_code		nvarchar(50)
			,@transaction_code	nvarchar(50)
			,@system_date		datetime

	begin try

		set	@system_date = dbo.xfn_get_system_date()

		if	(
					( select isnull(sum(total_amount),0) from dbo.cashier_banknote_and_coin where cashier_code = @p_code) 
					<> ( select isnull(cashier_close_amount,0) from dbo.cashier_main where code = @p_code)
				)
		begin
			set @msg = 'Please input banknote and coin, make sure equal with Close Amount';
			raiserror(@msg ,16,-1)
		end

		if exists (select 1 from dbo.cashier_transaction where cashier_main_code = @p_code and cashier_status in ('HOLD'))
		begin
			select	@transaction_code	= code 
			from	dbo.cashier_transaction 
			where	cashier_main_code = @p_code 
					and cashier_status not in ('PAID','CANCEL')

			set @msg = 'Cashier Transaction with transaction_no '+ @transaction_code+' has not been completed, please complete the transaction';
			raiserror(@msg ,16,-1)
		end

		--if exists (select 1 from dbo.suspend_allocation where cashier_code = @p_code and allocation_status not in ('POST','CANCEL'))
		--begin
		--	select	@transaction_code	= code 
		--	from	dbo.suspend_allocation 
		--	where	cashier_code = @p_code 
		--			and allocation_status <> 'POST'

		--	set @msg = 'Suspend Allocation with transaction_no '+ @transaction_code+' has not been completed, please complete the transaction';
		--	raiserror(@msg ,16,-1)
		--end

		--if exists (select 1 from dbo.deposit_allocation where cashier_code = @p_code and allocation_status not in ('POST','CANCEL'))
		--begin
		--	select	@transaction_code	= code 
		--	from	dbo.deposit_allocation 
		--	where	cashier_code = @p_code 
		--			and allocation_status <> 'POST'

		--	set @msg = 'Deposit Allocation with transaction_no '+ @transaction_code+' has not been completed, please complete the transaction';
		--	raiserror(@msg ,16,-1)
		--end

		if exists (select 1 from dbo.cashier_main where code = @p_code and cashier_status <> 'OPEN')
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed();
			raiserror(@msg ,16,-1)
		end
		else
		begin
			declare cur_cashier_receipt_allocated cursor fast_forward read_only for
			
			select	receipt_code
			from	dbo.cashier_receipt_allocated 
			where	cashier_code		= @p_code	
					and	receipt_status	= 'NEW'

			open cur_cashier_receipt_allocated
		
			fetch next from cur_cashier_receipt_allocated 
			into	@receipt_code

			while @@fetch_status = 0
			begin
				
				update	dbo.receipt_main
				set		cashier_code		= null
						,mod_date			= @p_mod_date
						,mod_by				= @p_mod_by
						,mod_ip_address		= @p_mod_ip_address
				where	code				= @receipt_code

				fetch next from cur_cashier_receipt_allocated 
				into	@receipt_code
			
			end
			close cur_cashier_receipt_allocated
			deallocate cur_cashier_receipt_allocated

			update	dbo.cashier_main
			set		cashier_status		= 'CLOSE'
					,cashier_close_date	= @system_date
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code = @p_code
		end
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

end


