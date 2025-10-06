CREATE PROCEDURE dbo.xsp_suspend_allocation_detail_delete
(
	@p_id bigint
)
as
begin
	declare @msg						nvarchar(max) 
			,@received_request_code		nvarchar(50)
			,@suspend_allocation_code	nvarchar(50)
			,@sum_amount				decimal(18, 2)
			,@allocation_exch_rate		decimal(18, 6);

	begin try
		select	@received_request_code		= received_request_code
				,@suspend_allocation_code	= suspend_allocation_code
		from	dbo.suspend_allocation_detail
		where	id	= @p_id

		delete suspend_allocation_detail
		where	id = @p_id ;

		if(isnull(@received_request_code,'') <> '')
		begin
		    update	dbo.cashier_received_request
			set		request_status		= 'HOLD'
					,process_reff_code	= null
					,process_reff_name	= null
			where	code				= @received_request_code

			select	@sum_amount = isnull(sum(orig_amount),0)
			from	dbo.suspend_allocation_detail
			where	suspend_allocation_code = @suspend_allocation_code
					and is_paid = '1'

			select	@allocation_exch_rate = allocation_exch_rate
			from	dbo.suspend_allocation
			where	code = @suspend_allocation_code

			update	dbo.suspend_allocation
			set		allocation_orig_amount	= @sum_amount
					,allocation_base_amount	= @sum_amount * @allocation_exch_rate
			where	code					= @suspend_allocation_code;
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
