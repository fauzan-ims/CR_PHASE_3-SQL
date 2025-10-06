CREATE PROCEDURE dbo.xsp_cashier_transaction_detail_update
(
	@p_id						 bigint
	,@p_cashier_transaction_code nvarchar(50)
	--,@p_transaction_code		 nvarchar(50)
	--,@p_received_request_code	 nvarchar(50)
	,@p_is_paid					 nvarchar(1)
	--,@p_orig_amount				 decimal(18, 2)
	--,@p_orig_currency_code		 nvarchar(3)
	--,@p_exch_rate				 decimal(18, 6)
	,@p_base_amount				 decimal(18, 2)
	--,@p_installment_no			 int
	--,@p_remarks					 nvarchar(4000)
	--
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare	@msg				nvarchar(max)
			,@sum_amount		decimal(18, 2)
			,@received_amount	decimal(18, 2)
			,@rate_amount		decimal(18, 6)

	if @p_is_paid = 'T'
		set @p_is_paid = '1' ;
	else
		set @p_is_paid = '0' ;

	--if (@p_base_amount <= 0)
	--begin
	--	set @p_is_paid = '0' ;
	--	set @p_base_amount = 0 ;
	--end

	begin try
		update	cashier_transaction_detail
		set		cashier_transaction_code	= @p_cashier_transaction_code
				--,transaction_code			= @p_transaction_code
				--,received_request_code		= @p_received_request_code
				,is_paid					= @p_is_paid
				,orig_amount				= @p_base_amount / exch_rate
				--,orig_currency_code			= @p_orig_currency_code
				--,exch_rate					= @p_exch_rate
				,base_amount				= @p_base_amount
				--,installment_no				= @p_installment_no
				--,remarks					= @p_remarks
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	id							= @p_id 
				--and is_paid				= '1';

		select	@sum_amount = isnull(sum(base_amount),0)
		from	dbo.cashier_transaction_detail
		where	cashier_transaction_code = @p_cashier_transaction_code
				and is_paid = '1'

		select	@rate_amount = cashier_exch_rate
		from	dbo.cashier_transaction
		where	code = @p_cashier_transaction_code
		set @received_amount = @sum_amount / @rate_amount

		if exists(select 1 from dbo.cashier_transaction where code = @p_cashier_transaction_code and isnull(received_request_code,'') = '')
		begin
			update	dbo.cashier_transaction
			set		cashier_orig_amount		= @received_amount - deposit_used_amount
					,received_amount		= @received_amount
					,cashier_base_amount	= @sum_amount
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	code					= @p_cashier_transaction_code;
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
end ;
