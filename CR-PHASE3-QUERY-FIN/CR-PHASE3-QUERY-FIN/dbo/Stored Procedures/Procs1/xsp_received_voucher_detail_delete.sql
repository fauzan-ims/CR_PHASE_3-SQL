CREATE PROCEDURE dbo.xsp_received_voucher_detail_delete
(
	@p_id int
)
as
begin
	declare @msg							nvarchar(max) 
			,@received_voucher_code			nvarchar(50)
			,@sum_amount					decimal(18, 2)
			,@rate_amount					decimal(18, 6);

	begin try
		select	@received_voucher_code	= received_voucher_code
		from	dbo.received_voucher_detail
		where	id = @p_id

		delete received_voucher_detail
		where	id = @p_id ;

		select	@sum_amount = isnull(sum(base_amount),0)
		from	dbo.received_voucher_detail
		where	received_voucher_code = @received_voucher_code

		select	@rate_amount = received_exch_rate
		from	dbo.received_voucher
		where	code = @received_voucher_code

		update	dbo.received_voucher
		set		received_orig_amount	= @sum_amount / @rate_amount
				,received_base_amount	= @sum_amount 
		where	code					= @received_voucher_code;

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
