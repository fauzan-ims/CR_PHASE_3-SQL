CREATE PROCEDURE dbo.xsp_cashier_received_request_for_cashier_proceed
(
	@p_code							nvarchar(50)
	,@p_rate						decimal(18, 6)
	,@p_employee_code				nvarchar(50)
	,@p_branch_bank_code			nvarchar(50)	= ''
	,@p_branch_bank_name			nvarchar(250)	= ''
	,@p_branch_bank_gl_link_code	nvarchar(50)	= ''
	,@p_request_currency_code		nvarchar(3)		= ''
    ,@p_bank_account_name			nvarchar(250)	= 'PT DIPO START FINANCE'
	,@p_bank_account_no				nvarchar(50)	= ''
	--,@p_approval_remark	nvarchar(4000)
	--
	,@p_cre_date					datetime
	,@p_cre_by						nvarchar(15)
	,@p_cre_ip_address				nvarchar(15)
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare	@msg						nvarchar(max)
			,@cashier_transaction_code	nvarchar(50)
			,@system_date				datetime = dbo.xfn_get_system_date()
			,@branch_code				nvarchar(50)
			,@branch_name				nvarchar(250)
			,@request_amount			decimal(18, 2)
			,@base_amount				decimal(18, 2)
			,@to_bank_name				nvarchar(250)
			,@agreement_no				nvarchar(50)
			,@cashier_main_code			nvarchar(50)
			,@to_bank_account_name		nvarchar(250)
			,@request_remarks			nvarchar(4000)
			,@request_currency_code		nvarchar(3)
			,@tax_file_no				nvarchar(50)
			,@tax_type					nvarchar(10)
			,@doc_ref_flag				nvarchar(10)
			,@id_request				bigint
			,@output_amount				decimal(18, 2) = 0
			,@orig_amount_detail		decimal(18, 2) = 0
			,@cashier_type				nvarchar(10)
			,@cashier_orig_amount		decimal(18, 2)
			,@cashier_base_amount		decimal(18, 2)
			,@is_received_request		nvarchar(1)
			,@received_request_code		nvarchar(50)
			,@cashier_value_date		datetime
			,@pdc_code					nvarchar(50)
			,@pdc_no					nvarchar(50)
			,@branch_bank_code			nvarchar(50)
			,@branch_bank_name			nvarchar(250)
			,@bank_gl_link_code			nvarchar(50)
			,@cashier_branch_code		nvarchar(50)
			,@cashier_branch_name		nvarchar(250)
			,@client_no					nvarchar(50) -- Louis Kamis, 26 Juni 2025 10.05.40 -- 
			,@client_name				nvarchar(250) -- Louis Kamis, 26 Juni 2025 10.05.42 -- 
	
	begin try
		select	@request_currency_code		= crr.request_currency_code
				,@request_amount			= crr.request_amount
				,@agreement_no				= crr.agreement_no
				,@request_remarks			= crr.request_remarks
				,@doc_ref_flag				= crr.doc_ref_flag
				,@cashier_orig_amount		= crr.request_amount
				,@base_amount				= crr.request_amount * @p_rate
				,@pdc_code					= crr.pdc_code
				,@pdc_no					= crr.pdc_no
				,@branch_bank_code			= isnull(crr.branch_bank_code,'')
				,@branch_bank_name			= isnull(crr.branch_bank_name,'')
				,@bank_gl_link_code			= crr.branch_bank_gl_link_code
				,@cashier_branch_code		= crr.branch_code
				,@cashier_branch_name		= crr.branch_name
				,@client_no					= isnull(crr.client_no,am.client_no)
				,@client_name				= isnull(crr.client_name,am.client_name)
		from	dbo.cashier_received_request crr with (nolock)
				left join ifinopl.dbo.agreement_main am on am.agreement_no = crr.agreement_no
		where   code = @p_code
	
		select	@cashier_main_code			= code
				,@branch_code				= branch_code
				,@branch_name				= branch_name
		from	dbo.cashier_main with (nolock)
		where	employee_code				= @p_employee_code
				and cast(cashier_open_date as date) = cast(@system_date as date) 

		if (isnull(@p_branch_bank_code, '') = '')
		begin
			set @msg = 'Please Select Bank First.'
			raiserror (@msg, 16, -1)
		end

		if exists
		(
			select	1
			from	dbo.cashier_received_request with (nolock)
			where	code			   = @p_code
					and request_status <> 'HOLD'
		)
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed() ;

			raiserror(@msg, 16, -1) ;
		end ;
	
		if @doc_ref_flag = 'PDC'
		begin
			if not exists
			(
				select	1
				from	dbo.cashier_main with (nolock)
				where	employee_code						= @p_employee_code
						and branch_code						= @cashier_branch_code
						and cast(cashier_open_date as date) = cast(@system_date as date)
			)
			begin
				set @msg = 'Please Open Cashier Branch : ' + @cashier_branch_name + ',before proceed' ;

				raiserror(@msg, 16, -1) ;
			end ;
		end ;
		else
		begin
			if not exists
			(
				select	1
				from	dbo.cashier_main with (nolock)
				where	employee_code						= @p_employee_code
						and cast(cashier_open_date as date) = cast(@system_date as date)
			)
			begin
				set @msg = 'Please Open Cashier before proceed' ;

				raiserror(@msg, 16, -1) ;
			end ;
		end ;

		if exists
		(
			select	1
			from	dbo.cashier_received_request with (nolock)
			where	code							  = @p_code
					and isnull(process_reff_code, '') <> ''
		)
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed() ;

			raiserror(@msg, 16, -1) ;
		end ;
		
		begin 
			if isnull(@doc_ref_flag,'') <> ''
			begin                    
					exec dbo.xsp_cashier_transaction_insert @p_code							= @cashier_transaction_code output
															,@p_branch_code					= @branch_code
															,@p_branch_name					= @branch_name
															,@p_cashier_main_code			= @cashier_main_code
															,@p_cashier_status				= 'HOLD' 
															,@p_cashier_trx_date			= @system_date
															,@p_cashier_value_date			= null
															,@p_cashier_type				= @doc_ref_flag
															,@p_cashier_orig_amount			= @cashier_orig_amount
															,@p_cashier_currency_code		= @p_request_currency_code
															,@p_cashier_exch_rate			= @p_rate
															,@p_cashier_base_amount			= @base_amount
															,@p_cashier_remarks				= ''
															,@p_agreement_no				= NULL -- sepria 14/10/2025: masuk jadinya per client, agreement di kosongkan. @agreement_no			
															,@p_client_no					= @client_no	-- Louis Kamis, 26 Juni 2025 10.04.36 -- 
															,@p_client_name					= @client_name	-- Louis Kamis, 26 Juni 2025 10.04.36 -- 
															,@p_deposit_amount				= 0
															,@p_is_use_deposit				= '0' 
															,@p_deposit_used_amount			= 0 
															,@p_received_amount				= 0 
															,@p_receipt_code				= null
															,@p_is_received_request			= '0'
															,@p_card_receipt_reff_no		= null
															,@p_card_bank_name				= null
															,@p_card_account_name			= null
															,@p_branch_bank_code			= @p_branch_bank_code
															,@p_branch_bank_name			= @p_branch_bank_name
															,@p_bank_gl_link_code			= @p_branch_bank_gl_link_code
															,@p_pdc_code					= @pdc_code
															,@p_pdc_no						= @pdc_no
															,@p_received_from				= 'CLIENT'
															,@p_received_collector_code		= null
															,@p_received_collector_name		= null
															,@p_received_payor_name			= null
															,@p_received_payor_area_no_hp	= null
															,@p_received_payor_no_hp		= null
															,@p_received_payor_reference_no = null
															,@p_reversal_code				= null
															,@p_received_request_code		= @p_code
															,@p_reversal_date				= null
															,@p_print_count					= 0 
															,@p_print_max_count				= 1 
															,@p_reff_no						= '' 
															,@p_is_reconcile				= '0' 
															,@p_reconcile_date				= nullr
															,@p_bank_account_name			= @p_bank_account_name
															,@p_bank_account_no				= @p_bank_account_no
															--
															,@p_cre_date					= @p_cre_date
															,@p_cre_by						= @p_cre_by
															,@p_cre_ip_address				= @p_cre_ip_address
															,@p_mod_date					= @p_cre_date
															,@p_mod_by						= @p_cre_by
															,@p_mod_ip_address				= @p_cre_ip_address

			end
			else
			begin 
				
				if not exists	(
								select	1 
								from	dbo.cashier_transaction with (nolock)
								where	cashier_status				= 'HOLD' 
										and cashier_currency_code	= @request_currency_code 
										and branch_code				= @branch_code
										--and isnull(agreement_no,'')	= isnull(@agreement_no,'') -- Louis Kamis, 26 Juni 2025 10.01.02 -- diganti jadi perclient
										and isnull(client_no, '') = isnull(@client_no, '') -- Louis Kamis, 26 Juni 2025 10.01.29 -- 
										and isnull(received_request_code,'') = ''
										and cashier_main_code		= @cashier_main_code
							)
				begin 
					exec dbo.xsp_cashier_transaction_insert @p_code							= @cashier_transaction_code output
															,@p_branch_code					= @branch_code
															,@p_branch_name					= @branch_name
															,@p_cashier_main_code			= @cashier_main_code
															,@p_cashier_status				= 'HOLD' 
															,@p_cashier_trx_date			= @system_date
															,@p_cashier_value_date			= @system_date
															,@p_cashier_type				= 'TRANSFER'
															,@p_cashier_orig_amount			= 0
															,@p_cashier_currency_code		= @p_request_currency_code
															,@p_cashier_exch_rate			= @p_rate
															,@p_cashier_base_amount			= 0
															,@p_cashier_remarks				= ''
															,@p_agreement_no				= NULL -- sepria 14/10/2025: masuk jadinya per client, agreement di kosongkan. @agreement_no		
															,@p_client_no					= @client_no	-- Louis Kamis, 26 Juni 2025 10.04.36 -- 
															,@p_client_name					= @client_name	-- Louis Kamis, 26 Juni 2025 10.04.36 -- 
															,@p_deposit_amount				= 0
															,@p_is_use_deposit				= '0' 
															,@p_deposit_used_amount			= 0 
															,@p_received_amount				= 0 
															,@p_receipt_code				= null
															,@p_is_received_request			= '1'
															,@p_card_receipt_reff_no		= null
															,@p_card_bank_name				= null
															,@p_card_account_name			= null
															,@p_branch_bank_code			= @p_branch_bank_code
															,@p_branch_bank_name			= @p_branch_bank_name
															,@p_bank_gl_link_code			= @p_branch_bank_gl_link_code
															,@p_pdc_code					= null
															,@p_pdc_no						= null
															,@p_received_from				= 'CLIENT'
															,@p_received_collector_code		= null
															,@p_received_collector_name		= null
															,@p_received_payor_name			= null
															,@p_received_payor_area_no_hp	= null
															,@p_received_payor_no_hp		= null
															,@p_received_payor_reference_no = null
															,@p_reversal_code				= null
															,@p_received_request_code		= null
															,@p_reversal_date				= null
															,@p_print_count					= 0 
															,@p_print_max_count				= 1 
															,@p_reff_no						= '' 
															,@p_is_reconcile				= '0' 
															,@p_reconcile_date				= null
															,@p_bank_account_name			= @p_bank_account_name
															,@p_bank_account_no				= @p_bank_account_no
															--
															,@p_cre_date					= @p_cre_date
															,@p_cre_by						= @p_cre_by
															,@p_cre_ip_address				= @p_cre_ip_address
															,@p_mod_date					= @p_cre_date
															,@p_mod_by						= @p_cre_by
															,@p_mod_ip_address				= @p_cre_ip_address

					update dbo.cashier_transaction
					set cashier_remarks = @request_remarks
					where code = @cashier_transaction_code 
				end
				else
				begin
					select	@cashier_transaction_code	= code 
					from	dbo.cashier_transaction with (nolock)
					where	cashier_status				= 'HOLD' 
							and cashier_currency_code	= @request_currency_code
							and branch_code				= @branch_code
							--and isnull(agreement_no,'')	= isnull(@agreement_no,'')
							and isnull(client_no,'')	= isnull(@client_no,'') -- Louis Kamis, 26 Juni 2025 15.06.31 -- 
							and isnull(received_request_code,'') = ''
							and cashier_main_code		= @cashier_main_code

				end

					exec dbo.xsp_cashier_transaction_detail_insert @p_id						= 0
																   ,@p_cashier_transaction_code = @cashier_transaction_code
																   ,@p_transaction_code			= null
																   ,@p_received_request_code	= @p_code
																   ,@p_agreement_no				= @agreement_no
																   ,@p_is_paid					= 'T' 
																   ,@p_innitial_amount			= @request_amount 
																   ,@p_orig_amount				= @request_amount
																   ,@p_orig_currency_code		= @request_currency_code
																   ,@p_exch_rate				= @p_rate
																   ,@p_base_amount				= @base_amount
																   ,@p_installment_no			= null
																   ,@p_remarks					= @request_remarks
																   ,@p_cre_date					= @p_cre_date
																   ,@p_cre_by					= @p_cre_by
																   ,@p_cre_ip_address			= @p_cre_ip_address
																   ,@p_mod_date					= @p_cre_date
																   ,@p_mod_by					= @p_cre_by
																   ,@p_mod_ip_address			= @p_cre_ip_address
			end

				update	cashier_received_request
				set		request_status	= 'ON PROCESS'
						,mod_date		= @p_cre_date
						,mod_by			= @p_cre_by
						,mod_ip_address	= @p_cre_ip_address
				where	code = @p_code
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