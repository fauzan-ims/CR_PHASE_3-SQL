CREATE PROCEDURE dbo.xsp_cashier_transaction_detail_delete
(
	@p_id bigint
)
as
begin
	declare @msg						nvarchar(max)
			,@received_request_code		nvarchar(50)
			,@cashier_transaction_code	nvarchar(50)
			,@sum_amount				decimal(18, 2)
			,@rate_amount				decimal(18, 6);

	begin try
		select	@received_request_code		= received_request_code
				,@cashier_transaction_code	= cashier_transaction_code
		from	dbo.cashier_transaction_detail
		where	id	= @p_id

		delete cashier_transaction_detail
		where	id = @p_id ;

		if(isnull(@received_request_code,'') <> '')
		begin
		    update	dbo.cashier_received_request
			set		request_status		= 'HOLD'
					,process_reff_code	= null
					,process_reff_name	= null
			where	code				= @received_request_code
		end

		select	@sum_amount = isnull(sum(base_amount),0)
		from	dbo.cashier_transaction_detail
		where	cashier_transaction_code = @cashier_transaction_code
				and is_paid = '1'

		select	@rate_amount = cashier_exch_rate
		from	dbo.cashier_transaction
		where	code = @cashier_transaction_code

		update	dbo.cashier_transaction
		set		cashier_orig_amount		= (@sum_amount / @rate_amount) - deposit_used_amount
				,received_amount		= @sum_amount / @rate_amount
				,cashier_base_amount	= @sum_amount
		where	code					= @cashier_transaction_code;

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
