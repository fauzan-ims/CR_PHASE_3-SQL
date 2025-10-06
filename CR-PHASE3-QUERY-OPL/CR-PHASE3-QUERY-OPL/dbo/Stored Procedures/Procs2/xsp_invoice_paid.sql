CREATE PROCEDURE dbo.xsp_invoice_paid
(
	@p_invoice_no				nvarchar(50)
	,@p_payment_date			datetime
	,@p_transaction_no			nvarchar(50)
	,@p_voucher_no				nvarchar(50)
	,@p_process_reff_name		nvarchar(250) = ''
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
			set		invoice_status		= 'PAID'
					,received_reff_date	= @p_payment_date
					--
					,mod_date		= @p_mod_date
					,mod_ip_address	= @p_mod_ip_address
					,mod_by			= @p_mod_by
			where	invoice_no		= @p_invoice_no
			
			if exists
			(
				select	1
				from	dbo.agreement_invoice
				where	invoice_no = @p_invoice_no
			)
			begin
				exec dbo.xsp_agreement_invoice_payment_paid @p_invoice_no			= @p_invoice_no
															,@p_payment_date		= @p_payment_date
															,@p_transaction_no		= @p_transaction_no
															,@p_voucher_no			= @p_voucher_no
															--
															,@p_mod_date			= @p_mod_date
															,@p_mod_by				= @p_mod_by
															,@p_mod_ip_address		= @p_mod_ip_address
			end ;
		
			if (isnull(@additional_invoice_code, '') <> '')
			begin
				exec dbo.xsp_additional_invoice_request_update @p_code			  = @additional_invoice_code
															   ,@p_status		  = N'PAID'
															   ,@p_mod_date		  = @p_mod_date
															   ,@p_mod_by		  = @p_mod_by
															   ,@p_mod_ip_address = @p_mod_ip_address
				
				if (@invoice_type IN ('PENALTY','LATERETURN','LATE RETURN')) -- raffy (2025/08/07) CR Fase 3
				begin
					declare	c_invoice	cursor for
						select	agreement_no
								,asset_no
								,billing_amount
						from	dbo.invoice_detail
						where	invoice_no = @p_invoice_no ;

					open	c_invoice
					fetch	c_invoice
					into	@agreement_no
							,@asset_no
							,@billing_amount

					while	@@fetch_status = 0
					begin
						if exists
						(
							select	1
							from	dbo.agreement_obligation ago
							where	ago.agreement_no		= @agreement_no
									and ago.asset_no		= @asset_no
									and ago.obligation_type in('CETP','LRAP')
						)
						begin
							insert into dbo.agreement_obligation_payment
							(
								obligation_code
								,agreement_no
								,asset_no
								,invoice_no
								,installment_no
								,payment_date
								,value_date
								,payment_source_type
								,payment_source_no
								,payment_amount
								,is_waive
								--
								,cre_date
								,cre_by
								,cre_ip_address
								,mod_date
								,mod_by
								,mod_ip_address
							)
							select	ago.code
									,ago.agreement_no
									,ago.asset_no
									,ago.invoice_no
									,ago.installment_no
									,@p_payment_date
									,@p_payment_date
									,@p_process_reff_name
									,@p_transaction_no
									,@billing_amount
									,'0'
									--
									,@p_mod_date
									,@p_mod_by
									,@p_mod_ip_address
									,@p_mod_date
									,@p_mod_by
									,@p_mod_ip_address
							from	dbo.agreement_obligation ago
							where	ago.agreement_no		= @agreement_no
									and ago.asset_no		= @asset_no
									and ago.obligation_type IN('CETP','LRAP') ;
						end ;
					fetch	c_invoice
					into	@agreement_no
							,@asset_no
							,@billing_amount
					end

					close		c_invoice
					deallocate	c_invoice
				end
			end

			---- Louis Selasa, 18 Juni 2024 15.41.17 -- jika semua invoice pada agreement sudah digenerate/ ditagih dan sudah dibayar semua update sub status menjadi COMPLETE
			begin
			    exec dbo.xsp_agreement_update_sub_status @p_invoice_no		= @p_invoice_no
			    										 ,@p_is_paid		= N'1'
			    										 ,@p_mod_date		= @p_mod_date
			    										 ,@p_mod_by			= @p_mod_by
			    										 ,@p_mod_ip_address = @p_mod_ip_address
			    
			end
			
			---- Louis Senin, 29 April 2024 20.44.20 ----recalculate obligation
			begin
				declare currobligation cursor fast_forward read_only for
				select	agreement_no
						,asset_no
				from	dbo.invoice_detail with (nolock)
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
			 
			---- update agreement status if all installment for all asset already paid
			begin
				declare currInvoiceDetail cursor fast_forward read_only for
				select	distinct agreement_no
				from	dbo.invoice_detail with (nolock)
				where	invoice_no = @p_invoice_no ;

				open currInvoiceDetail ;

				fetch next from currInvoiceDetail
				into @agreement_no ;

				while @@fetch_status = 0
				begin
					exec dbo.xsp_agreement_main_update_terminate_status @p_agreement_no		 = @agreement_no
																		,@p_termination_date = @p_payment_date
																	    --
																	    ,@p_mod_date		 = @p_mod_date
																	    ,@p_mod_by			 = @p_mod_by
																	    ,@p_mod_ip_address	 = @p_mod_ip_address ;
																		

					-- Louis Senin, 05 Februari 2024 11.21.04 -- penambahan fungsing untuk hitung ulang agreement information
					begin

						exec dbo.xsp_agreement_information_update @p_agreement_no		= @agreement_no
																  ,@p_mod_date			= @p_mod_date
																  ,@p_mod_by			= @p_mod_by
																  ,@p_mod_ip_address	= @p_mod_ip_address ;
				
					end

					fetch next from currInvoiceDetail
					into @agreement_no ;
				end ;

				close currInvoiceDetail ;
				deallocate currInvoiceDetail ;
			end

			--push ke income ledger
			begin
				declare currincome cursor fast_forward read_only for
				--select	idt.agreement_no
				--		,isnull(asat.fa_code, asat.replacement_fa_code)
				--		,dbo.xfn_get_system_date()
				--		,idt.invoice_no
				--		,'Rent'
				--		,idt.description
				--		,idt.billing_amount
				--		,inv.client_name
				--from	dbo.invoice_detail idt
				--		inner join invoice inv on inv.invoice_no			= idt.invoice_no
				--		left join agreement_asset asat on asat.agreement_no = idt.agreement_no
				--where	idt.invoice_no = @p_invoice_no ;
				select	idt.agreement_no
						,asat.asset_code
						,dbo.xfn_get_system_date()
						,idt.invoice_no
						,'Rent'
						,idt.description
						,idt.billing_amount
						,inv.client_name
				from	dbo.invoice_detail idt with (nolock)
						inner join invoice inv with (nolock) on inv.invoice_no = idt.invoice_no
						outer apply
						(
							select	isnull(asat.fa_code, asat.replacement_fa_code) asset_code
							from	agreement_asset asat with (nolock)
							where	asat.agreement_no = idt.agreement_no
									and idt.ASSET_NO  = asat.ASSET_NO
						) asat
				where	idt.invoice_no = @p_invoice_no and isnull(asat.asset_code, '') <> '';

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







