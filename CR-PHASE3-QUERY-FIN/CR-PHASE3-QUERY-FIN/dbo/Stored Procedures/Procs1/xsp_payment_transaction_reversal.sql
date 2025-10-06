CREATE PROCEDURE dbo.xsp_payment_transaction_reversal
(
	@p_code				nvarchar(50)
	--,@p_approval_reff		nvarchar(250)
	--,@p_approval_remark	nvarchar(4000)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare	@msg						nvarchar(max)
			,@gl_link_transaction_code	nvarchar(50)
			,@branch_code				nvarchar(50)
			,@branch_name				nvarchar(250)
			,@cashier_trx_date			datetime
			,@cashier_value_date		datetime
			,@bank_gl_link_code			nvarchar(50)
			,@orig_amount				decimal(18, 2)
			,@base_amount				decimal(18, 2)
			,@exch_rate					decimal(18, 6)
			,@currency_code				nvarchar(3)
			,@agreement_no				nvarchar(50)
			,@remarks					nvarchar(4000)
			,@base_amount_db			decimal(18, 2)
			,@base_amount_cr			decimal(18, 2)
			,@orig_amount_cr			decimal(18, 2)
			,@orig_amount_db			decimal(18, 2)
			,@cashier_base_amount		decimal(18, 2)		
			,@cashier_orig_amount		decimal(18, 2)	
			,@cashier_exch_rate			decimal(18, 6)	
			,@index						bigint = 1
			,@cashier_currency_code		nvarchar(3)
			,@cashier_remarks			nvarchar(4000)
			,@received_request_code		nvarchar(50)
			,@gl_link_code				nvarchar(50)
			,@transaction_code			nvarchar(50)
			,@division_code				nvarchar(50)
			,@division_name				nvarchar(50)
			,@department_code			nvarchar(50)
			,@department_name			nvarchar(50)
			,@orig_currency_code		nvarchar(50)
			,@reff_source_name			nvarchar(250)
			,@detail_branch_code		nvarchar(50)
			,@detail_branch_name		nvarchar(250)
			,@suspend_main_code			nvarchar(50)
			,@deposit_type				nvarchar(15)
			,@payment_transaction_id	bigint
            ,@bank_mutation_code		nvarchar(50)
			,@branch_gl_link_code		nvarchar(50)	
			,@branch_bank_code			nvarchar(50)
			,@branch_bank_name			nvarchar(250)	
			,@payment_value_date		datetime
			,@system_date				datetime	 = dbo.xfn_get_system_date()

	begin try
	 
		select	@cashier_base_amount			= ct.payment_base_amount
				,@cashier_orig_amount			= ct.payment_orig_amount
				,@cashier_exch_rate				= ct.payment_exch_rate
				,@cashier_remarks				= ct.payment_remarks 
				,@cashier_currency_code			= ct.payment_orig_currency_code
				,@bank_gl_link_code				= bank_gl_link_code
				,@branch_code					= ct.branch_code
				,@branch_name					= ct.branch_name
				,@branch_bank_code				= branch_bank_code
				,@branch_bank_name				= branch_bank_name
				,@payment_value_date			= ct.payment_value_date
		from	dbo.payment_transaction ct
		where	code = @p_code

		exec dbo.xsp_bank_mutation_insert @p_code				= @bank_mutation_code output 
										,@p_branch_code			= @branch_code
										,@p_branch_name			= @branch_name
										,@p_gl_link_code		= @bank_gl_link_code
										,@p_branch_bank_code	= @branch_bank_code
										,@p_branch_bank_name	= @branch_bank_name
										,@p_balance_amount		= @cashier_base_amount
										,@p_cre_date			= @p_cre_date		
										,@p_cre_by				= @p_cre_by			
										,@p_cre_ip_address		= @p_cre_ip_address
										,@p_mod_date			= @p_mod_date		
										,@p_mod_by				= @p_mod_by			
										,@p_mod_ip_address		= @p_mod_ip_address

		exec dbo.xsp_bank_mutation_history_insert @p_id						= 0
												,@p_bank_mutation_code		= @bank_mutation_code
												,@p_transaction_date		= @system_date
												,@p_value_date				= @payment_value_date
												,@p_source_reff_code		= @p_code
												,@p_source_reff_name		= N'Reversal Payment Transaction' -- nvarchar(250)
												,@p_orig_amount				= @cashier_orig_amount
												,@p_orig_currency_code		= @cashier_currency_code
												,@p_exch_rate				= @cashier_exch_rate
												,@p_base_amount				= @cashier_base_amount
												,@p_remarks					= @cashier_remarks
												,@p_cre_date				= @p_cre_date		
												,@p_cre_by					= @p_cre_by			
												,@p_cre_ip_address			= @p_cre_ip_address
												,@p_mod_date				= @p_mod_date		
												,@p_mod_by					= @p_mod_by			
												,@p_mod_ip_address			= @p_mod_ip_address

		update payment_transaction
		set payment_status	= 'REVERSAL'
			--
			,mod_date		= @p_mod_date		
			,mod_by			= @p_mod_by			
			,mod_ip_address	= @p_mod_ip_address
		where code			= @p_code

		update dbo.payment_request
		set    payment_status				= 'HOLD'
			   ,payment_transaction_code	= null
			   ,tax_type					= null
			   ,tax_file_no					= null
			   ,tax_payer_reff_code			= null
			   ,tax_file_name				= null 
				--
				,mod_date					= @p_mod_date		
				,mod_by						= @p_mod_by			
				,mod_ip_address				= @p_mod_ip_address
		where  code in (select payment_request_code 
						from  dbo.payment_transaction_detail
						where payment_transaction_code = @p_code)
				
		update dbo.fin_interface_payment_request
		set    payment_status		= 'HOLD'
				,process_date		= null
				,process_reff_no	= null
				,process_reff_name  = null
				--
				,mod_date			= @p_mod_date		
				,mod_by				= @p_mod_by			
				,mod_ip_address		= @p_mod_ip_address
		where  code in (select payment_request_code 
						from  dbo.payment_transaction_detail
						where payment_transaction_code = @p_code)
											
		--looping seperti payment_transaction
		declare cur_reversal cursor fast_forward read_only for
			
		select	rtd.orig_amount																														
				,rtd.base_amount																													
				,rtd.exch_rate																														
				,rrd.gl_link_code																													
				,rr.payment_orig_currency_code																										
				,rtd.payment_request_code																											
				,rtd.payment_transaction_CODE																										
				,rr.branch_code																														
				,rr.branch_name																														
				,rr.payment_transaction_DATE																										
				,rr.payment_value_date 																											
				,rrd.remarks
				,rtd.id																															
		from	dbo.payment_transaction_detail rtd
				inner join dbo.payment_transaction rr on (rr.code = rtd.payment_transaction_code)
				left join dbo.received_request_detail rrd on (rrd.received_request_code = rr.code) 
		where	payment_transaction_code = @p_code
		open cur_reversal
		
		fetch next from cur_reversal 
		into	@orig_amount
				,@base_amount
				,@exch_rate
				,@gl_link_code
				,@currency_code
				,@received_request_code
				,@transaction_code
				,@branch_code
				,@branch_name
				,@cashier_trx_date
				,@cashier_value_date 
				,@remarks
				,@payment_transaction_id

		while @@fetch_status = 0
		begin	
				
			if (@index = 1)
			begin
				set @reff_source_name = 'Reversal Payment Transaction ' + @cashier_remarks
				--journal nya di balik debit jadi credit dan sebaliknya ( pas terbentuk journal is reversal nya diisi 1)
				exec dbo.xsp_fin_interface_journal_gl_link_transaction_insert @p_id							= 0
																				,@p_code					= @gl_link_transaction_code output
																				,@p_branch_code				= @branch_code 
																				,@p_branch_name				= @branch_name 
																				,@p_transaction_status		= N'NEW' 
																				,@p_transaction_date		= @system_date
																				,@p_transaction_value_date	= @cashier_value_date
																				,@p_transaction_code		= @p_code
																				,@p_transaction_name		= N'Payment Transaction'
																				,@p_reff_module_code		= N'IFINFIN'
																				,@p_reff_source_no			= @p_code
																				,@p_reff_source_name		= @reff_source_name
																				,@p_is_journal_reversal		= '1'
																				,@p_reversal_reff_no		= @p_code
																				--
																				,@p_cre_date				= @p_cre_date		
																				,@p_cre_by					= @p_cre_by			
																				,@p_cre_ip_address			= @p_cre_ip_address
																				,@p_mod_date				= @p_mod_date		
																				,@p_mod_by					= @p_mod_by			
																				,@p_mod_ip_address			= @p_mod_ip_address
				
				exec dbo.xsp_fin_interface_journal_gl_link_transaction_detail_insert @p_id								= 0
																						,@p_gl_link_transaction_code	= @gl_link_transaction_code
																						,@p_branch_code					= @branch_code
																						,@p_branch_name					= @branch_name
																						,@p_gl_link_code				= @bank_gl_link_code
																						,@p_contra_gl_link_code			= null
																						,@p_agreement_no				= null
																						,@p_orig_currency_code			= @cashier_currency_code
																						,@p_orig_amount_db				= @cashier_orig_amount
																						,@p_orig_amount_cr				= 0
																						,@p_exch_rate					= @cashier_exch_rate
																						,@p_base_amount_db				= @cashier_base_amount
																						,@p_base_amount_cr				= 0
																						,@p_remarks						= @cashier_remarks
																						,@p_division_code				= null
																						,@p_division_name				= null
																						,@p_department_code				= null
																						,@p_department_name				= null
																						--
																						,@p_cre_date					= @p_cre_date		
																						,@p_cre_by						= @p_cre_by			
																						,@p_cre_ip_address				= @p_cre_ip_address
																						,@p_mod_date					= @p_mod_date		
																						,@p_mod_by						= @p_mod_by			
																						,@p_mod_ip_address				= @p_mod_ip_address
						
				set @index = @index+1
			end
			 
			declare cur_payment_request_detail cursor fast_forward read_only for
			
			select	ctd.payment_request_code
					,crrd.remarks
					,ctd.exch_rate
					,crrd.orig_amount
					,ctd.exch_rate * crrd.orig_amount
					,crrd.division_code
					,crrd.division_name
					,crrd.department_code
					,crrd.department_name
					,crrd.orig_currency_code
					,crrd.gl_link_code
					,crrd.branch_code
					,crrd.branch_name	
			from	dbo.payment_transaction_detail ctd
					inner join dbo.payment_request crr on (crr.code = ctd.payment_request_code)
					inner join dbo.payment_request_detail crrd on (crrd.payment_request_code = crr.code)
			where	ctd.payment_transaction_code = @p_code
					and ctd.payment_request_code = @received_request_code 

			open cur_payment_request_detail
		
			fetch next from cur_payment_request_detail 
			into	@received_request_code
					,@remarks
					,@exch_rate
					,@orig_amount
					,@base_amount
					,@division_code
					,@division_name
					,@department_code
					,@department_name
					,@orig_currency_code
					,@gl_link_code
					,@detail_branch_code
					,@detail_branch_name

			while @@fetch_status = 0
			begin
	
				if (@orig_amount < 0)
				begin
					set @orig_amount_db = abs(@orig_amount);
					set @orig_amount_cr = 0;
				end
				else
				begin
					set @orig_amount_db =  0;
					set @orig_amount_cr =  @orig_amount;
				end

				if (@base_amount < 0)
				begin
					set @base_amount_db = abs(@base_amount);
					set @base_amount_cr = 0;
				end
				else
				begin
					set @base_amount_db = 0;
					set @base_amount_cr = @base_amount;
				end


				exec dbo.xsp_fin_interface_journal_gl_link_transaction_detail_insert @p_id								= 0
																						,@p_gl_link_transaction_code	= @gl_link_transaction_code
																						,@p_branch_code					= @detail_branch_code
																						,@p_branch_name					= @detail_branch_name
																						,@p_gl_link_code				= @gl_link_code
																						,@p_contra_gl_link_code			= null
																						,@p_agreement_no				= @agreement_no
																						,@p_orig_currency_code			= @orig_currency_code
																						,@p_orig_amount_db				= @orig_amount_db
																						,@p_orig_amount_cr				= @orig_amount_cr
																						,@p_exch_rate					= @exch_rate
																						,@p_base_amount_db				= @base_amount_db
																						,@p_base_amount_cr				= @base_amount_cr
																						,@p_remarks						= @remarks
																						,@p_division_code				= @division_code
																						,@p_division_name				= @division_name
																						,@p_department_code				= @department_code
																						,@p_department_name				= @department_name
																						--
																						,@p_cre_date					= @p_cre_date		
																						,@p_cre_by						= @p_cre_by			
																						,@p_cre_ip_address				= @p_cre_ip_address
																						,@p_mod_date					= @p_mod_date		
																						,@p_mod_by						= @p_mod_by			
																						,@p_mod_ip_address				= @p_mod_ip_address

				fetch next from cur_payment_request_detail 
				into	@received_request_code
						,@remarks
						,@exch_rate
						,@orig_amount
						,@base_amount
						,@division_code
						,@division_name
						,@department_code
						,@department_name
						,@orig_currency_code
						,@gl_link_code
						,@detail_branch_code
						,@detail_branch_name
					
			end
			close cur_payment_request_detail
			deallocate cur_payment_request_detail
		end

		fetch next from cur_reversal 
		into	@orig_amount
				,@base_amount
				,@exch_rate
				,@gl_link_code
				,@currency_code
				,@received_request_code
				,@transaction_code
				,@branch_code
				,@branch_name
				,@cashier_trx_date
				,@cashier_value_date 
				,@remarks
				,@payment_transaction_id
			
		close cur_reversal
		deallocate cur_reversal
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

