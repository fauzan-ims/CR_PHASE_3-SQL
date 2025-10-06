CREATE PROCEDURE [dbo].[xsp_cashier_transaction_update]
(
	@p_code							nvarchar(50)
	,@p_branch_code					nvarchar(50)
	,@p_branch_name					nvarchar(250)
	,@p_cashier_main_code			nvarchar(50)
	,@p_cashier_status				nvarchar(10)
	,@p_cashier_trx_date			datetime
	,@p_cashier_value_date			datetime
	,@p_cashier_type				nvarchar(10)
	,@p_cashier_orig_amount			decimal(18, 2)
	,@p_cashier_currency_code		nvarchar(3)
	,@p_cashier_exch_rate			decimal(18, 6)
	,@p_cashier_base_amount			decimal(18, 2)
	,@p_cashier_remarks				nvarchar(4000)
	,@p_agreement_no				nvarchar(50) = null
	,@p_deposit_amount				decimal(18, 2) = 0
	,@p_is_use_deposit				nvarchar(1)
	,@p_deposit_used_amount			decimal(18, 2) = 0
	,@p_received_amount				decimal(18, 2) = 0
	,@p_receipt_code				nvarchar(50) = null
	,@p_is_received_request			nvarchar(1)
	,@p_card_receipt_reff_no		nvarchar(50)	= null
	,@p_card_bank_name				nvarchar(250)	= null
	,@p_card_account_name			nvarchar(250)	= null
	,@p_branch_bank_code			nvarchar(50)
	,@p_branch_bank_name			nvarchar(250)
	,@p_bank_gl_link_code			nvarchar(50)
	,@p_pdc_code					nvarchar(50) = null
	,@p_pdc_no						nvarchar(50) = null
	,@p_received_from				nvarchar(50)
	,@p_received_collector_code		nvarchar(50) = null
	,@p_received_collector_name		nvarchar(250)  = null
	,@p_received_payor_name			nvarchar(250) = null
	,@p_received_payor_area_no_hp	nvarchar(4)	  = null
	,@p_received_payor_no_hp		nvarchar(15)  = null
	,@p_received_payor_reference_no nvarchar(50)  = null
	,@p_reversal_code				nvarchar(50) = null
	,@p_reversal_date				datetime = null
	,@p_received_request_code		nvarchar(50) = null
	,@p_bank_account_name			nvarchar(250) = null
	,@p_bank_account_no				nvarchar(50) = null
	--,@p_print_count					int
	--,@p_print_max_count				int
	,@p_reff_no						nvarchar(250) = ''
	--,@p_is_reconcile				nvarchar(1)
	--,@p_reconcile_date				datetime = null
	--
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ,
			@from_is_use_deposit nvarchar(1),
			@from_cashier_orig_amount decimal(18,2),
			@from_detail_cashier_amount decimal(18,2)

	if @p_is_use_deposit = 'T'
		set @p_is_use_deposit = '1' ;
	else
		set @p_is_use_deposit = '0' ;

	--if @p_is_reconcile = 'T'
	--	set @p_is_reconcile = '1' ;
	--else
	--	set @p_is_reconcile = '0' ;

	if (@p_pdc_code = '')
	begin
	    set @p_pdc_code = null
	end

	if (@p_pdc_no = '')
	begin
	    set @p_pdc_no = null
	end

	if (@p_deposit_used_amount <= 0)
	begin
	    set @p_is_use_deposit = '0'
	end

	--if (@p_cashier_type = 'CASH')
	--begin
	--	select @p_bank_gl_link_code	= value
	--	from dbo.sys_global_param
	--	where code = 'GLLINKCC'
	--end

	begin try
		if not exists
		(
			select	1
			from	dbo.journal_gl_link
			where	code = @p_bank_gl_link_code
		)
		begin
			set @msg = 'Please setting GL Link for GL Link Code : ' + @p_bank_gl_link_code ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@p_cashier_value_date > dbo.xfn_get_system_date())
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Value Date', 'System Date') ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@p_deposit_used_amount < 0)
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_greater_than('Deposit Use Amount', '0') ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@p_deposit_used_amount > @p_deposit_amount)
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Deposit Use Amount', 'Deposit Amount') ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (isnull(@p_received_request_code, '') <> '')
		begin
			if exists
			(
				select	1
				from	dbo.cashier_received_request
				where	code					  = @p_received_request_code
						and request_currency_code <> @p_cashier_currency_code
			)
			begin
				set @msg = dbo.xfn_get_msg_err_must_be_equal_to('Received Currency', 'Bank Currency') ;

				raiserror(@msg, 16, -1) ;
			end ;
		end ;
		
		SELECT @from_is_use_deposit = is_use_deposit,
			   @from_cashier_orig_amount = cashier_orig_amount
		from dbo.cashier_transaction
		where code = @p_code;

		update	cashier_transaction
		set		branch_code						= @p_branch_code
				,branch_name					= @p_branch_name
				,cashier_main_code				= @p_cashier_main_code
				,cashier_status					= @p_cashier_status
				,cashier_trx_date				= @p_cashier_trx_date
				,cashier_value_date				= @p_cashier_value_date
				,cashier_type					= @p_cashier_type
				,cashier_orig_amount			= @p_cashier_orig_amount
				,cashier_currency_code			= @p_cashier_currency_code
				,cashier_exch_rate				= @p_cashier_exch_rate
				,cashier_base_amount			= @p_cashier_base_amount
				,cashier_remarks				= @p_cashier_remarks
				,agreement_no					= @p_agreement_no
				,deposit_amount					= @p_deposit_amount		
				,is_use_deposit					= @p_is_use_deposit		
				,deposit_used_amount			= @p_deposit_used_amount	
				,received_amount				= @p_received_amount		
				,receipt_code					= @p_receipt_code
				,is_received_request			= @p_is_received_request
				,card_receipt_reff_no			= @p_card_receipt_reff_no
				,card_bank_name					= @p_card_bank_name
				,card_account_name				= @p_card_account_name
				,branch_bank_code				= @p_branch_bank_code
				,branch_bank_name				= @p_branch_bank_name
				,bank_gl_link_code				= @p_bank_gl_link_code
				,pdc_code						= @p_pdc_code
				,pdc_no							= @p_pdc_no
				,received_from					= @p_received_from
				,received_collector_code		= @p_received_collector_code
				,received_collector_name		= @p_received_collector_name
				,received_payor_name			= @p_received_payor_name
				,received_payor_area_no_hp		= @p_received_payor_area_no_hp
				,received_payor_no_hp			= @p_received_payor_no_hp
				,received_payor_reference_no	= @p_received_payor_reference_no
				,reversal_code					= @p_reversal_code
				,reversal_date					= @p_reversal_date
				,received_request_code			= @p_received_request_code
				,bank_account_name				= @p_bank_account_name
				,bank_account_no				= @p_bank_account_no
				--,print_count					= @p_print_count
				--,print_max_count				= @p_print_max_count
				,reff_no						= @p_reff_no
				--,is_reconcile					= @p_is_reconcile
				--,reconcile_date					= @p_reconcile_date
				--
				,mod_date						= @p_mod_date
				,mod_by							= @p_mod_by
				,mod_ip_address					= @p_mod_ip_address
		where	code							= @p_code ;

		if (@p_cashier_orig_amount <> @from_cashier_orig_amount and @p_is_use_deposit = '1')
		begin
			select @from_detail_cashier_amount = sum(orig_amount)
			from dbo.cashier_transaction_detail
			where cashier_transaction_code = @p_code;

			update  dbo.cashier_transaction 
			SET deposit_used_amount = @from_detail_cashier_amount -  @p_cashier_orig_amount 
			WHERE code = @p_code

		end

		if (isnull(@p_receipt_code,'') <> '')
		begin
			update	dbo.cashier_receipt_allocated 
			set		receipt_use_trx_code	= @p_code
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	receipt_code			= @p_receipt_code
					and cashier_code		= @p_cashier_main_code
		end

		if (isnull(@p_agreement_no,'') = '' and @p_is_received_request = '0')
		begin
			update	dbo.cashier_transaction_detail 
			set		orig_amount					= @p_cashier_orig_amount
					,exch_rate					= @p_cashier_exch_rate
					,base_amount				= @p_cashier_base_amount
					,mod_date					= @p_mod_date
					,mod_by						= @p_mod_by
					,mod_ip_address				= @p_mod_ip_address
			where	cashier_transaction_code	= @p_code
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

