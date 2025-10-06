CREATE PROCEDURE dbo.xsp_suspend_allocation_reversal
(
	@p_code					nvarchar(50)
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
	declare @msg								  nvarchar(max)
			,@gl_link_transaction_code			  nvarchar(50)
			,@agreement_external_no				  nvarchar(50)
			,@received_request_code				  nvarchar(50)
			,@transaction_code					  nvarchar(50)
			,@suspend_code						  nvarchar(50)
			,@deposit_main_code					  nvarchar(50)
			,@suspend_gl_link_code				  nvarchar(50)
			,@gl_link_code						  nvarchar(50)
			,@allocation_currency_code			  nvarchar(3)
			,@currency_code						  nvarchar(3)
			,@orig_currency_code				  nvarchar(3)
			,@agreement_no						  nvarchar(50)
			,@branch_code						  nvarchar(50)
			,@branch_name						  nvarchar(250)
			,@cr_branch_code					  nvarchar(50)
			,@cr_branch_name					  nvarchar(250)
			,@agreement_branch_code				  nvarchar(50)
			,@agreement_branch_name				  nvarchar(250)
			,@reff_source_name					  nvarchar(250)
			,@client_name						  nvarchar(250)
			,@division_code						  nvarchar(50)
			,@division_name						  nvarchar(250)
			,@department_code					  nvarchar(50)
			,@department_name					  nvarchar(250)
			,@deposit_type						  nvarchar(15)
			,@suspend_amount					  decimal(18, 2)
			,@allocation_exch_rate				  decimal(18, 6)
			,@allocation_base_amount			  decimal(18, 2)
			,@allocation_orig_amount			  decimal(18, 2)
			,@allocation_trx_date				  datetime
			,@allocation_value_date				  datetime
			,@exch_rate							  decimal(18, 6)
			,@orig_amount						  decimal(18, 2)
			,@base_amount						  decimal(18, 2)
			,@orig_amount_db					  decimal(18, 2)
			,@orig_amount_cr					  decimal(18, 2)
			,@base_amount_db					  decimal(18, 2)
			,@base_amount_cr					  decimal(18, 2)
			,@remarks							  nvarchar(4000)
			,@allocationt_remarks				  nvarchar(4000)
			,@transaction_code_temp				  nvarchar(50)
			,@is_paid							  nvarchar(1)
			,@index								  bigint
			,@detail_id							  bigint
			,@installment_no					  int
			,@sequence							  int			= 0
			,@parsial							  int			= 0
			,@first								  int			= 1
			,@charges_amount					  decimal(18, 2)
			,@reversal_date						  datetime
			,@orig_amount_deposit				  decimal(18, 2)
			,@base_amount_deposit				  decimal(18, 2)
			,@suspend_main_code					  nvarchar(50)
			,@cashier_received_request_invoice_no nvarchar(50)
			,@detail_agreement_no				  nvarchar(50) ;

	begin try
	
		select	@reversal_date		= reversal_date
		from	dbo.reversal_main
		where	source_reff_code = @p_code

		if exists
		(
			select	1
			from	dbo.suspend_allocation
			where	code				  = @p_code
					and allocation_status <> 'ON REVERSE'
		)
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed() ;
			raiserror(@msg, 16, -1) ;
		end ;
		else
		begin
			
			select	@suspend_gl_link_code		= suspend_gl_link_code
			from	dbo.suspend_allocation sa
					inner join dbo.agreement_main amn on (amn.agreement_no = sa.agreement_no)
			where	code = @p_code

			declare cur_suspend_allocation_detail cursor fast_forward read_only for
			select	sad.orig_amount
					,sad.exch_rate
					,sad.base_amount
					,case sad.transaction_code
						when 'INST' then 
							case isnull(am.agreement_sub_status,'') 
							when 'WO ACC'  then (select value from dbo.sys_global_param where code = 'INCOME')
							else mt.gl_link_code
						end
						else mt.gl_link_code
					end
					,sad.orig_currency_code
					,sad.received_request_code
					,sad.transaction_code
					,sa.branch_code
					,sa.branch_name
					,sa.allocation_trx_date
					,sa.allocation_value_date
					,sa.agreement_no
					,sad.remarks
					,sa.allocationt_remarks
					,sad.id
					,row_number() over(order by sad.id asc) as row#
			from	dbo.suspend_allocation_detail sad
					inner join dbo.suspend_allocation sa on (sa.code = sad.suspend_allocation_code)
					left join dbo.master_transaction mt on (mt.code = sad.transaction_code)
					left join dbo.agreement_main am on (am.agreement_no = sa.agreement_no)
			where	sad.suspend_allocation_code = @p_code
					and is_paid = '1'

			open cur_suspend_allocation_detail
		
			fetch next from cur_suspend_allocation_detail 
			into	@orig_amount
					,@exch_rate
					,@base_amount
					,@gl_link_code
					,@currency_code
					,@received_request_code
					,@transaction_code
					,@branch_code
					,@branch_name
					,@allocation_trx_date
					,@allocation_value_date
					,@agreement_no
					,@remarks			
					,@allocationt_remarks
					,@detail_id
					,@index

			while @@fetch_status = 0
			begin
			
				if (@index = 1)
				begin
				    select	@allocation_orig_amount		= allocation_orig_amount 
							,@allocation_base_amount	= sa.allocation_base_amount 
							,@allocation_exch_rate		= sa.allocation_exch_rate 
							,@allocation_currency_code	= allocation_currency_code 
							,@suspend_main_code			= suspend_code 
							,@agreement_external_no		= amn.agreement_external_no 
							,@client_name				= amn.client_name 
							,@agreement_branch_code		= amn.branch_code
							,@agreement_branch_name		= amn.branch_name 
					from	dbo.suspend_allocation sa
							inner join dbo.agreement_main amn on (amn.agreement_no = sa.agreement_no)
					where	code = @p_code

					set @reff_source_name = 'Reversal Suspend Allocation, Suspend No : ' + @suspend_main_code + ' for ' + @agreement_external_no + ' - ' + @client_name + '. ' + @allocationt_remarks
			
					exec dbo.xsp_fin_interface_journal_gl_link_transaction_insert @p_id							= 0
																				  ,@p_code						= @gl_link_transaction_code output
																				  ,@p_branch_code				= @branch_code 
																				  ,@p_branch_name				= @branch_name 
																				  ,@p_transaction_status		= N'NEW' 
																				  ,@p_transaction_date			= @reversal_date
																				  ,@p_transaction_value_date	= @allocation_value_date
																				  ,@p_transaction_code			= @p_code
																				  ,@p_transaction_name			= N'Reversal Suspend Allocation'
																				  ,@p_reff_module_code			= N'IFINFIN'
																				  ,@p_reff_source_no			= @p_code
																				  ,@p_reff_source_name			= @reff_source_name
																				  ,@p_is_journal_reversal		= '1'
																				  ,@p_reversal_reff_no			= @p_code
																				  ,@p_cre_date					= @p_cre_date		
																				  ,@p_cre_by					= @p_cre_by			
																				  ,@p_cre_ip_address			= @p_cre_ip_address
																				  ,@p_mod_date					= @p_mod_date		
																				  ,@p_mod_by					= @p_mod_by			
																				  ,@p_mod_ip_address			= @p_mod_ip_address


					exec dbo.xsp_fin_interface_journal_gl_link_transaction_detail_insert @p_id							= 0
																						 ,@p_gl_link_transaction_code	= @gl_link_transaction_code
																						 ,@p_branch_code				= @branch_code
																						 ,@p_branch_name				= @branch_name
																						 ,@p_gl_link_code				= @suspend_gl_link_code
																						 ,@p_contra_gl_link_code		= null
																						 ,@p_agreement_no				= @agreement_no
																						 ,@p_orig_currency_code			= @allocation_currency_code
																						 ,@p_orig_amount_db				= 0
																						 ,@p_orig_amount_cr				= @allocation_orig_amount
																						 ,@p_exch_rate					= @allocation_exch_rate
																						 ,@p_base_amount_db				= 0
																						 ,@p_base_amount_cr				= @allocation_base_amount
																						 ,@p_remarks					= @allocationt_remarks
																						 ,@p_division_code				= null
																						 ,@p_division_name				= null
																						 ,@p_department_code			= null
																						 ,@p_department_name			= null
																						 ,@p_cre_date					= @p_cre_date		
																						 ,@p_cre_by						= @p_cre_by			
																						 ,@p_cre_ip_address				= @p_cre_ip_address
																						 ,@p_mod_date					= @p_mod_date		
																						 ,@p_mod_by						= @p_mod_by			
																						 ,@p_mod_ip_address				= @p_mod_ip_address
				end

	
				if (isnull(@transaction_code,'') <> '')
				begin
				    
						if (@orig_amount > 0)
						begin
							set @orig_amount_db = abs(@orig_amount);
							set @orig_amount_cr = 0;
						end
						else
						begin
							set @orig_amount_db = 0;
							set @orig_amount_cr = abs(@orig_amount);
						end

						if (@base_amount > 0)
						begin
							set @base_amount_db = abs(@base_amount);
							set @base_amount_cr = 0;
						end
						else
						begin
							set @base_amount_db = 0;
							set @base_amount_cr = abs(@base_amount);
						end
					
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
																							 ,@p_department_name			= null
																							 ,@p_cre_date					= @p_cre_date		
																							 ,@p_cre_by						= @p_cre_by			
																							 ,@p_cre_ip_address				= @p_cre_ip_address
																							 ,@p_mod_date					= @p_mod_date		
																							 ,@p_mod_by						= @p_mod_by			
																							 ,@p_mod_ip_address				= @p_mod_ip_address
						
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

						set @orig_amount_deposit = @orig_amount * -1
						set @base_amount_deposit = @base_amount * -1

						--01/07/2021 deposit insert ke fin_interface_agreement_deposit_history
						exec dbo.xsp_fin_interface_agreement_deposit_history_insert @p_id						= 0                    
						                                                            ,@p_branch_code				= @agreement_branch_code
						                                                            ,@p_branch_name				= @agreement_branch_name
						                                                            ,@p_agreement_no			= @agreement_no
																					,@p_agreement_deposit_code  = null
						                                                            ,@p_deposit_type			= @deposit_type
						                                                            ,@p_transaction_date		= @reversal_date
						                                                            ,@p_orig_amount				= @orig_amount_deposit
						                                                            ,@p_orig_currency_code		= @currency_code
						                                                            ,@p_exch_rate				= @exch_rate  
						                                                            ,@p_base_amount				= @base_amount_deposit
						                                                            ,@p_source_reff_module		= 'IFINFIN'
						                                                            ,@p_source_reff_code		= @p_code
						                                                            ,@p_source_reff_name		= 'Reversal Suspend Allocation'
						                                                            ,@p_cre_date				= @p_cre_date		
																					,@p_cre_by					= @p_cre_by			
																					,@p_cre_ip_address			= @p_cre_ip_address
																					,@p_mod_date				= @p_mod_date		
																					,@p_mod_by					= @p_mod_by			
																					,@p_mod_ip_address			= @p_mod_ip_address    
											
					end
					
					if (@transaction_code  = 'INST') -- untuk angsuran
					begin
						exec dbo.xsp_agreement_amortization_payment_sync @p_id					= @detail_id
																		 ,@p_Type				= N'REVERSAL SUSPEND' -- nvarchar(10)
																		 ,@p_cre_date			= @p_cre_date		
																		 ,@p_cre_by				= @p_cre_by			
																		 ,@p_cre_ip_address		= @p_cre_ip_address
																		 ,@p_mod_date			= @p_mod_date		
																		 ,@p_mod_by				= @p_mod_by			
																		 ,@p_mod_ip_address		= @p_mod_ip_address
						
						
					end
					else if(@transaction_code  in ('OVDP','BYTR'))-- untuk obligasi
					begin 
						exec dbo.xsp_agreement_obligation_payment_sync @p_id					= @detail_id
																	   ,@p_Type					= N'REVERSAL SUSPEND' -- nvarchar(10)
																	   ,@p_cre_date				= @p_cre_date		
																	   ,@p_cre_by				= @p_cre_by			
																	   ,@p_cre_ip_address		= @p_cre_ip_address
																	   ,@p_mod_date				= @p_mod_date		
																	   ,@p_mod_by				= @p_mod_by			
																	   ,@p_mod_ip_address		= @p_mod_ip_address
						
						
					end
					else if(@transaction_code in ('SVCH','PUGR','FTXP','GO_LIVE','INVA','CRNC','FCCA')) 
					begin 
						set @remarks = @remarks + @allocationt_remarks
						set @charges_amount = @orig_amount * -1
						exec dbo.xsp_fin_interface_agreement_fund_in_used_history_insert @p_agreement_no				= @agreement_no
																						 ,@p_charges_date				= @allocation_trx_date
																						 ,@p_charges_type				= @transaction_code
																						 ,@p_transaction_no				= @p_code
																						 ,@p_transaction_name			= 'REVERSAL CASHIER'
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
				end
				else
				begin

					declare cur_cashier_received_request_detail cursor fast_forward read_only for
					select	sad.received_request_code
							,crrd.remarks
							,sad.exch_rate
							,crrd.orig_amount
							,sad.exch_rate * crrd.orig_amount
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
					from	dbo.suspend_allocation_detail sad
							inner join dbo.cashier_received_request crr on (crr.code = sad.received_request_code)
							inner join dbo.cashier_received_request_detail crrd on (crrd.cashier_received_request_code = crr.code)
					where	sad.suspend_allocation_code = @p_code
							and sad.received_request_code = @received_request_code 

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
							,@cr_branch_code
							,@cr_branch_name
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
						
							if (@orig_amount < 0)
							begin
								set @orig_amount_db = abs(@orig_amount);
								set @orig_amount_cr = 0;
							end
							else
							begin
								set @orig_amount_db = 0;
								set @orig_amount_cr = @orig_amount;
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
						
							exec dbo.xsp_fin_interface_journal_gl_link_transaction_detail_insert @p_id							= 0
																								 ,@p_gl_link_transaction_code	= @gl_link_transaction_code
																								 ,@p_branch_code				= @cr_branch_code
																								 ,@p_branch_name				= @cr_branch_name
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
																								 ,@p_add_reff_01				= @cashier_received_request_invoice_no
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
								,@cr_branch_code
								,@cr_branch_name
								,@cashier_received_request_invoice_no
								,@detail_agreement_no
					
					end
					close cur_cashier_received_request_detail
					deallocate cur_cashier_received_request_detail
					
				    update cashier_received_request
					set		request_status		= 'HOLD'
							,process_date		= NULL
							,process_reff_code	= null
							,process_reff_name	= null
							,voucher_no			= null
							--
							,mod_date			= @p_mod_date
							,mod_by				= @p_mod_by
							,mod_ip_address		= @p_mod_ip_address
					where	code				= @received_request_code

					update dbo.fin_interface_cashier_received_request
					set		request_status			= 'REVERSAL'
							--
							,mod_date				= @p_mod_date
							,mod_by					= @p_mod_by
							,mod_ip_address			= @p_mod_ip_address
					where	code					= @received_request_code
				end

				fetch next from cur_suspend_allocation_detail 
				into	@orig_amount
						,@exch_rate
						,@base_amount
						,@gl_link_code
						,@currency_code
						,@received_request_code
						,@transaction_code
						,@branch_code
						,@branch_name
						,@allocation_trx_date
						,@allocation_value_date
						,@agreement_no
						,@remarks			
						,@allocationt_remarks
						,@detail_id
						,@index
			
			end
			close cur_suspend_allocation_detail
			deallocate cur_suspend_allocation_detail
			
			----SEPRIA 18/07/2023: UNTUK TRANSAKSI DARI REQUEST TP NGK JADI ADA PEMBAYARAN, UPDATE STATUS KEMBALI JADI HOLD.
			--update	dbo.cashier_received_request
			--set		request_status		= 'HOLD'
			--		,process_reff_code	= null
			--		,process_reff_name	= null
			--from	dbo.cashier_received_request crr 
			--		inner join dbo.suspend_allocation_detail ctd on ctd.received_request_code = crr.code
			--where	ctd.suspend_allocation_code = @p_code
			--and		is_paid = '0'

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

			select	@suspend_main_code			= suspend_code 
					,@suspend_amount		   = allocation_base_amount
					,@branch_code			   = branch_code
					,@branch_name			   = branch_name
					,@allocation_trx_date	   = allocation_trx_date
					,@agreement_no			   = agreement_no
					,@allocation_exch_rate	   = allocation_exch_rate
					,@allocation_base_amount   = allocation_base_amount
					,@allocation_orig_amount   = allocation_orig_amount
					,@allocation_currency_code = allocation_currency_code
			from	dbo.suspend_allocation 
			where	code = @p_code

			update	dbo.suspend_main
			set		used_amount						= used_amount - @allocation_orig_amount
					,remaining_amount				= remaining_amount + @allocation_orig_amount
					--,transaction_code				= null
					--,transaction_name				= null
					,mod_date						= @p_mod_date
					,mod_by							= @p_mod_by
					,mod_ip_address					= @p_mod_ip_address
			where	code							= @suspend_main_code
			
			set @allocation_base_amount = @allocation_base_amount
			set @allocation_orig_amount = @allocation_orig_amount
			exec dbo.xsp_suspend_history_insert @p_id					= 0
												,@p_branch_code			= @branch_code
												,@p_branch_name			= @branch_name
												,@p_suspend_code		= @suspend_main_code
												,@p_transaction_date	= @reversal_date
												,@p_orig_amount			= @allocation_orig_amount
												,@p_orig_currency_code	= @allocation_currency_code
												,@p_exch_rate			= @allocation_exch_rate
												,@p_base_amount			= @allocation_base_amount
												,@p_agreement_no		= @agreement_no
												,@p_source_reff_code	= @p_code
												,@p_source_reff_name	= N'Reversal Suspend Allocation'
												,@p_cre_date			= @p_cre_date		
												,@p_cre_by				= @p_cre_by			
												,@p_cre_ip_address		= @p_cre_ip_address
												,@p_mod_date			= @p_mod_date		
												,@p_mod_by				= @p_mod_by			
												,@p_mod_ip_address		= @p_mod_ip_address

			update	dbo.suspend_allocation
			set		allocation_status	= 'REVERSE'
					,voucher_no			= @gl_link_transaction_code
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
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





