CREATE PROCEDURE [dbo].[xsp_invoice_cancel_paid]
(
	@p_invoice_no		nvarchar(50)
	--
	,@p_mod_date	    datetime
	,@p_mod_by		    nvarchar(15)
	,@p_mod_ip_address  nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max)
			,@additional_invoice_code	nvarchar(50) 
			,@agreement_no				nvarchar(50)

	begin try

		if exists
		(
			select	1
			from	dbo.invoice
			where	invoice_no			= @p_invoice_no
					and invoice_status	= 'POST'
		)
		begin
			select	@additional_invoice_code = additional_invoice_code
			from	dbo.invoice
			where	invoice_no = @p_invoice_no ;

			--delete dbo.agreement_invoice
			--where	invoice_no = @p_invoice_no ;

			delete dbo.agreement_invoice_pph
			where	invoice_no = @p_invoice_no ;

			delete dbo.invoice_pph
			where	invoice_no = @p_invoice_no ;

			--delete dbo.agreement_asset_interest_income
			--where	invoice_no = @p_invoice_no ;
			
			begin
				update	dbo.agreement_invoice
				set		description		= 'CANCEL ' + description

						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	invoice_no		= @p_invoice_no ;

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
				select	code
						,invoice_no
						,agreement_no
						,asset_no
						,billing_no
						,'INVOICE CANCEL'
						,@p_mod_date
						,ar_amount - isnull(payment_amount, 0) -- hari 2024/01/26 -- insert ke tabel payment selalu positif
						,null
						,'INVOICE CANCEL'
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address 
						,0
				from	dbo.agreement_invoice ai
						outer apply
						(
							select	isnull(sum(isnull(aip.payment_amount, 0)), 0) payment_amount
							from	dbo.agreement_invoice_payment aip
							where	aip.agreement_invoice_code = ai.code
						) aip
						where	invoice_no = @p_invoice_no ;
			end

			-- journal cancel Invoice
			begin
				if not exists (select 1 from dbo.invoice where invoice_no = @p_invoice_no and invoice_type = 'PENALTY')
				begin
					exec dbo.xsp_invoice_cancel_journal @p_reff_name		= 'INVOICE CANCEL'
														,@p_reff_code		= @p_invoice_no
														,@p_value_date		= @p_mod_date
														,@p_trx_date		= @p_mod_date
														,@p_mod_date		= @p_mod_date
														,@p_mod_by			= @p_mod_by
														,@p_mod_ip_address	= @p_mod_ip_address
				end
			end
		
			-- journal reverse accrue income jika agreement ADVANCE
			begin
				if exists
				(
					select	1
					from	dbo.agreement_asset aa
							inner join dbo.invoice_detail invd on (invd.asset_no = aa.asset_no)
					where	invd.invoice_no			  = @p_invoice_no
							and aa.first_payment_type = 'ADV'
				)
				begin
					if exists (
							select	sum(income_amount_1)
							from	dbo.agreement_asset_interest_income
							where	invoice_no	   = @p_invoice_no
							and		status_accrue	= 'ACCRUED'
							and		income_amount_1 > 0
					   )
					BEGIN

						exec dbo.xsp_invoice_cancel_journal_accrue_income	@p_reff_name		= 'REVERSE ACCRUE INVOICE'
																			,@p_reff_code		= @p_invoice_no
																			,@p_value_date		= @p_mod_date
																			,@p_trx_date		= @p_mod_date
																			,@p_mod_date		= @p_mod_date
																			,@p_mod_by			= @p_mod_by
																			,@p_mod_ip_address	= @p_mod_ip_address ;
					end ;
				end ;
			end ;

			update dbo.agreement_asset_amortization
			set	generate_code	= null
				,invoice_no		= null
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
			where invoice_no	= @p_invoice_no

			update	dbo.invoice
			set		invoice_status	= 'CANCEL'
					,received_reff_no = 'CANCEL CASHIER' -- 20231202 - hari - pembatalan invoice sebagai flaging di invoice
					,received_reff_date = @p_mod_date
					--,CANCEL_DATE = @p_mod_date
					--,CANCEL_BY = @p_mod_by
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	invoice_no		= @p_invoice_no ; 


			if (isnull(@additional_invoice_code, '') <> '')
			begin
				exec dbo.xsp_additional_invoice_request_update @p_code			   = @additional_invoice_code
																,@p_status		   = N'HOLD'
																,@p_mod_date	   = @p_mod_date
																,@p_mod_by		   = @p_mod_ip_address
																,@p_mod_ip_address = @p_mod_by
				
			end 
			
			if exists
			(
				select	1
				from	dbo.agreement_obligation
				where	invoice_no = @p_invoice_no
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
				select	code
						,agreement_no
						,asset_no
						,invoice_no
						,installment_no
						,dbo.xfn_get_system_date()
						,dbo.xfn_get_system_date()
						,'INVOICE CANCEL'
						,'INVOICE CANCEL'
						,obligation_amount
						,'0'
						--
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
				from	dbo.agreement_obligation
				where	invoice_no = @p_invoice_no ;
			end ;
			
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
		end ;
		else
		begin
			set @msg = 'Data already process';
			raiserror(@msg, 16, 1) ;
		end ;
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


