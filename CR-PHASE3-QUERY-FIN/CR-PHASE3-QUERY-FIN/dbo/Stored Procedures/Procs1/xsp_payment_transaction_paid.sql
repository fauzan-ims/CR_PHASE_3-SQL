CREATE PROCEDURE [dbo].[xsp_payment_transaction_paid]
(
	@p_code					NVARCHAR(50)
	--
	,@p_cre_date			DATETIME
	,@p_cre_by				NVARCHAR(15)
	,@p_cre_ip_address		NVARCHAR(15)
	,@p_mod_date			DATETIME
	,@p_mod_by				NVARCHAR(15)
	,@p_mod_ip_address		NVARCHAR(15)
)
AS
begin
	declare	@msg							nvarchar(max)
			,@gl_link_code					nvarchar(50)
			,@agreement_no					nvarchar(50)
			,@bank_mutation_code			nvarchar(50)
			,@gl_link_transaction_code		nvarchar(50)
			,@payment_request_code			nvarchar(50)
			,@suspend_release_code			nvarchar(50)
			,@deposit_release_code			nvarchar(50)
			,@payment_base_amount			decimal(18, 2)
			,@payment_orig_amount			decimal(18, 2)
			,@payment_exch_rate				decimal(18, 6)
			,@exch_rate						decimal(18, 6)
			,@orig_amount					decimal(18, 2)
			,@base_amount					decimal(18, 2)
			,@base_amount_db				decimal(18, 2)
			,@base_amount_cr				decimal(18, 2)
			,@orig_amount_db				decimal(18, 2)
			,@orig_amount_cr				decimal(18, 2)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@branch_code_detail			nvarchar(50)
			,@branch_name_detail			nvarchar(250)
			,@division_code					nvarchar(50)
			,@division_name					nvarchar(250)
			,@department_code				nvarchar(50)
			,@department_name				nvarchar(250)
			,@reff_source_name				nvarchar(250)
			,@bank_gl_link_code				nvarchar(50)
			,@branch_bank_code				nvarchar(50)
			,@branch_bank_name				nvarchar(250)
			,@payment_source				nvarchar(50)
			,@payment_transaction_date		datetime
			,@payment_value_date			datetime
			,@payment_orig_currency_code	nvarchar(3)
			,@orig_currency_code			nvarchar(3)
			,@payment_remarks				nvarchar(4000)
			,@remarks						nvarchar(4000)
			,@index							int = 0 
			,@tax_payer_reff_code			nvarchar(50)
			,@tax_type						nvarchar(5)
			,@tax_file_no					nvarchar(15)
			,@tax_file_name					nvarchar(250)
		    ,@tax_amount					decimal(18, 2)
		    ,@tax_pct						decimal(9, 6)
			,@payment_amount				decimal(18, 2)
			,@tax_percent					decimal(9, 6)
			,@payable_code					nvarchar(50)
			,@ap_amount						decimal(18, 2)
			,@ap_code						nvarchar(50)
			,@payment_to					nvarchar(250)
			,@payment_request				nvarchar(50)
			,@exch_rate_request				decimal(18, 6)
			,@total_tax_amount				decimal(18, 6)
			,@branch_bank					nvarchar(50)
			,@ext_pph_type					nvarchar(20)
			,@ext_vendor_code				nvarchar(50)
			,@ext_vendor_name				nvarchar(250)
			,@ext_vendor_npwp				nvarchar(20)
			,@ext_vendor_address			nvarchar(4000)
			,@ext_vendor_type				nvarchar(20)
			,@ext_income_type				nvarchar(250)
			,@ext_income_bruto_amount		decimal(18,2)
			,@ext_tax_rate_pct				decimal(5,2)
			,@ext_pph_amount				decimal(18,2)
			,@ext_description				nvarchar(4000)
			,@ext_tax_number				nvarchar(50)
			,@ext_sale_type					nvarchar(50)
			,@payment_detail_remark			nvarchar(4000)
			,@system_date					datetime	 = dbo.xfn_get_system_date()
			,@ext_tax_date					datetime

	begin try

		if	(
				(select payment_base_amount + isnull(total_tax_amount,0) from dbo.payment_transaction where code = @p_code) <> 
				(select sum(base_amount) from dbo.payment_transaction_detail where payment_transaction_code = @p_code)
			)
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_equal_to('Base Amount','Total Amount');
			raiserror(@msg ,16,-1)
		end

		if exists (select 1 from payment_transaction where code = @p_code and payment_orig_amount < 0)
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_greater_than('Orig Amount','0');
			raiserror(@msg ,16,-1)
		end


		if((select bank_gl_link_code from dbo.payment_transaction where code = @p_code)is null)
		begin
			set @msg = 'Please Insert Bank';
			raiserror(@msg ,16,-1)
			return
		end

		if exists (select 1 from dbo.payment_transaction where code = @p_code and payment_status <> 'ON PROCESS')
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed();
			raiserror(@msg ,16,-1)
		end
		else
		begin
			update	payment_transaction
			set		payment_transaction_date = dbo.xfn_get_system_date()
			where	code = @p_code ;

			select	@branch_code					= branch_code
					,@branch_name					= branch_name
					,@payment_transaction_date		= payment_transaction_date
					,@payment_value_date			= payment_value_date
					,@payment_orig_currency_code	= payment_orig_currency_code
					,@bank_gl_link_code				= bank_gl_link_code
					,@branch_bank_code				= branch_bank_code
					,@branch_bank_name				= branch_bank_name
					,@payment_remarks				= payment_remarks
					,@payment_base_amount			= payment_base_amount
					,@payment_exch_rate				= payment_exch_rate
					,@payment_orig_amount			= payment_orig_amount
					,@total_tax_amount				= total_tax_amount
			from	dbo.payment_transaction
			where	code = @p_code

			set	@payment_base_amount = @payment_base_amount * -1;
			set	@payment_orig_amount = @payment_orig_amount * -1;

			exec dbo.xsp_bank_mutation_insert @p_code				= @bank_mutation_code output 
											  ,@p_branch_code		= @branch_code
											  ,@p_branch_name		= @branch_name
											  ,@p_gl_link_code		= @bank_gl_link_code
											  ,@p_branch_bank_code	= @branch_bank_code
											  ,@p_branch_bank_name	= @branch_bank_name
											  ,@p_balance_amount	= @payment_orig_amount
											  ,@p_cre_date			= @p_cre_date		
											  ,@p_cre_by			= @p_cre_by			
											  ,@p_cre_ip_address	= @p_cre_ip_address
											  ,@p_mod_date			= @p_mod_date		
											  ,@p_mod_by			= @p_mod_by			
											  ,@p_mod_ip_address	= @p_mod_ip_address

			exec dbo.xsp_bank_mutation_history_insert @p_id						= 0
													  ,@p_bank_mutation_code	= @bank_mutation_code
													  ,@p_transaction_date		= @system_date
													  ,@p_value_date			= @payment_value_date
													  ,@p_source_reff_code		= @p_code
													  ,@p_source_reff_name		= N'Payment Confirm' -- nvarchar(250)
													  ,@p_orig_amount			= @payment_orig_amount
													  ,@p_orig_currency_code	= @payment_orig_currency_code
													  ,@p_exch_rate				= @payment_exch_rate
													  ,@p_base_amount			= @payment_base_amount
													  ,@p_remarks				= @payment_remarks
													  ,@p_cre_date				= @p_cre_date		
													  ,@p_cre_by				= @p_cre_by			
													  ,@p_cre_ip_address		= @p_cre_ip_address
													  ,@p_mod_date				= @p_mod_date		
													  ,@p_mod_by				= @p_mod_by			
													  ,@p_mod_ip_address		= @p_mod_ip_address

			set	@payment_base_amount = abs(@payment_base_amount);
			set	@payment_orig_amount = abs(@payment_orig_amount);

			-- update data request
			declare cur_payment_request cursor fast_forward read_only for
			
			select	code
					,ptd.exch_rate
			from	dbo.payment_request pr
					inner join payment_transaction_detail ptd on (ptd.payment_request_code = pr.code)
			where	ptd.payment_transaction_code = @p_code
	
			open cur_payment_request
		
			fetch next from cur_payment_request 
			into	@payment_request
					,@exch_rate_request

			while @@fetch_status = 0
			begin
			 
				if exists (select 1 from dbo.payment_request where code = @payment_request and  payment_source = 'RELEASE SUSPEND')
				begin
					select	@suspend_release_code	= payment_source_no 
					from	dbo.payment_request 
					where	code = @payment_request
					
					exec dbo.xsp_suspend_release_paid @p_code				= @suspend_release_code
													  --,@p_transaction_code	= @gl_link_transaction_code
													  ,@p_exch_rate			= @exch_rate_request
													  ,@p_cre_date			= @p_cre_date		
													  ,@p_cre_by			= @p_cre_by			
													  ,@p_cre_ip_address	= @p_cre_ip_address
													  ,@p_mod_date			= @p_mod_date		
													  ,@p_mod_by			= @p_mod_by			
													  ,@p_mod_ip_address	= @p_mod_ip_address
					
				end
				else if exists (select 1 from dbo.payment_request where code = @payment_request and  payment_source = 'RELEASE DEPOSIT')
				begin
					select	@deposit_release_code	= payment_source_no 
					from	dbo.payment_request 
					where	code = @payment_request
			
					exec dbo.xsp_deposit_release_paid @p_code				= @deposit_release_code
														--,@p_transaction_code	= @gl_link_transaction_code
													  ,@p_exch_rate			= @exch_rate_request
													  ,@p_cre_date			= @p_cre_date		
													  ,@p_cre_by			= @p_cre_by			
													  ,@p_cre_ip_address	= @p_cre_ip_address
													  ,@p_mod_date			= @p_mod_date		
													  ,@p_mod_by			= @p_mod_by			
													  ,@p_mod_ip_address	= @p_mod_ip_address

				end

				update	dbo.payment_request
				set		payment_status		= 'PAID'
						,mod_date			= @p_mod_date
						,mod_by				= @p_mod_by
						,mod_ip_address		= @p_mod_ip_address
				where	code				= @payment_request

				update	dbo.fin_interface_payment_request
				set		payment_status			= 'PAID'
						,process_date			= @payment_value_date
						,process_reff_no		= @p_code
						,process_reff_name		= 'PAYMENT CONFIRM'
						,mod_date				= @p_mod_date
						,mod_by					= @p_mod_by
						,mod_ip_address			= @p_mod_ip_address
				where	code					= @payment_request
					
			fetch next from cur_payment_request 
				into	@payment_request
						,@exch_rate_request
			
			end
		
			close cur_payment_request
			deallocate cur_payment_request


			--region jurnal
			declare cur_payment_transaction_detail cursor fast_forward read_only for
			
			select	ptd.payment_request_code
					,pr.payment_source
					,isnull(prd.exch_rate,ptd.exch_rate) -- pengambilan rate dari request, jika request ada rate nya
					,prd.orig_amount
					,isnull(prd.exch_rate,ptd.exch_rate) * prd.orig_amount 
					,prd.orig_currency_code
					,prd.gl_link_code
					,prd.remarks
					,prd.division_code
					,prd.division_name
					,prd.department_code
					,prd.department_name
					,prd.agreement_no
					,pr.tax_payer_reff_code
					,pr.tax_type
					,pr.tax_file_no
					,pr.tax_file_name
					,pr.payment_amount
					,pr.payment_to
					,prd.tax_amount
					,prd.tax_pct
					,prd.branch_code
					,prd.branch_name
					,prd.ext_pph_type
					,prd.ext_vendor_code
					,prd.ext_vendor_name
					,prd.ext_vendor_npwp
					,prd.ext_vendor_address
					,prd.ext_vendor_type
					,prd.ext_income_type
					,prd.ext_income_bruto_amount
					,prd.ext_tax_rate_pct
					,prd.ext_pph_amount
					,prd.ext_description
					,prd.ext_tax_number
					,prd.ext_sale_type
					,pr.payment_remarks
					,prd.ext_tax_date
			from	dbo.payment_transaction_detail ptd
					inner join dbo.payment_request pr on (pr.code = ptd.payment_request_code)
					--outer apply (select top 1 * from dbo.payment_request_detail prd where prd.payment_request_code = pr.code) prd
					inner join dbo.payment_request_detail prd on (prd.payment_request_code = pr.code)
			where	ptd.payment_transaction_code = @p_code
	
			open cur_payment_transaction_detail
		
			fetch next from cur_payment_transaction_detail 
			into	@payment_request_code
					,@payment_source
					,@exch_rate
					,@orig_amount
					,@base_amount
					,@orig_currency_code
					,@gl_link_code
					,@remarks
					,@division_code
					,@division_name
					,@department_code
					,@department_name
					,@agreement_no
					,@tax_payer_reff_code
					,@tax_type
					,@tax_file_no
					,@tax_file_name
					,@payment_amount
					,@payment_to
					,@tax_amount
					,@tax_pct
					,@branch_code_detail
					,@branch_name_detail
					,@ext_pph_type			
					,@ext_vendor_code		
					,@ext_vendor_name		
					,@ext_vendor_npwp		
					,@ext_vendor_address	
					,@ext_vendor_type		
					,@ext_income_type		
					,@ext_income_bruto_amount
					,@ext_tax_rate_pct		
					,@ext_pph_amount		
					,@ext_description		
					,@ext_tax_number		
					,@ext_sale_type
					,@payment_detail_remark
					,@ext_tax_date

			while @@fetch_status = 0
			begin
			-- journal
				--if (@payment_source in ('RELEASE SUSPEND','RELEASE DEPOSIT'))
				--begin
			
					if (@index = 0)
					begin
						set @index = 1
						set @reff_source_name = 'Payment Transaction ' + @payment_remarks
						exec dbo.xsp_fin_interface_journal_gl_link_transaction_insert @p_id							= 0
																					  ,@p_code						= @gl_link_transaction_code output
																					  ,@p_branch_code				= @branch_code 
																					  ,@p_branch_name				= @branch_name 
																					  ,@p_transaction_status		= N'NEW' 
																					  ,@p_transaction_date			= @payment_transaction_date
																					  ,@p_transaction_value_date	= @payment_value_date
																					  ,@p_transaction_code			= @p_code
																					  ,@p_transaction_name			= N'Payment Transaction'
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


						--select	@payment_base_amount	= sum(ptd.base_amount)
						--from	dbo.payment_transaction_detail ptd
						--		inner join dbo.payment_request pr on (pr.code = ptd.payment_request_code)
						--where	ptd.payment_transaction_code = @p_code
								--and pr.payment_source in ('RELEASE SUSPEND','RELEASE DEPOSIT')
						
						--senilai header amount
						exec dbo.xsp_fin_interface_journal_gl_link_transaction_detail_insert @p_id							= 0
																							 ,@p_gl_link_transaction_code	= @gl_link_transaction_code
																							 ,@p_branch_code				= @branch_code
																							 ,@p_branch_name				= @branch_name
																							 ,@p_gl_link_code				= @bank_gl_link_code
																							 ,@p_contra_gl_link_code		= null
																							 ,@p_agreement_no				= null
																							 ,@p_orig_currency_code			= @payment_orig_currency_code
																							 ,@p_orig_amount_db				= 0
																							 ,@p_orig_amount_cr				= @payment_orig_amount
																							 ,@p_exch_rate					= @payment_exch_rate
																							 ,@p_base_amount_db				= 0
																							 ,@p_base_amount_cr				= @payment_base_amount
																							 ,@p_remarks					= @payment_remarks
																							 ,@p_division_code				= null
																							 ,@p_division_name				= null
																							 ,@p_department_code			= null
																							 ,@p_department_name			= null
																							 ,@p_ext_pph_type				= null--@ext_pph_type
																							 ,@p_ext_vendor_code			= null--@ext_vendor_code
																							 ,@p_ext_vendor_name			= null--@ext_vendor_name
																							 ,@p_ext_vendor_npwp			= null--@ext_vendor_npwp
																							 ,@p_ext_vendor_address			= null--@ext_vendor_address
																							 ,@p_ext_vendor_type			= null--@ext_vendor_type
																							 ,@p_ext_income_type			= null--@ext_income_type
																							 ,@p_ext_income_bruto_amount	= null--@ext_income_bruto_amount
																							 ,@p_ext_tax_rate_pct			= null--@ext_tax_rate_pct
																							 ,@p_ext_pph_amount				= null--@ext_pph_amount
																							 ,@p_ext_description			= null--@ext_description
																							 ,@p_ext_tax_number				= null--@ext_tax_number
																							 ,@p_ext_sale_type				= null--@ext_sale_type
																							 ,@p_ext_tax_date				= null
																							 ,@p_cre_date					= @p_cre_date		
																							 ,@p_cre_by						= @p_cre_by			
																							 ,@p_cre_ip_address				= @p_cre_ip_address
																							 ,@p_mod_date					= @p_mod_date		
																							 ,@p_mod_by						= @p_mod_by			
																							 ,@p_mod_ip_address				= @p_mod_ip_address
					end

				--end
		
					if (@orig_amount > 0)
					begin
						set @orig_amount_db = @orig_amount;
						set @orig_amount_cr = 0;
					end
					else
					begin
						set @orig_amount_db =  0;
						set @orig_amount_cr = abs(@orig_amount);
					end

					if (@base_amount > 0)
					begin
						set @base_amount_db = @base_amount;
						set @base_amount_cr = 0;
					end
					else
					begin
						set @base_amount_db =  0;
						set @base_amount_cr = abs(@base_amount);
					end

					--senilai detail amount
					exec dbo.xsp_fin_interface_journal_gl_link_transaction_detail_insert @p_id							= 0
																						 ,@p_gl_link_transaction_code	= @gl_link_transaction_code
																						 ,@p_branch_code				= @branch_code_detail
																						 ,@p_branch_name				= @branch_name_detail
																						 ,@p_gl_link_code				= @gl_link_code
																						 ,@p_contra_gl_link_code		= null
																						 ,@p_agreement_no				= @agreement_no
																						 ,@p_orig_currency_code			= @orig_currency_code
																						 ,@p_orig_amount_db				= @orig_amount_db
																						 ,@p_orig_amount_cr				= @orig_amount_cr
																						 ,@p_exch_rate					= @exch_rate
																						 ,@p_base_amount_db				= @base_amount_db
																						 ,@p_base_amount_cr				= @base_amount_cr
																						 ,@p_remarks					= @remarks --@payment_detail_remark
																						 ,@p_division_code				= @division_code
																						 ,@p_division_name				= @division_name
																						 ,@p_department_code			= @department_code
																						 ,@p_department_name			= @department_name
																						 ,@p_ext_pph_type				= @ext_pph_type
																						 ,@p_ext_vendor_code			= @ext_vendor_code
																						 ,@p_ext_vendor_name			= @ext_vendor_name
																						 ,@p_ext_vendor_npwp			= @ext_vendor_npwp
																						 ,@p_ext_vendor_address			= @ext_vendor_address
																						 ,@p_ext_vendor_type			= @ext_vendor_type
																						 ,@p_ext_income_type			= @ext_income_type
																						 ,@p_ext_income_bruto_amount	= @ext_income_bruto_amount
																						 ,@p_ext_tax_rate_pct			= @ext_tax_rate_pct
																						 ,@p_ext_pph_amount				= @ext_pph_amount
																						 ,@p_ext_description			= @ext_description
																						 ,@p_ext_tax_number				= @ext_tax_number
																						 ,@p_ext_sale_type				= @ext_sale_type
																						 ,@p_ext_tax_date				= @ext_tax_date
																						 ,@p_cre_date					= @p_cre_date		
																						 ,@p_cre_by						= @p_cre_by			
																						 ,@p_cre_ip_address				= @p_cre_ip_address
																						 ,@p_mod_date					= @p_mod_date		
																						 ,@p_mod_by						= @p_mod_by			
																						 ,@p_mod_ip_address				= @p_mod_ip_address
					
					--if tax_amount > 0 insert journal detail senilai tax amount(CR)
					if @tax_amount > 0 
					begin
						exec dbo.xsp_fin_interface_journal_gl_link_transaction_detail_insert @p_id							= 0
																							 ,@p_gl_link_transaction_code	= @gl_link_transaction_code
																							 ,@p_branch_code				= @branch_code_detail
																							 ,@p_branch_name				= @branch_name_detail
																							 ,@p_gl_link_code				= @gl_link_code
																							 ,@p_contra_gl_link_code		= null
																							 ,@p_agreement_no				= @agreement_no
																							 ,@p_orig_currency_code			= @payment_orig_currency_code
																							 ,@p_orig_amount_db				= 0
																							 ,@p_orig_amount_cr				= @tax_amount
																							 ,@p_exch_rate					= @exch_rate
																							 ,@p_base_amount_db				= 0
																							 ,@p_base_amount_cr				= @tax_amount
																							 ,@p_remarks					= @remarks --@payment_detail_remark
																							 ,@p_division_code				= @division_code
																							 ,@p_division_name				= @division_name
																							 ,@p_department_code			= @department_code
																							 ,@p_department_name			= @department_name
																							 ,@p_ext_pph_type				= @ext_pph_type
																							 ,@p_ext_vendor_code			= @ext_vendor_code
																							 ,@p_ext_vendor_name			= @ext_vendor_name
																							 ,@p_ext_vendor_npwp			= @ext_vendor_npwp
																							 ,@p_ext_vendor_address			= @ext_vendor_address
																							 ,@p_ext_vendor_type			= @ext_vendor_type
																							 ,@p_ext_income_type			= @ext_income_type
																							 ,@p_ext_income_bruto_amount	= @ext_income_bruto_amount
																							 ,@p_ext_tax_rate_pct			= @ext_tax_rate_pct
																							 ,@p_ext_pph_amount				= @ext_pph_amount
																							 ,@p_ext_description			= @ext_description
																							 ,@p_ext_tax_number				= @ext_tax_number
																							 ,@p_ext_sale_type				= @ext_sale_type
																							 ,@p_ext_tax_date				= @ext_tax_date
																							 ,@p_cre_date					= @p_cre_date		
																							 ,@p_cre_by						= @p_cre_by			
																							 ,@p_cre_ip_address				= @p_cre_ip_address
																							 ,@p_mod_date					= @p_mod_date		
																							 ,@p_mod_by						= @p_mod_by			
																							 ,@p_mod_ip_address				= @p_mod_ip_address

						-- (+) Fadlan 05/13/2022 : 03:12 pm  Notes :  tax histori di insert per request detail, sebelum nya per payment transaction 

						exec dbo.xsp_withholding_tax_history_insert @p_id						= 0
																	,@p_branch_code				= @branch_code
																	,@p_branch_name				= @branch_name
																	,@p_payment_date			= @payment_transaction_date
																	,@p_payment_amount			= @payment_amount
																	,@p_tax_payer_reff_code		= @tax_payer_reff_code
																	,@p_tax_type				= @tax_type
																	,@p_tax_file_no				= @tax_file_no
																	,@p_tax_file_name			= @tax_file_name
																	,@p_tax_pct					= @tax_pct
																	,@p_tax_amount				= @tax_amount
																	,@p_reff_no					= @p_code
																	,@p_reff_name				= @payment_source
																	,@p_remark					= @payment_remarks
																	,@p_cre_date				= @p_cre_date
																	,@p_cre_by					= @p_cre_by 
																	,@p_cre_ip_address			= @p_cre_ip_address
																	,@p_mod_date				= @p_mod_date
																	,@p_mod_by					= @p_mod_by
																	,@p_mod_ip_address			= @p_mod_ip_address
					end
				
			fetch next from cur_payment_transaction_detail 
			into	@payment_request_code
					,@payment_source
					,@exch_rate
					,@orig_amount
					,@base_amount
					,@orig_currency_code
					,@gl_link_code
					,@remarks
					,@division_code
					,@division_name
					,@department_code
					,@department_name
					,@agreement_no
					,@tax_payer_reff_code
					,@tax_type
					,@tax_file_no
					,@tax_file_name
					,@payment_amount
					,@payment_to
					,@tax_amount
					,@tax_pct
					,@branch_code_detail
					,@branch_name_detail
					,@ext_pph_type			
					,@ext_vendor_code		
					,@ext_vendor_name		
					,@ext_vendor_npwp		
					,@ext_vendor_address	
					,@ext_vendor_type		
					,@ext_income_type		
					,@ext_income_bruto_amount
					,@ext_tax_rate_pct		
					,@ext_pph_amount		
					,@ext_description		
					,@ext_tax_number		
					,@ext_sale_type
					,@payment_detail_remark
					,@ext_tax_date
			
			end
		
			close cur_payment_transaction_detail
			deallocate cur_payment_transaction_detail

				
			if	(isnull(@gl_link_transaction_code,'') <> '')
			begin
				
				select	 @base_amount_cr	= sum(base_amount_cr) 
						,@base_amount_db	= sum(base_amount_db) 
				from	dbo.fin_interface_journal_gl_link_transaction_detail
				where	gl_link_transaction_code = @gl_link_transaction_code
		

				--select	case 
				--			when sum(base_amount_cr) = sum(base_amount_db) then '1'
				--			else '0'
				--		end 'boolean'
				--from	dbo.fin_interface_journal_gl_link_transaction_detail
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
			
			update	dbo.payment_transaction
			set		payment_status				= 'PAID'
					,payment_transaction_date	= dbo.xfn_get_system_date()
					,mod_date					= @p_mod_date
					,mod_by						= @p_mod_by
					,mod_ip_address				= @p_mod_ip_address
			where	code						= @p_code ;
		
			if exists (select 1 from dbo.master_account_payable_detail where payment_source = @payment_source)
			begin
				
				select @ap_code = ap_code 
				from dbo.master_account_payable map
					 inner join dbo.master_account_payable_detail mapd on (mapd.account_payable_code = map.code)
				where payment_source = @payment_source

				set @ap_amount = @payment_amount
				
				exec dbo.xsp_fin_interface_agreement_ap_thirdparty_history_insert @p_id							= 0                                   
																				  ,@p_branch_code				= @branch_code                       
																				  ,@p_branch_name				= @branch_name                      
																				  ,@p_reff_code					= @tax_payer_reff_code 
																				  ,@p_reff_name					= @payment_to
																				  ,@p_ap_type					= @ap_code
																				  ,@p_ap_thirdparty_code		= null     
																				  ,@p_agreement_no				= @agreement_no          
																				  ,@p_transaction_date			= @p_cre_date
																				  ,@p_orig_amount				= @ap_amount                       
																				  ,@p_orig_currency_code 		= @orig_currency_code                 
																				  ,@p_exch_rate					= 1                        
																				  ,@p_base_amount				= @ap_amount 
																				  ,@p_source_reff_module		= 'IFINFIN'
																				  ,@p_source_reff_no			= @p_code                     
																				  ,@p_source_reff_remarks		= @payment_remarks 
																				  ,@p_cre_date					= @p_cre_date
																				  ,@p_cre_by					= @p_cre_by
																				  ,@p_cre_ip_address			= @p_cre_ip_address
																				  ,@p_mod_date					= @p_mod_date
																				  ,@p_mod_by					= @p_mod_by
																				  ,@p_mod_ip_address			= @p_mod_ip_address   
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






GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_payment_transaction_paid] TO [ims-raffyanda]
    AS [dbo];

