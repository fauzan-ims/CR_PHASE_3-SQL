CREATE PROCEDURE dbo.xsp_reconcile_main_recount
(
	@p_code					nvarchar(50)
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
	declare @msg						nvarchar(max) 
			,@system_id					bigint
			,@upload_id					bigint
			,@transaction_value_date	datetime
			,@transaction_amount		decimal(18, 2)
			,@sum_system				decimal(18, 2)
			,@sum_upload				decimal(18,2)

	begin try
		
		update	dbo.reconcile_transaction
		set		is_reconcile		= '0'
		where	reconcile_code		= @p_code

		declare cur_reconcile_transaction cursor fast_forward read_only for
			
		select	rt.id
				,rt.transaction_value_date
				,rt.transaction_amount
		from	dbo.reconcile_transaction rt
		where	reconcile_code	= @p_code
				and	rt.is_system	= '0'
				and	rt.is_reconcile	= '0'

		open cur_reconcile_transaction
		
		fetch next from cur_reconcile_transaction 
		into	@upload_id	
				,@transaction_value_date
				,@transaction_amount

		while @@fetch_status = 0
		begin
			
			if exists	(	
							select	1 
							from	dbo.reconcile_transaction 
							where	reconcile_code = @p_code 
									and transaction_value_date	= @transaction_value_date
									and	transaction_amount		= @transaction_amount 
									and is_reconcile = '0'			
									and is_system = '1'			
						)
			begin
				select	top 1 
						@system_id	= id 
				from	dbo.reconcile_transaction 
				where	reconcile_code = @p_code 
						and transaction_value_date	= @transaction_value_date
						and	transaction_amount		= @transaction_amount 
						and is_reconcile = '0'	
						and is_system = '1'	

				-- data System
				update	dbo.reconcile_transaction
				set		is_reconcile		= '1'
						,mod_date			= @p_mod_date
						,mod_by				= @p_mod_by
						,mod_ip_address		= @p_mod_ip_address
				where	id					= @system_id

				-- data Upload
				update	dbo.reconcile_transaction
				set		is_reconcile		= '1'
						,mod_date			= @p_mod_date
						,mod_by				= @p_mod_by
						,mod_ip_address		= @p_mod_ip_address
				where	id					= @upload_id
			end

		fetch next from cur_reconcile_transaction 
			into	@upload_id	
					,@transaction_value_date
					,@transaction_amount

		end
		close cur_reconcile_transaction
		deallocate cur_reconcile_transaction

		select	@sum_system		= isnull(sum(transaction_amount),0)
		from	dbo.reconcile_transaction
		where	reconcile_code = @p_code
				and is_system = '1'
				and	is_reconcile	= '1'

		select	@sum_upload		= isnull(sum(transaction_amount),0)
		from	dbo.reconcile_transaction
		where	reconcile_code = @p_code
				and is_system = '0'
				and	is_reconcile	= '1'

		update	dbo.reconcile_main
		set		system_amount			= @sum_system
				,upload_amount			= @sum_upload
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	code					= @p_code

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
