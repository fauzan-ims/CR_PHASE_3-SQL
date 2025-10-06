CREATE PROCEDURE dbo.xsp_payment_transaction_detail_delete
(
	@p_id bigint
)
as
begin
	declare @msg						nvarchar(max) 
			,@payment_request_code		nvarchar(50)
			,@payment_transaction_code	nvarchar(50)
			,@sum_amount			    decimal(18, 2)
			,@rate_amount			    decimal(18, 6)
			,@tax_amount			    decimal(18, 2)
			,@mod_date					datetime = getdate()		
			,@mod_by					nvarchar(50) = 'Admin'	
			,@mod_ip_address			nvarchar(50) = '127.1.1'

	begin try
		select	@payment_request_code	    = payment_request_code
				,@payment_transaction_code	= payment_transaction_code
		from	dbo.payment_transaction_detail
		where	id = @p_id ;
		
		delete payment_transaction_detail
		where	id = @p_id ;
		
		update dbo.payment_request
		set		payment_transaction_code	= null
				,payment_status				= 'HOLD'
		where	code = @payment_request_code

		select	@sum_amount  = isnull(sum(base_amount),0)
				,@tax_amount = isnull(sum(tax_amount),0)
		from	dbo.payment_transaction_detail with(nolock)
		where	payment_transaction_code = @payment_transaction_code
 

		update	dbo.payment_transaction
		set		payment_orig_amount		= @sum_amount / payment_exch_rate
				,payment_base_amount	= @sum_amount 
				,total_tax_amount       = @tax_amount
		where	code					= @payment_transaction_code;

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
