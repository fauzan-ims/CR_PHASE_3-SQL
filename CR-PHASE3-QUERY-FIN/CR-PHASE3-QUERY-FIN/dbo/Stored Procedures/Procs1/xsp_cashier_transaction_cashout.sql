CREATE PROCEDURE dbo.xsp_cashier_transaction_cashout
(
	@p_code						nvarchar(50) output
	,@p_cashier_code			nvarchar(50) -- ini nomor cashier
	,@p_bank_gl_link_code		nvarchar(50)
	,@p_branch_bank_code		nvarchar(50) 
	,@p_branch_bank_name		nvarchar(250)
	,@p_currency_code			nvarchar(3)
	--,@p_approval_remark		nvarchar(4000)
	--
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare	@msg							nvarchar(max)
			,@cashier_close_amount			decimal(18,2)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@cashier_trx_date				datetime
			,@cashier_value_date			datetime
			,@cashier_remarks				nvarchar(4000)

	begin try
		if not exists (select 1 from dbo.cashier_transaction where cashier_main_code = @p_cashier_code)
		begin
			set @msg = 'Please do at least one transaction for this cashier';
			raiserror(@msg ,16,-1)
		end

		if exists (select 1 from dbo.cashier_main where code = @p_cashier_code and cashier_close_amount < 0)
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_greater_than('Close Amount','0');
			raiserror(@msg ,16,-1)
		end

		if exists (select 1 from dbo.account_transfer where cashier_code = @p_cashier_code and transfer_status = 'HOLD')
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed();
			raiserror(@msg ,16,-1)
		end
		else
		begin
			select	top	1 
					@cashier_trx_date			= cashier_trx_date
					,@cashier_value_date		= cashier_value_date
					,@cashier_remarks			= cashier_remarks
					,@branch_code				= branch_code
					,@branch_name				= branch_name
			from	dbo.cashier_transaction
			where	cashier_main_code			= @p_cashier_code

			select	@cashier_close_amount	= cashier_close_amount 
			from	dbo.cashier_main
			where	code = @p_cashier_code

			if exists	( 
					select	1 
					from	dbo.account_transfer 
					where	from_branch_bank_code = @p_branch_bank_code 
							and from_branch_code = @branch_code
							and	transfer_status = 'HOLD'
				)
			begin
					set @msg = 'Data already on process for this bank';
					raiserror(@msg ,16,-1)
			end

			exec dbo.xsp_account_transfer_insert @p_code					= @p_code output
												 ,@p_transfer_status		= N'HOLD'
												 ,@p_transfer_trx_date		= @cashier_trx_date
												 ,@p_transfer_value_date	= @cashier_value_date
												 ,@p_cashier_amount			= @cashier_close_amount
												 ,@p_transfer_remarks		= @cashier_remarks
												 ,@p_cashier_code			= @p_cashier_code
												 ,@p_from_branch_code		= @branch_code
												 ,@p_from_branch_name		= @branch_name
												 ,@p_from_currency_code		= @p_currency_code
												 ,@p_from_branch_bank_code	= @p_branch_bank_code
												 ,@p_from_branch_bank_name	= @p_branch_bank_name
												 ,@p_from_gl_link_code		= @p_bank_gl_link_code
												 ,@p_from_exch_rate			= 1
												 ,@p_from_orig_amount		= 0
												 ,@p_to_branch_code			= null
												 ,@p_to_branch_name			= null
												 ,@p_to_currency_code		= null
												 ,@p_to_branch_bank_code	= null
												 ,@p_to_branch_bank_name	= null
												 ,@p_to_gl_link_code		= null
												 ,@p_to_exch_rate			= 1
												 ,@p_to_orig_amount			= 0
												 ,@p_cre_date				= @p_cre_date		
												 ,@p_cre_by					= @p_cre_by			
												 ,@p_cre_ip_address			= @p_cre_ip_address
												 ,@p_mod_date				= @p_mod_date		
												 ,@p_mod_by					= @p_mod_by			
												 ,@p_mod_ip_address			= @p_mod_ip_address

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

