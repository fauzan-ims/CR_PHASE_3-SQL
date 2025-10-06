CREATE PROCEDURE dbo.xsp_received_transaction_detail_update
(
	@p_id						bigint
	,@p_received_request_code	nvarchar(50)
	,@p_orig_curr_code			nvarchar(3)
	,@p_orig_amount				decimal(18, 2)
	,@p_exch_rate				decimal(18, 6)
	,@p_base_amount				decimal(18, 2)
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max) 
			,@received_transaction_code	nvarchar(50)
			,@sum_amount				decimal(18, 2)
			,@rate_amount				decimal(18, 6);

	select	@received_transaction_code = received_transaction_code 
	from	dbo.received_transaction_detail
	where	id	= @p_id

	begin try
		update	received_transaction_detail
		set		received_request_code	= @p_received_request_code
				,orig_curr_code			= @p_orig_curr_code
				,orig_amount			= @p_orig_amount
				,exch_rate				= @p_exch_rate
				,base_amount			= @p_base_amount
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	id						= @p_id ;

		select	@sum_amount = isnull(sum(base_amount),0)
		from	dbo.received_transaction_detail
		where	received_transaction_code = @received_transaction_code

		select	@rate_amount = received_exch_rate
		from	dbo.received_transaction
		where	code = @received_transaction_code

		update	dbo.received_transaction
		set		received_orig_amount	= @sum_amount / @rate_amount
				,received_base_amount	= @sum_amount 
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	code					= @received_transaction_code;

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
