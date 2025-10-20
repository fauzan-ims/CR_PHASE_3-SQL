CREATE PROCEDURE dbo.xsp_cashier_transaction_paid
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
	declare	@msg						  nvarchar(max)
			,@deposit_code				  nvarchar(50)
			,@bank_mutation_code		  nvarchar(50)
			,@deposit_gl_link_code		  nvarchar(50)
			,@gl_link_transaction_code	  nvarchar(50)
			,@suspend_main_code			  nvarchar(50)
			,@received_request_code		  nvarchar(50)
			,@transaction_code			  nvarchar(50)
			,@branch_code				  nvarchar(50)
			,@branch_name				  nvarchar(250)
			,@agreement_branch_code		  nvarchar(50)
			,@agreement_branch_name		  nvarchar(250)
			,@branch_bank_code			  nvarchar(50)
			,@branch_bank_name			  nvarchar(250)
			,@cashier_trx_date			  datetime
			,@cashier_value_date		  datetime
			,@gl_link_code				  nvarchar(50)
			,@bank_gl_link_code			  nvarchar(50)
			,@cashier_type				  nvarchar(10)
			,@deposit_type				  nvarchar(15)
			,@currency_code				  nvarchar(3)
			,@cashier_currency_code		  nvarchar(3)
			,@orig_currency_code		  nvarchar(3)
			,@agreement_no				  nvarchar(50)
			,@orig_amount				  decimal(18, 2)
			,@base_amount				  decimal(18, 2)
			,@reten_orig_amount			  decimal(18, 2)
			,@reten_base_amount			  decimal(18, 2)
			,@exch_rate					  decimal(18, 6)
			,@cashier_base_amount		  decimal(18, 2)
			,@cashier_orig_amount		  decimal(18, 2)
			,@cashier_exch_rate			  decimal(18, 6)
			,@base_amount_db			  decimal(18, 2)
			,@base_amount_cr			  decimal(18, 2)
			,@orig_amount_db			  decimal(18, 2)
			,@orig_amount_cr			  decimal(18, 2)
			,@deposit_amount			  decimal(18, 2)
			,@division_code				  nvarchar(50)
			,@division_name				  nvarchar(250)
			,@department_code			  nvarchar(50)
			,@department_name			  nvarchar(250)
			,@cashier_main_code			  nvarchar(50)
			,@receipt_code				  nvarchar(50)
			,@reff_source_name			  nvarchar(250)
			,@reff_no					  nvarchar(250)
			,@suspend_remarks			  nvarchar(4000)
			,@remarks					  nvarchar(4000)
			,@cashier_remarks			  nvarchar(4000)
			,@is_use_deposit			  nvarchar(1)
			,@deposit_used_amount		  decimal(18, 2)
			,@deposit_base_amount		  decimal(18, 2)
			,@received_amount			  decimal(18, 2)
			,@transaction_code_temp		  nvarchar(50)
			,@is_paid					  nvarchar(1)
			,@index						  bigint
			,@cashier_transaction_id	  bigint
			,@installment_no			  int
			,@sequence					  int = 0
			,@parsial					  int = 0
			,@first						  int = 1
			,@gl_link_name				  nvarchar(250)
			,@charges_amount			  decimal(18, 2)
			,@deposit_history_orig_amount decimal(18, 2)
			,@deposit_history_base_amount decimal(18, 2)
			,@customer_name				  nvarchar(250)
			,@invoice_date				  datetime
			,@allocation_amount			  decimal(18, 2)
			,@allocation_amount_detail	  decimal(18, 2)
			,@asset_no					  nvarchar(50)
			,@invoice_amount			  decimal(18, 2)
			,@remarks_invoice			  nvarchar(4000)
			,@invoice_no				  nvarchar(50)
			,@invoice_due_date			  datetime
			,@invoice_net_amount		  decimal(18, 2)
			,@invoice_balance_amount	  decimal(18, 2)
			,@factoring_type			  nvarchar(10)
			,@base_amount_detail		  decimal(18, 2)
			,@cashier_amount			  decimal(18, 2)
			,@crr_branch_code			  nvarchar(50)
			,@crr_branch_name			  nvarchar(250)
			,@cashier_received_request_invoice_no nvarchar(50)
			,@detail_agreement_no	nvarchar(50)

	begin try
		select	@cashier_main_code	    = cashier_main_code 
		        ,@factoring_type        = am.factoring_type
				,@cashier_orig_amount   = ct.cashier_orig_amount
				,@receipt_code			= ct.receipt_code
		from	dbo.cashier_transaction ct
		        left join dbo.agreement_main am on (am.agreement_no = ct.agreement_no) 
		where	code = @p_code

		--invoice amount
		select @invoice_amount = isnull(sum(allocation_amount),0)
		from   cashier_transaction_invoice
		where cashier_transaction_code = @p_code

		--allocation amount
		select @allocation_amount_detail = isnull(sum(base_amount),0)
		from   cashier_transaction_detail
		where cashier_transaction_code = @p_code
		and   transaction_code in ('ARRETEN','RTEN')
		
		--if @allocation_amount_detail > @allocation_amount_detail
		--begin
		--	set @msg = 'Please input invalid allocation';
		--	raiserror(@msg ,16,-1)
		--end
        
		if exists (select 1 from cashier_transaction where code = @p_code and branch_bank_code = '')
		begin
			set @msg = 'Please input bank';
			raiserror(@msg ,16,-1)
		end

		if exists (select 1 from dbo.cashier_transaction where code = @p_code and cashier_orig_amount <= 0 and is_use_deposit = '0')
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_greater_than('Orig Amount','0');
			raiserror(@msg ,16,-1)
		end
		
		if not exists (select 1 from dbo.cashier_transaction_detail where cashier_transaction_code = @p_code)
		begin
			set @msg = 'Please add Allocation';
			raiserror(@msg ,16,-1)
		END
        
		if exists (select 1 from dbo.receipt_main where code = @receipt_code and receipt_status <> 'NEW')
		begin
			set @msg = 'Receipt already used';
			raiserror(@msg ,16,-1)
		end
		
		if not exists (select 1 from dbo.cashier_transaction_detail where cashier_transaction_code = @p_code and is_paid = '1')
		begin
			set @msg = 'Please Paid at least one transaction ';
			raiserror(@msg ,16,-1)
		end

		if not exists (select 1 from dbo.cashier_main where code = @cashier_main_code)
		begin
			set @msg = 'Open cashier before proceed';
			raiserror(@msg ,16,-1)
		end

		--factoring		
		if @factoring_type = 'STANDARD' and @invoice_amount > @cashier_orig_amount
		begin
			set @msg = 'Invoice Amount must be less than Orig Amount';
			raiserror(@msg ,16,-1)
		end

		if (@cashier_orig_amount < 0 OR @deposit_used_amount < 0)
		begin
			set @msg = 'Please check Orig Amount and Deposit Use Amount';
			raiserror(@msg ,16,-1)
		END

		-- Louis Senin, 30 Juni 2025 18.03.07 -- 
		if exists
		(
			select	1
			from	dbo.cashier_transaction_detail
			where	cashier_transaction_code	 = @p_code
					and transaction_code		 = 'DPINST'
					and isnull(agreement_no, '') = ''
		)
		begin
			set @msg = N'Please Choose Agreement No in Allocation Deposit Installment' ;

			raiserror(@msg, 16, -1) ;
		end ;
		-- Louis Senin, 30 Juni 2025 18.03.07 -- 
        
		if ((
				select	isnull(cashier_base_amount, 0)
				from	dbo.cashier_transaction
				where	code = @p_code
			) <>
		   (
			   select	isnull(sum(base_amount), 0)
			   from		dbo.cashier_transaction_detail
			   where	cashier_transaction_code = @p_code
						and is_paid				 = '1'
		   )
		   )
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_equal_than('Base Amount', 'Total Amount') ;

			raiserror(@msg, 16, -1) ;
		end ;  
	
		-- Validasi Sequentily
		declare cur_cashier_transaction_detail cursor fast_forward read_only for
			
		select		ctd.id
					,ctd.transaction_code
					,ctd.installment_no
					,ctd.is_paid
		from		dbo.cashier_transaction_detail ctd
		where		cashier_transaction_code = @p_code
					and isnull(ctd.installment_no,0) <> 0
		order by	ctd.transaction_code asc, ctd.installment_no asc

		open cur_cashier_transaction_detail
		
		fetch next from cur_cashier_transaction_detail 
		into	@cashier_transaction_id
				,@transaction_code
				,@installment_no
				,@is_paid

		while @@fetch_status = 0
		begin
				if (@first = 1)
				begin
					set @transaction_code_temp = @transaction_code ;
					set @first = 2 ;
				end ;

				if (@transaction_code_temp <> @transaction_code)
				begin
					set @transaction_code_temp = @transaction_code ;
					set @first = 1 ;
				end ;

				if ((
						select	count(1)
						from	dbo.cashier_transaction_detail
						where	cashier_transaction_code = @p_code
								and transaction_code	 = @transaction_code
					) > 1
				   )
				begin
					if exists
					(
						select	1
						from	dbo.cashier_transaction_detail
						where	cashier_transaction_code = @p_code
								and transaction_code	 = @transaction_code
								and is_paid				 = '1'
					)
					begin
						if (@first = 1)
						begin
							--if (@is_paid <> '1')
							--begin
							--	close cur_cashier_transaction_detail ;
							--	deallocate cur_cashier_transaction_detail ;

							--	set @msg = 'Please allocate installment sequentially' ;

							--	raiserror(@msg, 16, -1) ;
							--end ;
							--else 
							if (@parsial = 1)
							begin
								if exists
								(
									select	1
									from	dbo.cashier_transaction_detail
									where	id					= @cashier_transaction_id
											and innitial_amount <> orig_amount
								)
								begin
									close cur_cashier_transaction_detail ;
									deallocate cur_cashier_transaction_detail ;

									set @msg = 'Allocate installment parsial only for one installment' ;

									raiserror(@msg, 16, -1) ;
								end ;
							end ;
							else if (@parsial = 0)
							begin
								if exists
								(
									select	1
									from	dbo.cashier_transaction_detail
									where	id					= @cashier_transaction_id
											and innitial_amount <> orig_amount
								)
								begin
									set @parsial = 1 ;
								end ;
							end ;
						end ;
						else
						begin
							if (@is_paid <> '1')
							begin
								set @sequence = 1 ;
							end ;
							else
							begin
								--if (@sequence = 1)
								--begin
								--	close cur_cashier_transaction_detail ;
								--	deallocate cur_cashier_transaction_detail ;

								--	set @msg = 'Please allocate installment sequentially' ;

								--	raiserror(@msg, 16, -1) ;
								--end ;
								--else 
								if (@parsial = 1)
								begin
									if exists
									(
										select	1
										from	dbo.cashier_transaction_detail
										where	id					= @cashier_transaction_id
												and innitial_amount <> orig_amount
									)
									begin
										close cur_cashier_transaction_detail ;
										deallocate cur_cashier_transaction_detail ;

										set @msg = 'Allocate installment parsial only for one installment' ;

										raiserror(@msg, 16, -1) ;
									end ;
								end ;
								else if (@parsial = 0)
								begin
									if exists
									(
										select	1
										from	dbo.cashier_transaction_detail
										where	id					= @cashier_transaction_id
												and innitial_amount <> orig_amount
									)
									begin
										set @parsial = 1 ;
									end ;
								end ;
							end ;
						end ;
					end ;
				end ;
				fetch next from cur_cashier_transaction_detail 
				into	@cashier_transaction_id
						,@transaction_code
						,@installment_no
						,@is_paid
			
			end
		close cur_cashier_transaction_detail
		deallocate cur_cashier_transaction_detail
		 
		if exists
		(
			select	1
			from	dbo.cashier_transaction
			where	code			   = @p_code
					and cashier_status <> 'HOLD'
		)
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed() ;

			raiserror(@msg, 16, -1) ;
		end ;
		else
		begin
		 
			select	@branch_code					= ct.branch_code
					,@branch_name					= ct.branch_name
					,@cashier_trx_date				= ct.cashier_trx_date
					,@cashier_value_date			= ct.cashier_value_date
					,@cashier_currency_code			= ct.cashier_currency_code
					,@reff_no						= ct.reff_no 
					,@cashier_remarks				= ct.cashier_remarks 
					,@cashier_base_amount			= ct.cashier_base_amount
					,@cashier_orig_amount			= ct.cashier_orig_amount
					,@cashier_exch_rate				= ct.cashier_exch_rate
					,@bank_gl_link_code				= ct.bank_gl_link_code
					,@branch_bank_code				= ct.branch_bank_code
					,@branch_bank_name				= ct.branch_bank_name
					,@cashier_type					= ct.cashier_type
					,@is_use_deposit				= ct.is_use_deposit
					,@deposit_used_amount			= ct.deposit_used_amount
					,@received_amount				= ct.received_amount
					,@received_request_code			= ct.received_request_code
			from	dbo.cashier_transaction ct
			where	code							= @p_code
	
			--- proses update request ketika ada request dari PDC dan Collection (SKT dan FIELD COLL)
			if (isnull(@received_request_code,'') <> '')
			begin
				update cashier_received_request
				set		request_status		= 'PAID'
						,process_date		= @cashier_value_date
						,process_reff_code	= @p_code
						,process_reff_name	= 'CASHIER TRANSACTION'
						,mod_date			= @p_mod_date
						,mod_by				= @p_mod_by
						,mod_ip_address		= @p_mod_ip_address
				where	code				= @received_request_code

				update dbo.fin_interface_cashier_received_request
				set		request_status			= 'PAID'
						,process_date			= @cashier_value_date
						,process_reff_no		= @p_code
						,process_reff_name		= 'CASHIER TRANSACTION'
						,mod_date				= @p_mod_date
						,mod_by					= @p_mod_by
						,mod_ip_address			= @p_mod_ip_address
				where	code					= @received_request_code    
			end
            

			exec dbo.xsp_bank_mutation_insert @p_code					= @bank_mutation_code output 
											  ,@p_branch_code			= @branch_code
											  ,@p_branch_name			= @branch_name
											  ,@p_gl_link_code			= @bank_gl_link_code
											  ,@p_branch_bank_code		= @branch_bank_code
											  ,@p_branch_bank_name		= @branch_bank_name
											  ,@p_balance_amount		= @cashier_orig_amount
											  ,@p_cre_date				= @p_cre_date		
											  ,@p_cre_by				= @p_cre_by			
											  ,@p_cre_ip_address		= @p_cre_ip_address
											  ,@p_mod_date				= @p_mod_date		
											  ,@p_mod_by				= @p_mod_by			
											  ,@p_mod_ip_address		= @p_mod_ip_address

			exec dbo.xsp_bank_mutation_history_insert @p_id						= 0
													  ,@p_bank_mutation_code	= @bank_mutation_code
													  ,@p_transaction_date		= @cashier_trx_date
													  ,@p_value_date			= @cashier_value_date
													  ,@p_source_reff_code		= @p_code
													  ,@p_source_reff_name		= N'Cashier Transaction' -- nvarchar(250)
													  ,@p_orig_amount			= @cashier_orig_amount
													  ,@p_orig_currency_code	= @cashier_currency_code
													  ,@p_exch_rate				= @cashier_exch_rate
													  ,@p_base_amount			= @cashier_base_amount
													  ,@p_remarks				= @cashier_remarks
													  ,@p_cre_date				= @p_cre_date		
													  ,@p_cre_by				= @p_cre_by			
													  ,@p_cre_ip_address		= @p_cre_ip_address
													  ,@p_mod_date				= @p_mod_date		
													  ,@p_mod_by				= @p_mod_by			
													  ,@p_mod_ip_address		= @p_mod_ip_address	

			declare cur_cashier_transaction_detail cursor fast_forward read_only for
			select	ctd.orig_amount
					,ctd.base_amount
					,ctd.exch_rate
					,case ctd.transaction_code
						 when 'INST' then case isnull(am.agreement_sub_status, '')
											  when 'WO' then
											  (
												  select	value
												  from		dbo.sys_global_param
												  where		code = 'INCOME'
											  )
											  else mt.gl_link_code
										  end
						 else mt.gl_link_code
					 end
					,ctd.orig_currency_code
					,ctd.received_request_code
					,ctd.transaction_code
					,ct.branch_code
					,ct.branch_name
					,ct.cashier_trx_date
					,ct.cashier_value_date
					,isnull(ctd.agreement_no, crr.agreement_no)
					,ctd.remarks + ' ' + case isnull(ctd.installment_no, 0)
											 when 0 then ''
											 else convert(nvarchar(10), ctd.installment_no)
										 end
					,ctd.id
					,row_number() over (order by ctd.id asc) as row#
					,ct.received_amount
					,crr.INVOICE_NO
			from	dbo.cashier_transaction_detail ctd
					inner join dbo.cashier_transaction ct on (ct.code	= ctd.cashier_transaction_code)
					left join dbo.cashier_received_request crr on (crr.code = ctd.received_request_code)
					left join dbo.agreement_main am on (am.agreement_no = ct.agreement_no)
					left join dbo.master_transaction mt on (mt.code		= ctd.transaction_code)
			where	cashier_transaction_code = @p_code
					and ctd.is_paid			 = '1' ;
				
			open cur_cashier_transaction_detail
		
			fetch next from cur_cashier_transaction_detail 
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
					,@agreement_no
					,@remarks
					,@cashier_transaction_id
					,@index
					,@cashier_amount
					,@invoice_no

			while @@fetch_status = 0
			begin

				-- journal
				if (@index = 1)
				begin
					set @reff_source_name = 'Cashier Transaction ' + @cashier_remarks
					exec dbo.xsp_fin_interface_journal_gl_link_transaction_insert @p_id							= 0
																				  ,@p_code						= @gl_link_transaction_code output
																				  ,@p_branch_code				= @branch_code 
																				  ,@p_branch_name				= @branch_name 
																				  ,@p_transaction_status		= N'NEW' 
																				  ,@p_transaction_date			= @cashier_trx_date
																				  ,@p_transaction_value_date	= @cashier_value_date
																				  ,@p_transaction_code			= @p_code
																				  ,@p_transaction_name			= N'Cashier Transaction'
																				  ,@p_reff_module_code			= N'IFINFIN'
																				  ,@p_reff_source_no			= @p_code
																				  ,@p_reff_source_name			= @reff_source_name
																				  ,@p_is_journal_reversal		= '0'
																				  ,@p_reversal_reff_no			= null
																				  ,@p_cre_date					= @p_cre_date		
																				  ,@p_cre_by					= @p_cre_by			
																				  ,@p_cre_ip_address			= @p_cre_ip_address
																				  ,@p_mod_date					= @p_mod_date		
																				  ,@p_mod_by					= @p_mod_by			
																				  ,@p_mod_ip_address			= @p_mod_ip_address

					--if (@is_use_deposit = '1')
					--	set @cashier_base_amount = @cashier_amount

					if (@is_use_deposit <> '1')
					--sepria(22jan24) masuk ke gl bank hanya jika bukan deposit
					begin
						exec dbo.xsp_fin_interface_journal_gl_link_transaction_detail_insert @p_id							= 0
																							 ,@p_gl_link_transaction_code	= @gl_link_transaction_code
																							 ,@p_branch_code				= @branch_code
																							 ,@p_branch_name				= @branch_name
																							 ,@p_gl_link_code				= @bank_gl_link_code
																							 ,@p_contra_gl_link_code		= null
																							 ,@p_agreement_no				= @agreement_no
																							 ,@p_orig_currency_code			= @cashier_currency_code
																							 ,@p_orig_amount_db				= @cashier_orig_amount
																							 ,@p_orig_amount_cr				= 0
																							 ,@p_exch_rate					= @cashier_exch_rate
																							 ,@p_base_amount_db				= @cashier_base_amount
																							 ,@p_base_amount_cr				= 0
																							 ,@p_remarks					= @cashier_remarks
																							 ,@p_division_code				= null
																							 ,@p_division_name				= null
																							 ,@p_department_code			= null
																							 ,@p_department_name			= NULL
                                                                                             ,@p_add_reff_01				= @invoice_no
																							 ,@p_add_reff_02				= ''
																							 ,@p_add_reff_03				= ''
																							 ,@p_cre_date					= @p_cre_date		
																							 ,@p_cre_by						= @p_cre_by			
																							 ,@p_cre_ip_address				= @p_cre_ip_address
																							 ,@p_mod_date					= @p_mod_date		
																							 ,@p_mod_by						= @p_mod_by			
																							 ,@p_mod_ip_address				= @p_mod_ip_address
					end
					--- use deposit
					if(@is_use_deposit = '1')
					begin

						select	@deposit_gl_link_code = gl_link_code 
						from	dbo.master_transaction
						where	code = 'DPINST'
					
						set @deposit_base_amount  = @deposit_used_amount * @cashier_exch_rate 
						exec dbo.xsp_fin_interface_journal_gl_link_transaction_detail_insert @p_id							= 0
																						     ,@p_gl_link_transaction_code	= @gl_link_transaction_code
																						     ,@p_branch_code				= @branch_code
																						     ,@p_branch_name				= @branch_name
																						     ,@p_gl_link_code				= @deposit_gl_link_code
																						     ,@p_contra_gl_link_code		= null
																						     ,@p_agreement_no				= @agreement_no
																						     ,@p_orig_currency_code			= @cashier_currency_code
																						     ,@p_orig_amount_db				= @deposit_used_amount
																						     ,@p_orig_amount_cr				= 0
																						     ,@p_exch_rate					= @cashier_exch_rate
																						     ,@p_base_amount_db				= @deposit_base_amount
																						     ,@p_base_amount_cr				= 0
																						     ,@p_remarks					= @cashier_remarks
																						     ,@p_division_code				= null
																						     ,@p_division_name				= null
																						     ,@p_department_code			= null
																						     ,@p_department_name			= NULL
                                                                                             ,@p_add_reff_01				= @invoice_no
																							 ,@p_add_reff_02				= ''
																							 ,@p_add_reff_03				= ''
																						     ,@p_cre_date					= @p_cre_date		
																						     ,@p_cre_by						= @p_cre_by			
																						     ,@p_cre_ip_address				= @p_cre_ip_address
																						     ,@p_mod_date					= @p_mod_date		
																						     ,@p_mod_by						= @p_mod_by			
																						     ,@p_mod_ip_address				= @p_mod_ip_address
						
						--01/07/2021 deposit insert ke fin_interface_agreement_deposit_history
						set @deposit_base_amount = @deposit_base_amount * -1
						set @deposit_used_amount = @deposit_used_amount * -1
						
						exec dbo.xsp_fin_interface_agreement_deposit_history_insert @p_id						= 0                    
						                                                            ,@p_branch_code				= @branch_code
						                                                            ,@p_branch_name				= @branch_name
						                                                            ,@p_agreement_no			= @agreement_no
																					,@p_agreement_deposit_code  = @deposit_code
						                                                            ,@p_deposit_type			= 'INSTALLMENT'
						                                                            ,@p_transaction_date		= @cashier_trx_date
						                                                            ,@p_orig_amount				= @deposit_used_amount
						                                                            ,@p_orig_currency_code		= @currency_code
						                                                            ,@p_exch_rate				= @exch_rate  
						                                                            ,@p_base_amount				= @deposit_base_amount
						                                                            ,@p_source_reff_module		= 'IFINFIN'
						                                                            ,@p_source_reff_code		= @p_code
						                                                            ,@p_source_reff_name		= 'CASHIER'
						                                                            ,@p_cre_date				= @p_cre_date		
																					,@p_cre_by					= @p_cre_by			
																					,@p_cre_ip_address			= @p_cre_ip_address
																					,@p_mod_date				= @p_mod_date		
																					,@p_mod_by					= @p_mod_by			
																					,@p_mod_ip_address			= @p_mod_ip_address    

						
					end
				end
				
				if (isnull(@transaction_code,'') <> '')
				begin

					select	@agreement_branch_code	= branch_code
							,@agreement_branch_name	= branch_name 
					from	dbo.agreement_main
					where	agreement_no	= REPLACE(@agreement_no, '/', '.')

				-- suspend
					if(@transaction_code = (select value from dbo.sys_global_param where code = 'TRXSPND'))
					begin
						set	@agreement_branch_code	= @branch_code
						set	@agreement_branch_name	= @branch_name 

						set @suspend_remarks = @reff_no + ' ' + @cashier_remarks
						exec dbo.xsp_suspend_main_insert @p_code					= @suspend_main_code output
														 ,@p_branch_code			= @branch_code
														 ,@p_branch_name			= @branch_name
														 ,@p_suspend_date			= @cashier_trx_date
														 ,@p_suspend_currency_code	= @currency_code
														 ,@p_suspend_amount			= @orig_amount
														 ,@p_suspend_remarks		= @suspend_remarks
														 ,@p_used_amount			= 0
														 ,@p_remaining_amount		= @orig_amount
														 ,@p_reff_name				= N'CASHIER' 
														 ,@p_reff_no				= @p_code 
														 ,@p_cre_date				= @p_cre_date		
														 ,@p_cre_by					= @p_cre_by			
														 ,@p_cre_ip_address			= @p_cre_ip_address
														 ,@p_mod_date				= @p_mod_date		
														 ,@p_mod_by					= @p_mod_by			
														 ,@p_mod_ip_address			= @p_mod_ip_address
						
						exec dbo.xsp_suspend_history_insert @p_id					= 0
															,@p_branch_code			= @branch_code
															,@p_branch_name			= @branch_name
															,@p_suspend_code		= @suspend_main_code
															,@p_transaction_date	= @p_cre_date
															,@p_orig_amount			= @orig_amount
															,@p_orig_currency_code	= @currency_code
															,@p_exch_rate			= @exch_rate
															,@p_base_amount			= @base_amount
															,@p_agreement_no		= @agreement_no
															,@p_source_reff_code	= @p_code
															,@p_source_reff_name	= N'CASHIER'
															,@p_cre_date			= @p_cre_date		
															,@p_cre_by				= @p_cre_by			
															,@p_cre_ip_address		= @p_cre_ip_address
															,@p_mod_date			= @p_mod_date		
															,@p_mod_by				= @p_mod_by			
															,@p_mod_ip_address		= @p_mod_ip_address
					end
					
				    -- deposit
					if(@transaction_code in (select value from dbo.sys_global_param where code in ('TRXDPOTH','TRXDPINST','TRXDPINSI')))
					begin

						if (@transaction_code in (select value from dbo.sys_global_param where code = 'TRXDPINST'))
						begin
						    set @deposit_type = 'INSTALLMENT'
						end
						else if (@transaction_code in (select value from dbo.sys_global_param where code = 'TRXDPINSI'))
						begin
						    set @deposit_type = 'INSURANCE'
						end
						else
						begin
						    set @deposit_type = 'OTHER'
						end
						select @agreement_branch_code = isnull(@agreement_branch_code, @branch_code)
						select @agreement_branch_name = isnull(@agreement_branch_name, @branch_name)
						--01/07/2021 deposit insert ke fin_interface_agreement_deposit_history
						exec dbo.xsp_fin_interface_agreement_deposit_history_insert @p_id						= 0                    
						                                                            ,@p_branch_code				= @agreement_branch_code
						                                                            ,@p_branch_name				= @agreement_branch_name
						                                                            ,@p_agreement_no			= @agreement_no
																					,@p_agreement_deposit_code  = @deposit_code
						                                                            ,@p_deposit_type			= @deposit_type
						                                                            ,@p_transaction_date		= @cashier_trx_date
						                                                            ,@p_orig_amount				= @orig_amount
						                                                            ,@p_orig_currency_code		= @currency_code
						                                                            ,@p_exch_rate				= @exch_rate  
						                                                            ,@p_base_amount				= @base_amount
						                                                            ,@p_source_reff_module		= 'IFINFIN'
						                                                            ,@p_source_reff_code		= @p_code
						                                                            ,@p_source_reff_name		= 'CASHIER'
						                                                            ,@p_cre_date				= @p_cre_date		
																					,@p_cre_by					= @p_cre_by			
																					,@p_cre_ip_address			= @p_cre_ip_address
																					,@p_mod_date				= @p_mod_date		
																					,@p_mod_by					= @p_mod_by			
																					,@p_mod_ip_address			= @p_mod_ip_address                      
						
					end

					if (@transaction_code  = 'INST') -- untuk angsuran
					begin
						exec dbo.xsp_agreement_amortization_payment_sync @p_id					= @cashier_transaction_id
																		 ,@p_Type				= N'CASHIER' -- nvarchar(10)
																		 ,@p_cre_date			= @p_cre_date		
																		 ,@p_cre_by				= @p_cre_by			
																		 ,@p_cre_ip_address		= @p_cre_ip_address
																		 ,@p_mod_date			= @p_mod_date		
																		 ,@p_mod_by				= @p_mod_by			
																		 ,@p_mod_ip_address		= @p_mod_ip_address
						
						
					end
					else if(@transaction_code = 'OVDP' or @transaction_code = 'LRAP' or @transaction_code = 'BYTR' )-- untuk obligasi
					begin
						exec dbo.xsp_agreement_obligation_payment_sync @p_id					= @cashier_transaction_id
																	   ,@p_Type					= N'CASHIER' -- nvarchar(10)
																	   ,@p_cre_date				= @p_cre_date		
																	   ,@p_cre_by				= @p_cre_by			
																	   ,@p_cre_ip_address		= @p_cre_ip_address
																	   ,@p_mod_date				= @p_mod_date		
																	   ,@p_mod_by				= @p_mod_by			
																	   ,@p_mod_ip_address		= @p_mod_ip_address
						
						
					end
					else if(@transaction_code in ('SVCH','PUGR','FTXP','CRNC','FCCA','PNTC','DSCC')) 
					begin 
						set @remarks = @remarks + @cashier_remarks
						set @charges_amount = @orig_amount * -1
						exec dbo.xsp_fin_interface_agreement_fund_in_used_history_insert @p_agreement_no				= @agreement_no
																						 ,@p_charges_date				= @cashier_trx_date
																						 ,@p_charges_type				= @transaction_code
																						 ,@p_transaction_no				= @p_code
																						 ,@p_transaction_name			= 'CASHIER'
																						 ,@p_charges_amount				= @charges_amount 
																						 ,@p_source_reff_module			= 'IFINFIN'
																						 ,@p_source_reff_remarks		= @remarks
																						 ,@p_cre_date					= @p_cre_date		
																						 ,@p_cre_by						= @p_cre_by			
																						 ,@p_cre_ip_address				= @p_cre_ip_address
																						 ,@p_mod_date					= @p_mod_date		
																						 ,@p_mod_by						= @p_mod_by			
																						 ,@p_mod_ip_address				= @p_mod_ip_address
					end
					else if (@transaction_code = 'RTEN') --retensi
					begin
						set @reten_orig_amount = @orig_amount * -1;
						set @reten_base_amount = @base_amount * -1;
						exec dbo.xsp_fin_interface_agreement_retention_history_insert @p_branch_code			= @branch_code
																					  ,@p_branch_name			= @branch_name
																					  ,@p_agreement_no			= @agreement_no
																					  ,@p_transaction_date		= @cashier_trx_date
																					  ,@p_orig_amount			= @reten_orig_amount
																					  ,@p_orig_currency_code	= @currency_code
																					  ,@p_exch_rate				= @exch_rate  
																					  ,@p_base_amount			= @reten_base_amount
																					  ,@p_source_reff_code		= @p_code
																					  ,@p_source_reff_name		= 'CASHIER'
																					  ,@p_cre_date				= @p_cre_date		
																					  ,@p_cre_by				= @p_cre_by			
																					  ,@p_cre_ip_address		= @p_cre_ip_address
																					  ,@p_mod_date				= @p_mod_date		
																					  ,@p_mod_by				= @p_mod_by			
																					  ,@p_mod_ip_address		= @p_mod_ip_address
						
					end
					
					if (@orig_amount < 0)
					begin
						set @orig_amount_db = abs(@orig_amount);
						set @orig_amount_cr = 0;
						set @base_amount_db = abs(@base_amount);
						set @base_amount_cr = 0;
					end
					else
					begin
						set @orig_amount_db =  0;
						set @orig_amount_cr = abs(@orig_amount);
						set @base_amount_db =  0;
						set @base_amount_cr = abs(@base_amount);
					end
					select 1, @transaction_code, @remarks, @gl_link_transaction_code
					select @agreement_branch_code = isnull(@agreement_branch_code, @branch_code)
					select @agreement_branch_name = isnull(@agreement_branch_name, @branch_name)
					exec dbo.xsp_fin_interface_journal_gl_link_transaction_detail_insert @p_id							= 0
																						 ,@p_gl_link_transaction_code	= @gl_link_transaction_code
																						 ,@p_branch_code				= @agreement_branch_code
																						 ,@p_branch_name				= @agreement_branch_name
																						 ,@p_gl_link_code				= @gl_link_code
																						 ,@p_contra_gl_link_code		= null
																						 ,@p_agreement_no				= @agreement_no
																						 ,@p_orig_currency_code			= @currency_code
																						 ,@p_orig_amount_db				= @orig_amount_db
																						 ,@p_orig_amount_cr				= @orig_amount_cr
																						 ,@p_exch_rate					= @exch_rate
																						 ,@p_base_amount_db				= @base_amount_db
																						 ,@p_base_amount_cr				= @base_amount_cr
																						 ,@p_remarks					= @remarks
																						 ,@p_division_code				= null
																						 ,@p_division_name				= null
																						 ,@p_department_code			= null
																						 ,@p_department_name			= NULL
                                                                                         ,@p_add_reff_01				= @invoice_no
																						 ,@p_add_reff_02				= ''
																						 ,@p_add_reff_03				= ''
																						 ,@p_cre_date					= @p_cre_date		
																						 ,@p_cre_by						= @p_cre_by			
																						 ,@p_cre_ip_address				= @p_cre_ip_address
																						 ,@p_mod_date					= @p_mod_date		
																						 ,@p_mod_by						= @p_mod_by			
																						 ,@p_mod_ip_address				= @p_mod_ip_address
				end
				else
				begin 

					declare cur_cashier_received_request_detail cursor fast_forward read_only for
			
					select	ctd.received_request_code
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
							,crr.invoice_no
							,crrd.agreement_no
					from	dbo.cashier_transaction_detail ctd
							inner join dbo.cashier_received_request crr on (crr.code = ctd.received_request_code)
							inner join dbo.cashier_received_request_detail crrd on (crrd.cashier_received_request_code = crr.code)
					where	ctd.cashier_transaction_code = @p_code
							and ctd.received_request_code = @received_request_code 

					open cur_cashier_received_request_detail
		
					fetch next from cur_cashier_received_request_detail 
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
							,@crr_branch_code
							,@crr_branch_name
							,@cashier_received_request_invoice_no
							,@detail_agreement_no

					while @@fetch_status = 0
					begin
							if exists
							(
								select	1
								from	ifinopl.dbo.invoice
								where	invoice_no	   = @cashier_received_request_invoice_no
										and is_journal = '0'
							)
							begin
								if (@gl_link_code = 'OLAR')
								begin
									set @gl_link_code = N'OLARND' ;
								end ;
							end ;
							else
							begin
								if (@gl_link_code = 'OLARND')
								begin
									set @gl_link_code = N'OLAR' ;
								end ;
							end ;
		
							IF (@orig_amount < 0)
							begin
								set @orig_amount_db = 0;
								set @orig_amount_cr = abs(@orig_amount);
							end
							else
							begin
								set @orig_amount_db =  @orig_amount;
								set @orig_amount_cr =  0;
							end

							if (@base_amount < 0)
							begin
								set @base_amount_db = 0;
								set @base_amount_cr = abs(@base_amount);
							end
							else
							begin
								set @base_amount_db = @base_amount;
								set @base_amount_cr = 0;
							end


							exec dbo.xsp_fin_interface_journal_gl_link_transaction_detail_insert @p_id							= 0
																								 ,@p_gl_link_transaction_code	= @gl_link_transaction_code
																								 ,@p_branch_code				= @crr_branch_code
																								 ,@p_branch_name				= @crr_branch_name
																								 ,@p_gl_link_code				= @gl_link_code
																								 ,@p_contra_gl_link_code		= null
																								 ,@p_agreement_no				= @detail_agreement_no
																								 ,@p_orig_currency_code			= @orig_currency_code
																								 ,@p_orig_amount_db				= @orig_amount_db
																								 ,@p_orig_amount_cr				= @orig_amount_cr
																								 ,@p_exch_rate					= @exch_rate
																								 ,@p_base_amount_db				= @base_amount_db
																								 ,@p_base_amount_cr				= @base_amount_cr
																								 ,@p_remarks					= @remarks
																								 ,@p_division_code				= @division_code
																								 ,@p_division_name				= @division_name
																								 ,@p_department_code			= @department_code
																								 ,@p_department_name			= @department_name
																								 ,@p_add_reff_01				= @invoice_no
																								 ,@p_add_reff_02				= ''
																								 ,@p_add_reff_03				= ''
																								 ,@p_cre_date					= @p_cre_date		
																								 ,@p_cre_by						= @p_cre_by			
																								 ,@p_cre_ip_address				= @p_cre_ip_address
																								 ,@p_mod_date					= @p_mod_date		
																								 ,@p_mod_by						= @p_mod_by			
																								 ,@p_mod_ip_address				= @p_mod_ip_address

					fetch next from cur_cashier_received_request_detail 
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
								,@crr_branch_code
								,@crr_branch_name
								,@cashier_received_request_invoice_no
								,@detail_agreement_no								
					
					end
					close cur_cashier_received_request_detail
					deallocate cur_cashier_received_request_detail
					
				    update cashier_received_request
					set		request_status		= 'PAID'
							,process_date		= @cashier_value_date
							,process_reff_code	= @p_code
							,process_reff_name	= 'CASHIER TRANSACTION'
							,voucher_no			= @gl_link_transaction_code
							--
							,mod_date			= @p_mod_date
							,mod_by				= @p_mod_by
							,mod_ip_address		= @p_mod_ip_address
					where	code				= @received_request_code

					update dbo.fin_interface_cashier_received_request
					set		request_status			= 'PAID'
							--,process_branch_code	= @branch_code
							--,process_branch_name	= @branch_name
							,process_date			= @cashier_value_date
							,process_reff_no		= @p_code
							,process_reff_name		= 'CASHIER TRANSACTION'
							,voucher_no				= @gl_link_transaction_code
							--,process_gl_link_code	= @bank_gl_link_code
							--,process_curr			= @cashier_currency_code
							--,process_exch_rate	= @cashier_exch_rate
							--,process_amount		= @cashier_orig_amount
							,mod_date				= @p_mod_date
							,mod_by					= @p_mod_by
							,mod_ip_address			= @p_mod_ip_address
					where	code					= @received_request_code
				end

				fetch next from cur_cashier_transaction_detail 
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
						,@agreement_no
						,@remarks
						,@cashier_transaction_id
						,@index
						,@cashier_amount
						,@invoice_no
			
			end
			close cur_cashier_transaction_detail
			deallocate cur_cashier_transaction_detail
				
			--SEPRIA 18/07/2023: UNTUK TRANSAKSI DARI REQUEST TP NGK JADI ADA PEMBAYARAN, UPDATE STATUS KEMBALI JADI HOLD.
			update	dbo.cashier_received_request
			set		request_status = 'HOLD'
					,process_reff_code = NULL
					,process_reff_name = NULL
			from	dbo.cashier_received_request crr 
					inner join dbo.cashier_transaction_detail ctd on ctd.received_request_code = crr.code
			where	cashier_transaction_code = @p_code
			and		is_paid = '0'

			
			if	(isnull(@gl_link_transaction_code,'') <> '')
			begin
				select	@base_amount_cr		= sum(base_amount_cr) 
						,@base_amount_db	= sum(base_amount_db) 
				from	dbo.fin_interface_journal_gl_link_transaction_detail
				where	gl_link_transaction_code = @gl_link_transaction_code
			
				--+ validasi : total detail =  payment_amount yang di header
				if (@base_amount_db <> @base_amount_cr)
				begin
					set @msg = 'Journal does not balance';
    				raiserror(@msg, 16, -1) ;
				end

				update dbo.fin_interface_journal_gl_link_transaction
				set		transaction_status	= 'HOLD'
						,mod_date			= @p_mod_date
						,mod_by				= @p_mod_by
						,mod_ip_address		= @p_mod_ip_address
				where	code				= @gl_link_transaction_code
			end

			if (@cashier_type = 'CASH')
			begin
				--update dbo.cashier_main
				--set	cashier_db_amount		= cashier_db_amount + @cashier_orig_amount
				--		,cashier_close_amount	= cashier_open_amount + cashier_db_amount - cashier_cr_amount + @cashier_orig_amount
				--		,mod_date				= @p_mod_date
				--		,mod_by					= @p_mod_by
				--		,mod_ip_address			= @p_mod_ip_address
				--where	code					= @cashier_main_code

				exec dbo.xsp_cashier_main_update_mutation @p_code				= @cashier_main_code
														  ,@p_amount			= @cashier_orig_amount
														  ,@p_cre_date			= @p_cre_date		
														  ,@p_cre_by			= @p_cre_by			
														  ,@p_cre_ip_address	= @p_cre_ip_address
														  ,@p_mod_date			= @p_mod_date		
														  ,@p_mod_by			= @p_mod_by			
														  ,@p_mod_ip_address	= @p_mod_ip_address
				
			end

			if exists (select 1 from dbo.cashier_transaction where code = @p_code and isnull(receipt_code,'') <> '')
			begin
			    
				select	@receipt_code		= receipt_code
						,@cashier_trx_date	= cashier_trx_date 
				from	dbo.cashier_transaction
				where	code = @p_code
					
				update	cashier_receipt_allocated
				set		receipt_status			 = 'USED'
						,receipt_use_date		 = @cashier_trx_date
						,mod_date				 = @p_mod_date
						,mod_by					 = @p_mod_by
						,mod_ip_address			 = @p_mod_ip_address
				where	receipt_code			 = @receipt_code
						and receipt_use_trx_code = @p_code

				update	receipt_main
				set		receipt_status		= 'USED'
						,receipt_use_date	= @cashier_trx_date
						,print_count 		= print_count +1
						,mod_date			= @p_mod_date
						,mod_by				= @p_mod_by
						,mod_ip_address		= @p_mod_ip_address
				where	code				= @receipt_code

				update dbo.cashier_transaction
				set		print_count			= 1
						,mod_date			= @p_mod_date
						,mod_by				= @p_mod_by
						,mod_ip_address		= @p_mod_ip_address
				where	code				= @p_code

			end
			
			declare cur_cashier_invoice cursor fast_forward read_only for
			
			select	customer_name
                    ,invoice_date
                    ,allocation_amount * -1
					,isnull(asset_no,'-')
					,invoice_no
					,invoice_due_date
					,invoice_net_amount
					,invoice_balance_amount
			from	dbo.cashier_transaction_invoice
			where	cashier_transaction_code = @p_code

				open cur_cashier_invoice
		
				fetch next from cur_cashier_invoice 
				into	@customer_name
						,@invoice_date
						,@allocation_amount
						,@asset_no
						,@invoice_no
						,@invoice_due_date
						,@invoice_net_amount
						,@invoice_balance_amount

				while @@fetch_status = 0
				begin
					--insert invoice
					set @remarks_invoice = 'Cashier Invoice Allocation ' + @cashier_remarks
					exec dbo.xsp_fin_interface_agreement_invoice_ledger_history_insert @p_id				     = 0
																					   ,@p_agreement_no		     = @agreement_no
																					   ,@p_asset_no			     = @asset_no
																					   ,@p_invoice_status	     = 'ACTIVE'
																					   ,@p_transaction_date	     = @cashier_trx_date
																					   ,@p_transaction_no	     = @p_code
																					   ,@p_transaction_name	     = 'CASHIER TRANSACTION'
																					   ,@p_transaction_amount    = @allocation_amount
					                                                                   ,@p_customer_client_no    = null
					                                                                   ,@p_customer_name	     = @customer_name
					                                                                   ,@p_invoice_no		     = @invoice_no
					                                                                   ,@p_invoice_date		     = @invoice_date
					                                                                   ,@p_invoice_due_date      = @invoice_due_date
					                                                                   ,@p_invoice_past_due_date = null
					                                                                   ,@p_gross_amount			 = 0
					                                                                   ,@p_vat_pct				 = null
					                                                                   ,@p_pph_pct				 = null
					                                                                   ,@p_net_amount			 = @invoice_net_amount
					                                                                   ,@p_used_amount			 = 0
					                                                                   ,@p_remarks				 = ''
					                                                                   ,@p_pug_date				 = null
					                                                                   ,@p_source_reff_module    = 'IFINFIN'
																					   ,@p_source_reff_remarks   = @remarks_invoice
																					   ,@p_cre_date			     = @p_cre_date		
																					   ,@p_cre_by			     = @p_cre_by			
																					   ,@p_cre_ip_address	     = @p_cre_ip_address
																					   ,@p_mod_date			     = @p_mod_date		
																					   ,@p_mod_by			     = @p_mod_by			
																					   ,@p_mod_ip_address	     = @p_mod_ip_address
					fetch next from cur_cashier_invoice 
					into @customer_name
						 ,@invoice_date
						 ,@allocation_amount
						 ,@asset_no
						 ,@invoice_no
						 ,@invoice_due_date
						 ,@invoice_net_amount
						 ,@invoice_balance_amount
					
				end
				close cur_cashier_invoice
				deallocate cur_cashier_invoice
																		  
			update dbo.cashier_transaction
			set		cashier_status		= 'PAID'
					,voucher_no			= @gl_link_transaction_code
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code				= @p_code
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