CREATE PROCEDURE [dbo].[xsp_invoice_reversal]
(
	@p_invoice_no				nvarchar(50)
	,@p_payment_date			datetime
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)

as
begin
	declare @msg						nvarchar(max)
			,@additional_invoice_code	nvarchar(50) 
			,@invoice_type				nvarchar(50)
			,@agreement_no				nvarchar(50)
			,@asset_no					nvarchar(50)
			,@billing_amount			decimal(18,2)
			,@agreement_no_2			nvarchar(50)
			,@asset_code				nvarchar(50)
			,@date						datetime
			,@reff_code					nvarchar(50)
			,@reff_name					nvarchar(250)
			,@reff_remark				nvarchar(4000)
			,@income_amount				decimal(18,2)
			,@client_name				nvarchar(250)
			,@job_status				nvarchar(250)
			,@failed_remark				nvarchar(250)
			,@invoice_no				nvarchar(50)
	
	begin try
		begin 
			select	@additional_invoice_code	= additional_invoice_code
					,@invoice_type				= invoice_type
			from	dbo.invoice
			where	invoice_no = @p_invoice_no ;
			
			update	dbo.invoice
			set		invoice_status		= 'POST'
					,received_reff_date	= null
					--
					,mod_date		= @p_mod_date
					,mod_ip_address	= @p_mod_ip_address
					,mod_by			= @p_mod_by
			where	invoice_no		= @p_invoice_no
			 
			--delete dbo.agreement_invoice_payment
			--where	invoice_no = @p_invoice_no ;
			
			--insert into invoice payment
			begin 
				insert into dbo.agreement_invoice_payment
				(
					agreement_invoice_code
					,invoice_no
					,agreement_no
					,asset_no
					,transaction_no
					,transaction_type
					,payment_date
					,payment_amount
					,voucher_no
					,description
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
					,mf_payment_amount
				)
				select		agreement_invoice_code
							,invoice_no
							,agreement_no
							,asset_no
							,transaction_no
							,'INVOICE REVERSAL'
							,dbo.xfn_get_system_date()
							,sum(payment_amount) * -1
							,voucher_no
							,'INVOICE PAYMENT REVERSAL'
							,@p_mod_date
							,@p_mod_by
							,@p_mod_ip_address
							,@p_mod_date
							,@p_mod_by
							,@p_mod_ip_address
							,0
				from		dbo.agreement_invoice_payment
				where		invoice_no			 = @p_invoice_no
							and transaction_type in (N'INVOICE REVERSAL', N'CASHIER')

				group by	agreement_invoice_code
							,invoice_no
							,agreement_no
							,asset_no
							,transaction_no
							,voucher_no ;
			end
		
			if (isnull(@additional_invoice_code, '') <> '')
			begin
				exec dbo.xsp_additional_invoice_request_update @p_code			  = @additional_invoice_code
															   ,@p_status		  = N'HOLD'
															   ,@p_mod_date		  = @p_mod_date
															   ,@p_mod_by		  = @p_mod_ip_address
															   ,@p_mod_ip_address = @p_mod_by
				
				if (@invoice_type = 'PENALTY')
				begin
						delete dbo.agreement_obligation_payment
						where	invoice_no = @p_invoice_no
				end

			end
		
			---- update agreement status if all installment for all asset already paid
			--begin
			--	declare currInvoiceDetail cursor fast_forward read_only FOR
                
			--	select	distinct agreement_no
			--	from	dbo.invoice_detail
			--	where	invoice_no = @p_invoice_no ;

			--	open currInvoiceDetail ;

			--	fetch next from currInvoiceDetail
			--	into @agreement_no ;

			--	while @@fetch_status = 0
			--	begin
			--		EXEC dbo.xsp_agreement_main_update_terminate_status_reversal	@p_agreement_no		 = @agreement_no
			--																		--
			--																		,@p_mod_date		 = @p_mod_date
			--																		,@p_mod_by			 = @p_mod_ip_address
			--																		,@p_mod_ip_address	 = @p_mod_by ;

			--		fetch next from currInvoiceDetail
			--		into @agreement_no ;
			--	end ;

			--	close currInvoiceDetail ;
			--	deallocate currInvoiceDetail ;
			--end
				
			--push ke income ledger dengan nilai min karena pengurangan
			begin
				declare currincome cursor fast_forward read_only for
				select	idt.agreement_no									
						,isnull(asat.fa_code, asat.replacement_fa_code)
						,dbo.xfn_get_system_date()
						,idt.invoice_no
						,'Rent'
						,'Reversal ' + idt.description
						,idt.billing_amount * -1
						,inv.client_name
				from	dbo.invoice_detail idt
						inner join invoice inv on inv.invoice_no			= idt.invoice_no
						left join agreement_asset asat on asat.agreement_no = idt.agreement_no
				where	idt.invoice_no = @p_invoice_no ;

				open currincome ;

				fetch next from currincome
				into @agreement_no_2
					 ,@asset_code
					 ,@date
					 ,@invoice_no
					 ,@reff_name
					 ,@reff_remark
					 ,@income_amount
					 ,@client_name ;

				while @@fetch_status = 0
				begin
					
						
					exec dbo.xsp_opl_interface_income_ledger_insert @p_asset_code				= @asset_code
																	,@p_date					= @date
																	,@p_reff_code				= @invoice_no
																	,@p_reff_name				= @reff_name
																	,@p_reff_remark				= @reff_remark
																	,@p_income_amount			= @income_amount
																	,@p_agreement_no			= @agreement_no_2
																	,@p_client_name				= @client_name
																	,@p_job_status				= 'HOLD'
																	,@p_failed_remark			= ''
																	,@p_cre_date				= @p_mod_date
																	,@p_cre_by					= @p_mod_by
																	,@p_cre_ip_address			= @p_mod_ip_address
																	,@p_mod_date				= @p_mod_date
																	,@p_mod_by					= @p_mod_by
																	,@p_mod_ip_address			= @p_mod_ip_address ;
					

					fetch next from currincome
					into @agreement_no_2
						 ,@asset_code
						 ,@date
						 ,@invoice_no
						 ,@reff_name
						 ,@reff_remark
						 ,@income_amount
						 ,@client_name ;
				end ;

				close currincome ;
				deallocate currincome ;
			end
			
			-- Louis Senin, 29 April 2024 20.43.51 ----recalculate obligation
			begin
				declare currobligation cursor fast_forward read_only for
				select	agreement_no
						,asset_no
				from	dbo.invoice_detail
				where	invoice_no = @p_invoice_no ;

				open currObligation ;

				fetch next from currObligation
				into @agreement_no
					 ,@asset_no ;

				while @@fetch_status = 0
				begin
					exec dbo.xsp_calculate_overdue_penalty_per_agreement_update @p_agreement_no		= @agreement_no
																				,@p_invoice_no		= @p_invoice_no
																				,@p_asset_no		= @asset_no
																				,@p_payment_date	= @p_payment_date
																				,@p_mod_date		= @p_mod_date
																				,@p_mod_by			= @p_mod_by
																				,@p_mod_ip_address	= @p_mod_ip_address ;

					fetch next from currObligation
					into @agreement_no
						 ,@asset_no ;
				end ;

				close currObligation ;
				deallocate currObligation ;
			end

			-- Louis Selasa, 18 Juni 2024 15.41.17 -- jika direversal update sub status menjadi INCOMPLETE
			begin
			    exec dbo.xsp_agreement_update_sub_status @p_invoice_no		= @p_invoice_no
			    										 ,@p_is_paid		= N'0'
			    										 ,@p_mod_date		= @p_mod_date
			    										 ,@p_mod_by			= @p_mod_by
			    										 ,@p_mod_ip_address = @p_mod_ip_address
			    
			end

			-- Louis Senin, 05 Februari 2024 11.21.04 -- penambahan fungsing untuk hitung ulang agreement information
			begin
				declare currInvoiceDetail cursor fast_forward read_only for
				select	distinct agreement_no
				from	dbo.invoice_detail
				where	invoice_no = @p_invoice_no ;

				open currInvoiceDetail ;

				fetch next from currInvoiceDetail
				into @agreement_no ;

				while @@fetch_status = 0
				begin  
				 
						exec dbo.xsp_agreement_information_update @p_agreement_no		= @agreement_no
																  ,@p_mod_date			= @p_mod_date
																  ,@p_mod_by			= @p_mod_by
																  ,@p_mod_ip_address	= @p_mod_ip_address ;

					fetch next from currInvoiceDetail
					into @agreement_no ;
				end ;

				close currInvoiceDetail ;
				deallocate currInvoiceDetail ;
			end
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







