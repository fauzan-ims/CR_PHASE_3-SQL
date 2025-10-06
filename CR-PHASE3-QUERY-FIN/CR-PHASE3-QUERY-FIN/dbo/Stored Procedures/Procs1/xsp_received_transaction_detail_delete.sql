CREATE PROCEDURE dbo.xsp_received_transaction_detail_delete
(
	@p_id bigint
)
as
begin
	declare @msg						nvarchar(max) 
			,@received_request_code		nvarchar(50)
			,@received_transaction_code	nvarchar(50)
			,@sum_amount				decimal(18, 2) = 0
			,@rate_amount				decimal(18, 6)
			,@status					nvarchar(50)

	begin try
		select	@received_request_code		= received_request_code
				,@received_transaction_code	= received_transaction_code
		from	dbo.received_transaction_detail
		where	id = @p_id ;

		select @status = received_status 
		from dbo.received_transaction
		where code = @received_transaction_code

		if(@status = 'HOLD')
		begin
			delete received_transaction_detail
			where	id = @p_id ;

			update dbo.received_request
			set		received_transaction_code	= null
					,received_status			= 'HOLD'
			where	code = @received_request_code

			select	@sum_amount = isnull(sum(base_amount),0)
			from	dbo.received_transaction_detail with(nolock)
			where	received_transaction_code = @received_transaction_code

	
			update	dbo.received_transaction
			set		received_orig_amount	= @sum_amount / received_exch_rate
					,received_base_amount	= @sum_amount 
			where	code					= @received_transaction_code;
		end

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
