CREATE PROCEDURE [dbo].[xsp_job_eod_for_insert_cashier_transaction_from_cashier_upload]

as
begin
	declare @msg								nvarchar(max)
			,@agreement_no						nvarchar(50)
			,@cashier_upload_code				nvarchar(50)
			,@total_amount						decimal(18, 2) = 0
			,@value_date						datetime
			,@trx_date							datetime
			,@branch_bank_code					nvarchar(50)
			,@branch_bank_name					nvarchar(250)
			,@bank_gl_link_code					nvarchar(50)
			,@fintech_name						nvarchar(250)
			,@branch_code						nvarchar(50) 
			,@branch_name						nvarchar(250)
			,@cashier_main_code					nvarchar(50)
			,@currency_code						nvarchar(3)
			,@remark							nvarchar(250)
			,@mod_date							datetime		 = getdate()
			,@mod_by							nvarchar(15)	 = 'EOD'
			,@mod_ip_address					nvarchar(15)	 = 'SYSTEM' 
			,@agreement_no_detail				nvarchar(50)
			,@installment_amount				decimal(18,2)
			,@obligation_amount					decimal(18,2)
			,@total_sisa_installment_amount		decimal(18,2)
			,@total_sisa_obligation_amount		decimal(18,2)
			,@agreement_no_inst					nvarchar(50)
			,@client_name_inst					nvarchar(250)
			,@installment_no_inst				int
			,@agreement_amount_instalment_inst	decimal(18, 2)
			,@remark_inst						nvarchar(250)
			,@agreement_no_obli					nvarchar(50)
			,@client_name_obli					nvarchar(250)
			,@installment_no_obli				int
			,@agreement_amount_obli				decimal(18, 2)
			,@obligation_type_obli				nvarchar(50)
			,@obligation_date_obli				datetime
			,@remark_obli						nvarchar(250)
			,@deposit							decimal(18,2)
			,@client_name_dpt					nvarchar(250)
			,@remark_dpt						nvarchar(250)
			,@exch_rate							decimal(18,2)
			,@base_amount						decimal(18,2)
			,@base_curency_code					nvarchar(1);

	begin try
		declare curr_cashier_upld cursor fast_forward for
		select	code
				,value_date
				,trx_date
				,branch_bank_code
				,branch_bank_name 
				,bank_gl_link_code
				,fintech_name
		from	cashier_upload_main
		where	status = 'POST' ;

		open curr_cashier_upld ;

		fetch curr_cashier_upld
		into @cashier_upload_code
			 ,@value_date
			 ,@trx_date
			 ,@branch_bank_code
			 ,@branch_bank_name
			 ,@bank_gl_link_code
			 ,@fintech_name ;

		while @@fetch_status = 0
		begin
			declare @p_code_cashier_transaction nvarchar(50) ;

			select top 1
					@agreement_no = agreement_no
			from	dbo.cashier_upload_detail
			where	cashier_upload_code = @cashier_upload_code ;

			select	@branch_code = branch_code
					,@branch_name = branch_name
					,@currency_code = currency_code
			from	dbo.agreement_main
			where	agreement_no = @agreement_no ;

			select	@cashier_main_code = code
			from	dbo.cashier_main
			where	cashier_status	= 'open'
					and branch_code = @branch_code ;

			set @remark = 'Penerimaan Cashier Fintech : '+@fintech_name

			select	@total_amount = sum(total_installment_amount) + sum(total_obligation_amount)
			from	dbo.cashier_upload_detail
			where	cashier_upload_code = @cashier_upload_code ;

			select	@exch_rate = sale_rate
			from	ifinsys.dbo.sys_currency_rate
			where	currency_code = @currency_code ;

			set @base_amount = @exch_rate * @total_amount
			
			exec dbo.xsp_cashier_transaction_insert @p_code							= @p_code_cashier_transaction output
													,@p_branch_code					= @branch_code
													,@p_branch_name					= @branch_name
													,@p_cashier_main_code			= @cashier_main_code
													,@p_cashier_status				= N'HOLD' 
													,@p_cashier_trx_date			= @trx_date 
													,@p_cashier_value_date			= @value_date 
													,@p_cashier_type				= N'TRANSFER' 
													,@p_cashier_orig_amount			= @total_amount 
													,@p_cashier_currency_code		= @currency_code
													,@p_cashier_exch_rate			= @exch_rate
													,@p_cashier_base_amount			= @base_amount
													,@p_cashier_remarks				= @remark
													,@p_agreement_no				= @agreement_no
													,@p_deposit_amount				= 0 
													,@p_is_use_deposit				= N'0'
													,@p_deposit_used_amount			= 0
													,@p_received_amount				= 0
													,@p_receipt_code				= null
													,@p_is_received_request			= N'0'
													,@p_card_receipt_reff_no		= null
													,@p_card_bank_name				= null
													,@p_card_account_name			= null
													,@p_branch_bank_code			= @branch_bank_code
													,@p_branch_bank_name			= @branch_bank_name
													,@p_bank_gl_link_code			= @bank_gl_link_code
													,@p_pdc_code					= null
													,@p_pdc_no						= null
													,@p_received_from				= N'CLIENT'
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
													,@p_reff_no						= N''
													,@p_is_reconcile				= N'0'
													,@p_reconcile_date				= null
													--
													,@p_cre_date					= @mod_date
													,@p_cre_by						= @mod_by
													,@p_cre_ip_address				= @mod_ip_address
													,@p_mod_date					= @mod_date
													,@p_mod_by						= @mod_by
													,@p_mod_ip_address				= @mod_ip_address

				update dbo.cashier_transaction
				set cashier_remarks = @remark
				where code = @p_code_cashier_transaction

				declare curr_cashier_upld_dtl cursor fast_forward for
				select	agreement_no
						,total_installment_amount
						,total_obligation_amount
				from	dbo.cashier_upload_detail
				where	cashier_upload_code = @cashier_upload_code ;

				open curr_cashier_upld_dtl ;

				fetch curr_cashier_upld_dtl
				into @agreement_no_detail
					 ,@installment_amount
					 ,@obligation_amount ;

				while @@fetch_status = 0
				begin
						------ Instalment -----
						set @total_sisa_installment_amount = @installment_amount;

						declare @myTampInstalment table
						(
							agreement_no				 nvarchar(50)
							,installment_no				 int
							,agreement_amount_instalment decimal(18, 2)
						) ;

						insert into @myTampInstalment
						(
							agreement_no
							,installment_no
							,agreement_amount_instalment
						)
						exec IFINCORE.dbo.xsp_get_list_instalment_amount @p_agreement_no	= @agreement_no_detail
																		 ,@p_date			= @value_date ;
					
						declare c_instalment cursor fast_forward for
						select	agreement_no
								,installment_no
								,agreement_amount_instalment
						from	@mytampinstalment ;

						open c_instalment ;

						fetch c_instalment
						into @agreement_no_inst
							 ,@installment_no_inst
							 ,@agreement_amount_instalment_inst ;

						while @@fetch_status = 0
						begin
							
							if (@total_sisa_installment_amount >= @agreement_amount_instalment_inst)
							begin
								
								declare @p_id_ins bigint ;

								select	@client_name_inst = client_name
								from	dbo.agreement_main
								where	agreement_no = @agreement_no_inst ;

								select	@exch_rate = sale_rate
								from	ifinsys.dbo.sys_currency_rate
								where	currency_code = @currency_code ;

								set @base_amount = @exch_rate * @agreement_amount_instalment_inst

								set @remark_inst = 'Agreement No : '+ @agreement_no_inst +' Client Name : '+@client_name_inst

								exec dbo.xsp_cashier_transaction_detail_insert @p_id						= @p_id_ins output -- bigint
																			   ,@p_cashier_transaction_code = @p_code_cashier_transaction
																			   ,@p_transaction_code			= N'INST' --- inst dkk
																			   ,@p_received_request_code	= null
																			   ,@p_agreement_no				= @agreement_no_inst
																			   ,@p_is_paid					= N'1' 
																			   ,@p_innitial_amount			= @agreement_amount_instalment_inst --- nilai tagihan
																			   ,@p_orig_amount				= @agreement_amount_instalment_inst --- nilai tagihan
																			   ,@p_orig_currency_code		= @currency_code
																			   ,@p_exch_rate				= @exch_rate --- sale rate
																			   ,@p_base_amount				= @base_amount ---- exchrate * orig
																			   ,@p_installment_no			= @installment_no_inst --- berdasarkan installmen no sendiri 
																			   ,@p_remarks					= @remark_inst
																			   --
																			   ,@p_cre_date					= @mod_date
																			   ,@p_cre_by					= @mod_by
																			   ,@p_cre_ip_address			= @mod_ip_address
																			   ,@p_mod_date					= @mod_date
																			   ,@p_mod_by					= @mod_by
																			   ,@p_mod_ip_address			= @mod_ip_address

								update	dbo.cashier_transaction_detail
								set		is_paid = '1'
								where	id = @p_id_ins;

								set @total_sisa_installment_amount = @total_sisa_installment_amount - @agreement_amount_instalment_inst ;

								
							end ;
							else
							begin
								break ;
							end ;

							
							fetch c_instalment
							into @agreement_no_inst
								,@installment_no_inst
								,@agreement_amount_instalment_inst ;
						end ;

						close c_instalment ;
						deallocate c_instalment ;

						delete @myTampInstalment

						------ Obligation -----
						set @total_sisa_obligation_amount = @obligation_amount;

						declare @myTampObligation table
						(
							agreement_no	  nvarchar(50)
							,installment_no	  int
							,agreement_amount decimal(18, 2)
							,obligation_type  nvarchar(50)
							,obligation_date  datetime
						) ;

						insert into @myTampObligation
						(
							agreement_no
							,installment_no
							,agreement_amount
							,obligation_type
							,obligation_date
						)
						exec IFINCORE.dbo.xsp_get_list_obligation_amount @p_agreement_no		= @agreement_no_detail
																		 ,@p_obligation_type	= N'OVDP'
																		 ,@p_date				= @value_date
						
						declare c_obligation cursor fast_forward for
						select	agreement_no
								,installment_no
								,agreement_amount
								,obligation_type
								,obligation_date
						from	@myTampObligation ;

						open c_obligation ;

						fetch c_obligation
						into @agreement_no_obli
							 ,@installment_no_obli
							 ,@agreement_amount_obli
							 ,@obligation_type_obli
							 ,@obligation_date_obli ;

						while @@fetch_status = 0
						begin
							
							if(@total_sisa_obligation_amount >= @agreement_amount_obli)
							begin
								declare @p_id_obli bigint ;

								select	@client_name_obli = client_name
								from	dbo.agreement_main
								where	agreement_no = @agreement_no_obli ;

								select	@exch_rate = sale_rate
								from	ifinsys.dbo.sys_currency_rate
								where	currency_code = @currency_code ;

								set @base_amount = @exch_rate * @agreement_amount_obli

								set @remark_obli = 'Agreement No : '+ @agreement_no_obli +' Client Name : '+@client_name_obli
								
								exec dbo.xsp_cashier_transaction_detail_insert @p_id						= @p_id_obli output
																			   ,@p_cashier_transaction_code = @p_code_cashier_transaction
																			   ,@p_transaction_code			= N'OVDP'
																			   ,@p_received_request_code	= null
																			   ,@p_agreement_no				= @agreement_amount_obli
																			   ,@p_is_paid					= N'1'
																			   ,@p_innitial_amount			= @agreement_amount_obli
																			   ,@p_orig_amount				= @agreement_amount_obli
																			   ,@p_orig_currency_code		= @currency_code
																			   ,@p_exch_rate				= @exch_rate
																			   ,@p_base_amount				= @base_amount
																			   ,@p_installment_no			= @installment_no_obli
																			   ,@p_remarks					= @remark_obli
																			   --
																			   ,@p_cre_date					= @mod_date
																			   ,@p_cre_by					= @mod_by
																			   ,@p_cre_ip_address			= @mod_ip_address
																			   ,@p_mod_date					= @mod_date
																			   ,@p_mod_by					= @mod_by
																			   ,@p_mod_ip_address			= @mod_ip_address

								update	dbo.cashier_transaction_detail
								set		is_paid = '1'
								where	id = @p_id_obli;

								set @total_sisa_obligation_amount = @total_sisa_obligation_amount - @agreement_amount_obli

								
							end
							else
							begin
								break;
							end
							fetch c_obligation
							into @agreement_no_obli
									,@installment_no_obli
									,@agreement_amount_obli
									,@obligation_type_obli
									,@obligation_date_obli ;
						end ;

						close c_obligation ;
						deallocate c_obligation ;

						delete @myTampObligation

					

					------ Deposit -----
					
					set @deposit = @total_sisa_installment_amount + @total_sisa_obligation_amount;
					
					if(@deposit > 0)
					begin
						declare @p_id_depo bigint ;

						select	@client_name_dpt = client_name
						from	dbo.agreement_main
						where	agreement_no = @agreement_no_detail ;

						select	@exch_rate = sale_rate
						from	ifinsys.dbo.sys_currency_rate
						where	currency_code = @currency_code ;

						set @base_amount = @exch_rate * @deposit

						set @remark_dpt = 'Agreement No : '+ @agreement_no_detail +' Client Name : '+@client_name_dpt
					
						exec dbo.xsp_cashier_transaction_detail_insert @p_id						= @p_id_depo output
																	   ,@p_cashier_transaction_code	= @p_code_cashier_transaction
																	   ,@p_transaction_code			= N'DPINST'
																	   ,@p_received_request_code	= null
																	   ,@p_agreement_no				= @agreement_no_detail
																	   ,@p_is_paid					= N'1'
																	   ,@p_innitial_amount			= @deposit
																	   ,@p_orig_amount				= @deposit
																	   ,@p_orig_currency_code		= @currency_code
																	   ,@p_exch_rate				= @exch_rate
																	   ,@p_base_amount				= @base_amount
																	   ,@p_installment_no			= null
																	   ,@p_remarks					= @remark_dpt
																	   --
																	   ,@p_cre_date					= @mod_date
																	   ,@p_cre_by					= @mod_by
																	   ,@p_cre_ip_address			= @mod_ip_address
																	   ,@p_mod_date					= @mod_date
																	   ,@p_mod_by					= @mod_by
																	   ,@p_mod_ip_address			= @mod_ip_address
					
						update	dbo.cashier_transaction_detail
						set		is_paid = '1'
						where	id = @p_id_depo;

					end

					fetch curr_cashier_upld_dtl
					into @agreement_no_detail
						 ,@installment_amount
						 ,@obligation_amount ;
				end ;

				close curr_cashier_upld_dtl ;
				deallocate curr_cashier_upld_dtl ;

				

				exec dbo.xsp_cashier_transaction_paid @p_code				= @p_code_cashier_transaction
													  ,@p_cre_date			= @mod_date
													  ,@p_cre_by			= @mod_by
													  ,@p_cre_ip_address	= @mod_ip_address
													  ,@p_mod_date			= @mod_date
													  ,@p_mod_by			= @mod_by
													  ,@p_mod_ip_address	= @mod_ip_address

				update	dbo.cashier_upload_main
				set		status = 'PAID'
						,reff_no = @p_code_cashier_transaction
				where	code = @cashier_upload_code ;

			fetch curr_cashier_upld
			into @cashier_upload_code
				 ,@value_date
				 ,@trx_date
				 ,@branch_bank_code
				 ,@branch_bank_name
				 ,@bank_gl_link_code
				 ,@fintech_name ;

		end ;

		close curr_cashier_upld ;
		deallocate curr_cashier_upld ;

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
