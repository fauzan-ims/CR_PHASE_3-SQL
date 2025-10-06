CREATE PROCEDURE dbo.xsp_cashier_transaction_cancel
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
			,@receipt_code				nvarchar(50)
			,@received_request_code		nvarchar(50)
			,@cashier_type				nvarchar(10)

	begin try

		if exists (select 1 from dbo.cashier_transaction where code = @p_code and cashier_status <> 'HOLD')
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed();
			raiserror(@msg ,16,-1)
		end
		else
		begin
			
			declare cur_cashier_transaction_detail cursor fast_forward read_only for
				
			select		received_request_code
			from		cashier_transaction_detail ctd
						inner join dbo.cashier_received_request crr on (crr.code = ctd.received_request_code)
			where		cashier_transaction_code = @p_code
			union
			select		received_request_code
			from		cashier_transaction 
			where		code = @p_code

			open cur_cashier_transaction_detail
			
			fetch next from cur_cashier_transaction_detail 
			into	@received_request_code

			while @@fetch_status = 0
			begin
				
					update	cashier_received_request
					set		request_status		= 'HOLD'
							,process_reff_name	= null
							,process_reff_code	= null
							--
							,mod_date			= @p_mod_date
							,mod_by				= @p_mod_by
							,mod_ip_address		= @p_mod_ip_address
					where	code				= @received_request_code

					fetch next from cur_cashier_transaction_detail 
					into	@received_request_code
				
				end
			close cur_cashier_transaction_detail
			deallocate cur_cashier_transaction_detail

			if exists (select 1 from dbo.cashier_transaction where code = @p_code and isnull(receipt_code,'') <> '')
			begin
				select	@receipt_code	= receipt_code
				from	dbo.cashier_transaction
				where	code = @p_code	

				update	dbo.cashier_receipt_allocated
				set		receipt_use_trx_code	 = null
						,mod_date				 = @p_mod_date
						,mod_by					 = @p_mod_by
						,mod_ip_address			 = @p_mod_ip_address
				where	receipt_code			 = @receipt_code
						and receipt_use_trx_code = @p_code
			end
			
			update	dbo.cashier_transaction
			set		cashier_status		= 'CANCEL'
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

