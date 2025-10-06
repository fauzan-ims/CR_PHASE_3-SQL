CREATE PROCEDURE [dbo].[xsp_cashier_transaction_insert]
(
	@p_code							nvarchar(50) output
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
	,@p_cashier_base_amount			decimal(18, 2) = 0
	,@p_cashier_remarks				nvarchar(4000)
	,@p_agreement_no				nvarchar(50)   = null
	,@p_client_no					nvarchar(50)	 = null -- Louis Rabu, 25 Juni 2025 10.52.37 -- 
	,@p_client_name					nvarchar(250)	 = null -- Louis Rabu, 25 Juni 2025 10.52.37 -- 
	,@p_deposit_amount				decimal(18, 2) = 0
	,@p_is_use_deposit				nvarchar(1)
	,@p_deposit_used_amount			decimal(18, 2) = 0
	,@p_received_amount				decimal(18, 2) = 0
	,@p_receipt_code				nvarchar(50)   = null
	,@p_is_received_request			nvarchar(1)	
	,@p_card_receipt_reff_no		nvarchar(50)   = null
	,@p_card_bank_name				nvarchar(250)  = null
	,@p_card_account_name			nvarchar(250)  = null
	,@p_branch_bank_code			nvarchar(50) 
	,@p_branch_bank_name			nvarchar(250)
	,@p_bank_gl_link_code			nvarchar(50)
	,@p_pdc_code					nvarchar(50)   = null
	,@p_pdc_no						nvarchar(50)   = null
	,@p_received_from				nvarchar(50)   
	,@p_received_collector_code		nvarchar(50)   = null
	,@p_received_collector_name		nvarchar(250)  = null
	,@p_received_payor_name			nvarchar(250)  = null
	,@p_received_payor_area_no_hp	nvarchar(4)	   = null
	,@p_received_payor_no_hp		nvarchar(15)   = null
	,@p_received_payor_reference_no nvarchar(50)   = null
	,@p_reversal_code				nvarchar(50)   = null
	,@p_received_request_code		nvarchar(50)   = null
	,@p_reversal_date				datetime       = null
	,@p_print_count					int = 0
	,@p_print_max_count				int = 1
	,@p_reff_no						nvarchar(250)  = ''
	,@p_is_reconcile				nvarchar(1)	   = '0'
	,@p_reconcile_date				datetime	   = null
    ,@p_bank_account_name			nvarchar(250)  = ''
	,@p_bank_account_no				nvarchar(50)   = ''
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
	declare @msg						nvarchar(max)
			,@client_name				nvarchar(250)
			,@cashier_name				nvarchar(250)
			,@year						nvarchar(2)
			,@month						nvarchar(2)
			,@code						nvarchar(50)
			,@agreement_external_no		nvarchar(50);

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	declare @p_unique_code nvarchar(50) ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @p_code output
												,@p_branch_code = @p_branch_code
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'CHT'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'CASHIER_TRANSACTION'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	select	@agreement_external_no = agreement_external_no
	from	dbo.agreement_main
	where	agreement_no = @p_agreement_no ;

	if @p_is_use_deposit = 'T'
		set @p_is_use_deposit = '1' ;
	else
		set @p_is_use_deposit = '0' ;

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
	
	select @cashier_name = employee_name  from dbo.cashier_main with (nolock) where code = @p_cashier_main_code

	if (isnull(@p_agreement_no,'') <> '')
	begin
		if isnull(@p_received_request_code,'') <> ''
		begin
			select @p_cashier_remarks = request_remarks 
			from dbo.cashier_received_request 
			where code = @p_received_request_code
		end
		else
		begin
			select @client_name = client_name from dbo.agreement_main with (nolock) where agreement_no = @p_agreement_no
			set @p_cashier_remarks ='Agreement No : ' + @agreement_external_no + ', ' + @client_name + ' ' + @p_cashier_remarks
		end
	end
    
	begin try
		
		if @p_cashier_type = 'PDC'
		begin
			if not exists (select 1 from dbo.cashier_main with (nolock) where code = @p_cashier_main_code and branch_code = @p_branch_code)
			begin
				set @msg = 'Open Cashier Branch : ' + @p_branch_name + ',before proceed';
				raiserror(@msg ,16,-1)
			end
        end

		if (@p_cashier_value_date > dbo.xfn_get_system_date())
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Value Date', 'System Date') ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@p_cashier_orig_amount < 0)
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_greater_or_equal_than('Received Amount', '0') ;

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

		if exists
		(
			select	1
			from	dbo.cashier_transaction
			--where	agreement_no	   = @p_agreement_no -- Louis Kamis, 26 Juni 2025 11.46.46 --
			where client_no = @p_client_no -- Louis Kamis, 26 Juni 2025 11.47.04 -- 
					and cashier_status = 'HOLD'
					and is_received_request = '0'
		)
		begin
			set @msg = 'Cashier Transaction for this Agreement is being processed ' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (isnull(@p_received_request_code,'') <> '') 
			begin
				if exists (select 1 from dbo.cashier_received_request where code = @p_received_request_code and request_currency_code <> @p_cashier_currency_code) 
				begin
					set @msg = dbo.xfn_get_msg_err_must_be_equal_to('Received Currency','Bank Currency');
					raiserror(@msg ,16,-1)
				end
			end

		insert into cashier_transaction
		(
			code
			,branch_code
			,branch_name
			,cashier_main_code
			,cashier_status
			,cashier_trx_date
			,cashier_value_date
			,cashier_type
			,cashier_orig_amount
			,cashier_currency_code
			,cashier_exch_rate
			,cashier_base_amount
			,cashier_remarks
			,agreement_no
			,client_no	-- Louis Rabu, 25 Juni 2025 10.52.37 -- 
			,client_name	-- Louis Rabu, 25 Juni 2025 10.52.37 -- 
			,deposit_amount
			,is_use_deposit
			,deposit_used_amount
			,received_amount
			,receipt_code
			,is_received_request
			,card_receipt_reff_no
			,card_bank_name
			,card_account_name
			,branch_bank_code
			,branch_bank_name
			,bank_gl_link_code
			,pdc_code
			,pdc_no
			,received_from
			,received_collector_code
			,received_collector_name
			,received_payor_name
			,received_payor_area_no_hp
			,received_payor_no_hp
			,received_payor_reference_no
			,reversal_code
			,reversal_date
			,print_count
			,print_max_count
			,reff_no
			,is_reconcile
			,reconcile_date
			,received_request_code
			,bank_account_name
			,bank_account_no
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_code
			,@p_branch_code
			,@p_branch_name
			,@p_cashier_main_code
			,@p_cashier_status
			,@p_cashier_trx_date
			,@p_cashier_value_date
			,@p_cashier_type
			,@p_cashier_orig_amount
			,@p_cashier_currency_code
			,@p_cashier_exch_rate
			,@p_cashier_base_amount
			,isnull(@p_cashier_remarks,'')
			,@p_agreement_no
			,@p_client_no	-- Louis Rabu, 25 Juni 2025 10.52.37 -- 
			,@p_client_name	-- Louis Rabu, 25 Juni 2025 10.52.37 -- 
			,@p_deposit_amount
			,@p_is_use_deposit
			,@p_deposit_used_amount
			,@p_received_amount
			,@p_receipt_code
			,@p_is_received_request
			,@p_card_receipt_reff_no
			,@p_card_bank_name
			,@p_card_account_name
			,@p_branch_bank_code
			,@p_branch_bank_name
			,@p_bank_gl_link_code
			,@p_pdc_code
			,@p_pdc_no
			,@p_received_from
			,@p_received_collector_code
			,@p_received_collector_name
			,@p_received_payor_name
			,@p_received_payor_area_no_hp
			,@p_received_payor_no_hp
			,@p_received_payor_reference_no
			,@p_reversal_code
			,@p_reversal_date
			,@p_print_count
			,@p_print_max_count
			,@p_reff_no
			,@p_is_reconcile
			,@p_reconcile_date
			,@p_received_request_code
			,@p_bank_account_name
			,@p_bank_account_no
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
	
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



