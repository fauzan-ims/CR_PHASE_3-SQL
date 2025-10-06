CREATE PROCEDURE dbo.xsp_received_voucher_update
(
	@p_code							nvarchar(50)
	,@p_branch_code					nvarchar(50)
	,@p_branch_name					nvarchar(250)
	,@p_received_status				nvarchar(10)
	,@p_received_from				nvarchar(250)
	,@p_received_transaction_date	datetime
	,@p_received_value_date			datetime
	,@p_received_orig_amount		decimal(18, 2)
	,@p_received_orig_currency_code nvarchar(3)
	,@p_received_exch_rate			decimal(18, 6)
	,@p_received_base_amount		decimal(18, 2)
	,@p_received_remarks			nvarchar(4000)
	,@p_branch_bank_code			nvarchar(50)
	,@p_branch_bank_name			nvarchar(50)
	--,@p_is_reconcile				nvarchar(1)
	--,@p_reconcile_date				datetime
	--,@p_reversal_code				nvarchar(50)
	--,@p_reversal_date				datetime
	--
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	--if @p_is_reconcile = 'T'
	--	set @p_is_reconcile = '1' ;

	--if @p_is_reconcile = 'F'
	--	set @p_is_reconcile = '0' ;
	--set @p_received_transaction_date = @p_received_value_date;
	set @p_received_transaction_date = dbo.xfn_get_system_date();
	begin try
		if (@p_received_value_date > dbo.xfn_get_system_date()) 
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Value Date','System Date');
			raiserror(@msg ,16,-1)
		end
		update	received_voucher
		set		branch_code						= @p_branch_code
				,branch_name					= @p_branch_name
				,received_status				= @p_received_status
				,received_from					= @p_received_from
				,received_transaction_date		= @p_received_transaction_date
				,received_value_date			= @p_received_value_date
				,received_orig_amount			= @p_received_orig_amount
				,received_orig_currency_code	= @p_received_orig_currency_code
				,received_exch_rate				= @p_received_exch_rate
				,received_base_amount			= @p_received_base_amount
				,received_remarks				= @p_received_remarks
				,branch_bank_code				= @p_branch_bank_code
				,branch_bank_name				= @p_branch_bank_name
				--,is_reconcile					= @p_is_reconcile
				--,reconcile_date				= @p_reconcile_date
				--,reversal_code				= @p_reversal_code
				--,reversal_date				= @p_reversal_date
				--
				,mod_date						= @p_mod_date
				,mod_by							= @p_mod_by
				,mod_ip_address					= @p_mod_ip_address
		where	code							= @p_code ;
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
