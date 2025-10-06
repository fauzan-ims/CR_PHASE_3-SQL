CREATE procedure dbo.xsp_job_eod_cashier_main_close
as
begin
	declare @msg			   nvarchar(max)
			,@mod_date		   datetime		= getdate()
			,@mod_by		   nvarchar(15) = 'EOD'
			,@mod_ip_address   nvarchar(15) = 'SYSTEM'
			,@receipt_code	   nvarchar(50)
			,@transaction_code nvarchar(50) ;

	begin try
		begin
			declare cur_cashier_receipt_allocated cursor fast_forward read_only for
			select	receipt_code
			from	dbo.cashier_receipt_allocated cra
					inner join dbo.cashier_main cm on (cm.code = cra.cashier_code)
			where	cm.cashier_status			= 'OPEN'
					and cm.cashier_close_amount = 0
					and receipt_status			= 'NEW' ;

			open cur_cashier_receipt_allocated ;

			fetch next from cur_cashier_receipt_allocated
			into @receipt_code ;

			while @@fetch_status = 0
			begin
				update	dbo.receipt_main
				set		cashier_code	= null
						,mod_date		= @mod_date
						,mod_by			= @mod_by
						,mod_ip_address = @mod_ip_address
				where	code			= @receipt_code ;

				fetch next from cur_cashier_receipt_allocated
				into @receipt_code ;
			end ;

			close cur_cashier_receipt_allocated ;
			deallocate cur_cashier_receipt_allocated ;

			--cancel transaction cashier yang masih hold
			declare cur_cashier cursor fast_forward read_only for
			select	code
			from	dbo.cashier_transaction
			where	cashier_status = 'HOLD'
					and cashier_main_code in
						(
							select	code
							from	dbo.cashier_main
							where	cashier_close_amount = 0
									and cashier_status	 = 'OPEN'
						) ;

			open cur_cashier ;

			fetch next from cur_cashier
			into @transaction_code ;

			while @@fetch_status = 0
			begin
				exec dbo.xsp_cashier_transaction_cancel @p_code				= @transaction_code
														,@p_cre_date		= @mod_date
														,@p_cre_by			= @mod_by
														,@p_cre_ip_address	= @mod_ip_address
														,@p_mod_date		= @mod_date
														,@p_mod_by			= @mod_by
														,@p_mod_ip_address	= @mod_ip_address ;

				fetch next from cur_cashier
				into @transaction_code ;
			end ;

			close cur_cashier ;
			deallocate cur_cashier ;

			update	dbo.cashier_main
			set		cashier_status			= 'CLOSE'
					,cashier_close_date		= @mod_date
					,mod_date				= @mod_date
					,mod_by					= @mod_by
					,mod_ip_address			= @mod_ip_address
			where	cashier_close_amount	= 0
					and cashier_status		= 'OPEN' ;
		end ;
	end try
	begin catch
		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			set @msg = 'E;There is an error.' + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
