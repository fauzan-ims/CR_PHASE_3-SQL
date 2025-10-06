CREATE PROCEDURE dbo.xsp_job_eod_for_insert_cashier_transaction_from_et_fintech
as
begin
	declare @msg					   nvarchar(max)
			,@cashier_transaction_code nvarchar(50)
			,@system_date			   datetime		 = dbo.xfn_get_system_date()
			,@branch_code			   nvarchar(50)
			,@branch_name			   nvarchar(250)
			,@cashier_main_code		   nvarchar(50)
			,@agreement_no			   nvarchar(50)
			,@request_currency_code	   nvarchar(3)
			,@cashier_orig_amount	   decimal(18, 2)
			,@cashier_base_amount	   decimal(18, 2)
			,@cashier_exch_rate		   decimal(18, 6)
			,@mod_date				   datetime		 = getdate()
			,@mod_by				   nvarchar(15)	 = 'EOD'
			,@mod_ip_address		   nvarchar(15)	 = '127.0.0.1' ;

	begin try  
		select top 1
				@request_currency_code = request_currency_code 
				,@branch_code = branch_code
				,@branch_name = branch_name
				,@agreement_no = agreement_no
		from	dbo.cashier_received_request
		where	(
					doc_ref_name	 = 'EARLY TERMINATION FINTECH'
					or	doc_ref_name = 'DEPOSIT FINTECH'
				)
				and request_status = 'HOLD' ;

		select  @cashier_orig_amount = sum(request_amount)
		from	dbo.cashier_received_request
		where	(
					doc_ref_name	 = 'EARLY TERMINATION FINTECH'
					or	doc_ref_name = 'DEPOSIT FINTECH'
				)
				and request_status = 'HOLD' ;

		select top 1
				@cashier_main_code = code
		from	dbo.cashier_main
		where	branch_code							= @branch_code
				and cashier_status					= 'OPEN'
				and cast(cashier_open_date as date) = cast(@system_date as date) ;

		if not exists
		(
			select	1
			from	dbo.cashier_main
			where	branch_code							= @branch_code
					and cashier_status					= 'OPEN'
					and cast(cashier_open_date as date) = cast(@system_date as date)
		)
		begin
			set @msg = 'Please Open Cashier before proceed' ;

			raiserror(@msg, 16, -1) ;
		end ; 

		set @cashier_exch_rate = ifinsys.dbo.xfn_get_exch_rate(@request_currency_code, @mod_date) ;
		
		set @cashier_base_amount = @cashier_orig_amount * @cashier_exch_rate

		exec dbo.xsp_cashier_transaction_insert @p_code							= @cashier_transaction_code output
												,@p_branch_code					= @branch_code
												,@p_branch_name					= @branch_name
												,@p_cashier_main_code			= @cashier_main_code
												,@p_cashier_status				= 'HOLD' 
												,@p_cashier_trx_date			= @system_date
												,@p_cashier_value_date			= @system_date
												,@p_cashier_type				= 'TRANSFER'
												,@p_cashier_orig_amount			= @cashier_orig_amount
												,@p_cashier_currency_code		= @request_currency_code
												,@p_cashier_exch_rate			= @cashier_exch_rate
												,@p_cashier_base_amount			= @cashier_base_amount
												,@p_cashier_remarks				= 'CASHIER RECEIVED EARLY TERMINATION FINTECH'
												,@p_agreement_no				= @agreement_no
												,@p_deposit_amount				= 0
												,@p_is_use_deposit				= '0' 
												,@p_deposit_used_amount			= 0 
												,@p_received_amount				= 0 
												,@p_receipt_code				= null
												,@p_is_received_request			= '1'
												,@p_card_receipt_reff_no		= null
												,@p_card_bank_name				= null
												,@p_card_account_name			= null
												,@p_branch_bank_code			= ''
												,@p_branch_bank_name			= ''
												,@p_bank_gl_link_code			= null
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
												,@p_cre_date					= @mod_date		
												,@p_cre_by						= @mod_by		
												,@p_cre_ip_address				= @mod_ip_address
												,@p_mod_date					= @mod_date		
												,@p_mod_by						= @mod_by		
												,@p_mod_ip_address				= @mod_ip_address

		insert into dbo.cashier_transaction_detail
		(
			cashier_transaction_code
			,transaction_code
			,received_request_code
			,agreement_no
			,is_paid
			,innitial_amount
			,orig_amount
			,orig_currency_code
			,exch_rate
			,base_amount
			,installment_no
			,remarks
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	@cashier_transaction_code
				,null
				,code
				,agreement_no
				,'1'
				,request_amount
				,request_amount
				,request_currency_code
				,1
				,request_amount
				,null
				,request_remarks
				--
				,@mod_date
				,@mod_by
				,@mod_ip_address
				,@mod_date
				,@mod_by
				,@mod_ip_address
		from	dbo.cashier_received_request
		where	(
					doc_ref_name	 = 'EARLY TERMINATION FINTECH'
					or	doc_ref_name = 'DEPOSIT FINTECH'
				)
				and request_status	 = 'HOLD' ;
				 
		update	dbo.cashier_received_request
		set		request_status			= 'ON PROCESS'
				,process_reff_code		= @cashier_transaction_code
				,process_reff_name		= 'CASHIER'
				,mod_date				= @mod_date		
				,mod_by					= @mod_by		
				,mod_ip_address			= @mod_ip_address
		where	(
					doc_ref_name		= 'EARLY TERMINATION FINTECH'
					or	doc_ref_name	= 'DEPOSIT FINTECH'
				)
				and request_status		= 'HOLD'  
				and code in
				(
					select	received_request_code
					from	dbo.cashier_transaction_detail
					where	cashier_transaction_code = @cashier_transaction_code
				) ; 
	end try
	begin catch
		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			set @msg = 'E;There is an error.' + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
