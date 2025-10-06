CREATE PROCEDURE [dbo].[xsp_reconcile_main_post]
(
	@p_code					nvarchar(50)
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
	declare	@msg						nvarchar(max)
			,@source_reff_code			nvarchar(50)
			,@source_reff_name			nvarchar(250)
			,@bank_mutation_id			bigint

	begin try
	
		--if exists (select 1 from dbo.reconcile_main where code = @p_code and system_amount <= 0)
		--begin
		--	set @msg = dbo.xfn_get_msg_err_must_be_greater_than('System Amount','0');
		--	raiserror(@msg ,16,-1)
		--end

		if exists (select 1 from dbo.reconcile_main where code = @p_code and system_amount <> upload_amount)
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_equal_to('System Amount','Upload Amount');
			raiserror(@msg ,16,-1)
		end
		
		if exists (select 1 from dbo.reconcile_main where code = @p_code and reconcile_status <> 'ON PROCESS')
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed();
			raiserror(@msg ,16,-1)
		end
		else
		begin

			declare cur_deposit_allocation_detail cursor fast_forward read_only for
			
			select	bmh.source_reff_code
					,bmh.source_reff_name
					,bmh.id
			from	dbo.reconcile_transaction rt
					inner join dbo.bank_mutation_history bmh on (bmh.source_reff_code = rt.transaction_no)
			where	rt.reconcile_code = @p_code
					and rt.is_system = '1'
					and rt.is_reconcile = '1'

			open cur_deposit_allocation_detail
		
			fetch next from cur_deposit_allocation_detail 
			into	@source_reff_code
					,@source_reff_name
					,@bank_mutation_id

			while @@fetch_status = 0
			begin
				
				if (@source_reff_name in ('Reversal Payment Voucher','Payment Voucher'))
				begin
					update	dbo.payment_voucher
					set		is_reconcile		= '1'
							,mod_date			= @p_mod_date
							,mod_by				= @p_mod_by
							,mod_ip_address		= @p_mod_ip_address
					where	code				= @source_reff_code
				end
				else if (@source_reff_name in ('Reversal Received Voucher','Received Voucher'))
				begin
					update	dbo.received_voucher
					set		is_reconcile		= '1'
							,mod_date			= @p_mod_date
							,mod_by				= @p_mod_by
							,mod_ip_address		= @p_mod_ip_address
					where	code				= @source_reff_code
				end
				else if (@source_reff_name in ('Reversal Payment Trasaction','Payment Trasaction'))
				begin
					update	dbo.payment_transaction
					set		is_reconcile		= '1'
							,mod_date			= @p_mod_date
							,mod_by				= @p_mod_by
							,mod_ip_address		= @p_mod_ip_address
					where	code				= @source_reff_code
				end
				else if (@source_reff_name in ('Reversal Received Transaction','Received Transaction'))
				begin
					update	dbo.received_transaction
					set		is_reconcile		= '1'
							,mod_date			= @p_mod_date
							,mod_by				= @p_mod_by
							,mod_ip_address		= @p_mod_ip_address
					where	code				= @source_reff_code
				end

				else if (@source_reff_name in ('Reversal Cashier Transaction','Cashier Transaction'))
				begin
					update	dbo.cashier_transaction
					set		is_reconcile		= '1'
							,mod_date			= @p_mod_date
							,mod_by				= @p_mod_by
							,mod_ip_address		= @p_mod_ip_address
					where	code				= @source_reff_code
				end

				update	dbo.bank_mutation_history
				set		is_reconcile		= '1'
						,mod_date			= @p_mod_date
						,mod_by				= @p_mod_by
						,mod_ip_address		= @p_mod_ip_address
				where	id					= @bank_mutation_id

				fetch next from cur_deposit_allocation_detail 
				into	@source_reff_code
						,@source_reff_name
						,@bank_mutation_id
			
			end
			close cur_deposit_allocation_detail
			deallocate cur_deposit_allocation_detail
			
			update	dbo.reconcile_main
			set		reconcile_status	= 'APPROVE'
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

