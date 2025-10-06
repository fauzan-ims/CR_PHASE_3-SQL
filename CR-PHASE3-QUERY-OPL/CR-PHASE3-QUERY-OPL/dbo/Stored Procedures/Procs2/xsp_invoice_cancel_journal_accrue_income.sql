CREATE PROCEDURE [dbo].[xsp_invoice_cancel_journal_accrue_income]
(
	@p_reff_name				nvarchar(50)
	,@p_reff_code				nvarchar(50)
	,@p_value_date				datetime
	,@p_trx_date				datetime
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)

as
begin
	declare @msg					nvarchar(max)
			,@gllink_trx_code		nvarchar(50)
			,@branch_code			nvarchar(50)
			,@branch_name			nvarchar(250)
			,@agreement_branch_code nvarchar(50)
			,@agreement_branch_name nvarchar(250)
			,@gl_link_code			nvarchar(50)
			,@debet_or_credit		nvarchar(10)
			,@currency				nvarchar(3)
			,@agreement_no			nvarchar(50)
			,@orig_amount_db		decimal(18, 2)
			,@orig_amount_cr		decimal(18, 2)
			,@transaction_name		nvarchar(250)
			,@sp_name				nvarchar(250)
			,@return_value			decimal(18, 2)
			,@invoice_detail_id		bigint
			,@invoice_external_no	nvarchar(50)
			,@client_name			nvarchar(250)
			,@periode				nvarchar(6)
			,@asset_no				nvarchar(50)
			,@is_journal			nvarchar(50)
			,@description			nvarchar(4000) 
			,@facility_code		    nvarchar(50)
			,@facility_name		    nvarchar(250)
			,@income_name		    nvarchar(250)
			,@income_amount		    decimal(18, 2)
			,@installment_no		int

	
	begin try
		select	@branch_code			= branch_code
				,@branch_name			= branch_name
				,@currency				= currency_code
				,@invoice_external_no	= invoice_external_no
				,@client_name			= client_name
				,@periode				= cast(year(invoice_due_date) as nvarchar(4)) + cast(month(invoice_due_date) as nvarchar(4))
				,@p_trx_date			= dbo.xfn_get_system_date() --invoice_date -- 	-- Hari - 31.Oct.2023 09:34 AM --	tanggal journal di ambil dari system date
				,@p_value_date			= invoice_date
				,@is_journal			= is_journal
		from dbo.invoice
		where invoice_no = @p_reff_code
		
		set @transaction_name = @p_reff_name + ' For : ' + @invoice_external_no + ' - ' + @client_name --+ '. Periode : ' + @periode

		exec dbo.xsp_opl_interface_journal_gl_link_transaction_insert	@p_code						= @gllink_trx_code output
																		,@p_branch_code				= @branch_code
																		,@p_branch_name				= @branch_name
																		,@p_transaction_status		= 'HOLD'
																		,@p_transaction_date		= @p_trx_date
																		,@p_transaction_value_date	= @p_value_date
																		,@p_transaction_code		= @p_reff_code
																		,@p_transaction_name		= @p_reff_name
																		,@p_reff_module_code		= 'IFINOPL'
																		,@p_reff_source_no			= @p_reff_code
																		,@p_reff_source_name		= @transaction_name
																		,@p_cre_date				= @p_mod_date
																		,@p_cre_by					= @p_mod_by
																		,@p_cre_ip_address			= @p_mod_ip_address
																		,@p_mod_date				= @p_mod_date
																		,@p_mod_by					= @p_mod_by
																		,@p_mod_ip_address			= @p_mod_ip_address
		
		begin
		
				declare c_jurnal_detail cursor local fast_forward read_only for
				select	aaii.agreement_no
						--,sum(isnull(aaii.income_amount_1, 0)) --(sepria 09-07-2024: penambahan kolom ini untuk mengcover perubahan konsep income yg dari post reverse jadi post saja untuk report dwh)
						,mtp.gl_link_code
						,mtp.debet_or_credit
						,am.currency_code
						,am.facility_code
						,am.facility_name
						,mt.transaction_name
						,aaii.asset_no
						,aaii.billing_no
				from	dbo.invoice_detail aaii
						inner join dbo.master_transaction_parameter mtp on (mtp.process_code = 'INTEREST')
						inner join dbo.master_transaction mt on (mt.code					 = mtp.transaction_code)
						inner join dbo.agreement_main am on (am.agreement_no				 = aaii.agreement_no)
				where	aaii.invoice_no = @p_reff_code

				open c_jurnal_detail ;

				fetch c_jurnal_detail
				into @agreement_no
					 --,@income_amount
					 ,@gl_link_code
					 ,@debet_or_credit
					 ,@currency
					 ,@facility_code
					 ,@facility_name
					 ,@transaction_name
					 ,@asset_no
					 ,@installment_no

				while @@fetch_status = 0
				begin

					select	@income_amount = sum(income_amount_1)
					from	dbo.agreement_asset_interest_income
					where	invoice_no		 = @p_reff_code
							and agreement_no = @agreement_no
							and asset_no	 = @asset_no 
							and status_accrue = 'ACCRUED'
							and	income_amount_1 > 0
					
					if (right(isnull(abs(@income_amount), '00'), 2) <> '00')
					begin
						set @msg = 'Data Kriting';
						raiserror(@msg, 16, -1);
					end

					if (@debet_or_credit = 'DEBIT')
					begin
						set @orig_amount_db = abs(@income_amount) ;
						set @orig_amount_cr = 0 ;
					end ;
					else
					begin
						set @orig_amount_db = 0 ;
						set @orig_amount_cr = abs(@income_amount) ;
					end ;

					select	@agreement_branch_code = branch_code
							,@agreement_branch_name = branch_name
					from	dbo.agreement_main
					where	agreement_no = @agreement_no ;

					--set @transaction_name = upper(@income_name) + ' For Invoice No : ' + @invoice_external_no + ', Asset No : ' + @asset_no + ', and Billing No : ' + cast(@installment_no as nvarchar(10)) ;

					if (abs(@income_amount) > 0)
					begin
											 
						begin 
							set @transaction_name = 'REVERSE ' + upper('INVOICE ACCRUE INTEREST INCOME') + ' For Invoice No : ' + @invoice_external_no + ', Asset No : ' + @asset_no + ', and Billing No : ' + cast(@installment_no as nvarchar(10)) ;

							exec dbo.xsp_opl_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code	 = @gllink_trx_code
																									,@p_branch_code				 = @agreement_branch_code
																									,@p_branch_name				 = @agreement_branch_name
																									,@p_gl_link_code			 = @gl_link_code
																									,@p_agreement_no			 = @agreement_no
																									,@p_facility_code			 = @facility_code			
																									,@p_facility_name			 = @facility_name			
																									,@p_purpose_loan_code		 = null
																									,@p_purpose_loan_name		 = null
																									,@p_purpose_loan_detail_code = null
																									,@p_purpose_loan_detail_name = null
																									,@p_orig_currency_code		 = @currency
																									,@p_orig_amount_db			 = @orig_amount_cr
																									,@p_orig_amount_cr			 = @orig_amount_db
																									,@p_exch_rate				 = 1
																									,@p_base_amount_db			 = @orig_amount_cr
																									,@p_base_amount_cr			 = @orig_amount_db
																									,@p_division_code			 = ''
																									,@p_division_name			 = ''
																									,@p_department_code			 = ''
																									,@p_department_name			 = ''
																									,@p_remarks					 = @transaction_name
																									,@p_add_reff_01				 = @p_reff_code
																									,@p_add_reff_02				 = ''
																									,@p_add_reff_03				 = ''
																									--
																									,@p_cre_date				 = @p_mod_date		
																									,@p_cre_by					 = @p_mod_by			
																									,@p_cre_ip_address			 = @p_mod_ip_address	
																									,@p_mod_date				 = @p_mod_date		
																									,@p_mod_by					 = @p_mod_by			
																									,@p_mod_ip_address			 = @p_mod_ip_address	
						end
					end ;

					set @transaction_name = ''

					fetch c_jurnal_detail
					into @agreement_no
							--,@income_amount
						 ,@gl_link_code
						 ,@debet_or_credit
						 ,@currency
						 ,@facility_code
						 ,@facility_name
						 ,@transaction_name
						 ,@asset_no
						 ,@installment_no
				end ;

				close c_jurnal_detail ;
				deallocate c_jurnal_detail ;

		end

		-- balancing
		begin
			if ((
					select	sum(orig_amount_db) - sum(orig_amount_cr)
					from	dbo.opl_interface_journal_gl_link_transaction_detail
					where	gl_link_transaction_code = @gllink_trx_code
				) <> 0
				)
			begin
				set @msg = 'Journal is not balance' ;

				raiserror(@msg, 16, -1) ;
			end ;
		end

	end try
	Begin catch
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


