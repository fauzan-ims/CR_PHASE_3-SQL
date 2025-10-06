CREATE PROCEDURE dbo.xsp_payment_transaction_detail_insert
(
	@p_id						 bigint			= 0 output
	,@p_payment_transaction_code nvarchar(50)
	,@p_payment_request_code	 nvarchar(50)
	,@p_orig_curr_code			 nvarchar(3)
	,@p_orig_amount				 decimal(18, 2)
	,@p_exch_rate				 decimal(18, 6)
	,@p_base_amount				 decimal(18, 2) = 0
	,@p_tax_amount				 decimal(18, 2)
	--
	,@p_cre_date				 datetime
	,@p_cre_by					 nvarchar(15)
	,@p_cre_ip_address			 nvarchar(15)
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max) 
			,@sum_amount		decimal(18, 2)
			,@rate_amount		decimal(18, 6)
			,@tax_amount		decimal(18, 2);

	set @p_base_amount = @p_orig_amount * @p_exch_rate ;

	begin try
		insert into payment_transaction_detail
		(
			payment_transaction_code
			,payment_request_code
			,orig_curr_code
			,orig_amount
			,exch_rate
			,base_amount
			,tax_amount
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_payment_transaction_code
			,@p_payment_request_code
			,@p_orig_curr_code
			,@p_orig_amount
			,@p_exch_rate
			,@p_base_amount
			,@p_tax_amount
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;

		select	@sum_amount	= isnull(sum(base_amount),0)
				,@tax_amount = isnull(sum(tax_amount),0)
		from	dbo.payment_transaction_detail
		where	payment_transaction_code = @p_payment_transaction_code

		select	@rate_amount = payment_exch_rate
		from	dbo.payment_transaction
		where	code = @p_payment_transaction_code

		set @sum_amount = @sum_amount - @tax_amount

		update	dbo.payment_transaction
		set		payment_base_amount		= @sum_amount
				,payment_orig_amount	= @sum_amount / @rate_amount
				,total_tax_amount       = @tax_amount
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	code					= @p_payment_transaction_code


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

