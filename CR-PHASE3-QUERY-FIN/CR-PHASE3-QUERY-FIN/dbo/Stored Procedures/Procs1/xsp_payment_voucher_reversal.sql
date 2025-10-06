CREATE PROCEDURE dbo.xsp_payment_voucher_reversal
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
	declare	@msg							nvarchar(max)
			,@bank_mutation_code			nvarchar(50)
			,@gl_link_transaction_code		nvarchar(50)
			,@branch_gl_link_code			nvarchar(50)
			,@branch_bank_code				nvarchar(50)
			,@branch_bank_name				nvarchar(250)
			,@gl_link_code					nvarchar(50)
			,@payment_base_amount			decimal(18, 2)
			,@payment_orig_amount			decimal(18, 2)
			,@payment_exch_rate				decimal(18, 6)
			,@db_amount						decimal(18, 2)
			,@cr_amount						decimal(18, 2)
			,@base_amount_cr				decimal(18, 2)
			,@base_amount_db				decimal(18, 2)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@detail_branch_code			nvarchar(50)
			,@detail_branch_name			nvarchar(250)
			,@payment_transaction_date		datetime
			,@payment_value_date			datetime
			,@payment_orig_currency_code	nvarchar(3)
			,@payment_remarks				nvarchar(4000)
			,@remarks						nvarchar(4000)
			,@department_code				nvarchar(50)
			,@department_name				nvarchar(250)
			,@division_code					nvarchar(50)
			,@division_name					nvarchar(250)
			,@reff_source_name				nvarchar(250)
			,@system_date					datetime	 = dbo.xfn_get_system_date()

	begin try

		if exists (select 1 from dbo.payment_voucher where code = @p_code and payment_status <> 'ON REVERSE')
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed();
			raiserror(@msg ,16,-1)
		end
		else
		begin

			select	@branch_code					= branch_code
					,@branch_name					= branch_name
					,@payment_transaction_date		= payment_transaction_date
					,@payment_value_date			= payment_value_date
					,@payment_orig_currency_code	= payment_orig_currency_code
					,@payment_remarks				= payment_remarks
					,@payment_base_amount			= payment_base_amount
					,@payment_orig_amount			= payment_orig_amount
					,@payment_exch_rate				= payment_exch_rate
					,@branch_gl_link_code			= branch_gl_link_code
					,@branch_bank_code				= branch_bank_code
					,@branch_bank_name				= branch_bank_name
			from	dbo.payment_voucher
			where	code = @p_code

			exec dbo.xsp_bank_mutation_insert @p_code				= @bank_mutation_code output 
											  ,@p_branch_code		= @branch_code
											  ,@p_branch_name		= @branch_name
											  ,@p_gl_link_code		= @branch_gl_link_code
											  ,@p_branch_bank_code	= @branch_bank_code
											  ,@p_branch_bank_name	= @branch_bank_name
											  ,@p_balance_amount	= @payment_base_amount
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
													  ,@p_source_reff_name		= N'Reversal Payment Voucher' -- nvarchar(250)
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

			set @reff_source_name = 'Reversal Payment Voucher ' + @payment_remarks
			exec dbo.xsp_fin_interface_journal_gl_link_transaction_insert @p_id							= 0
																		  ,@p_code						= @gl_link_transaction_code output
																		  ,@p_branch_code				= @branch_code 
																		  ,@p_branch_name				= @branch_name 
																		  ,@p_transaction_status		= N'NEW' 
																		  ,@p_transaction_date			= @system_date
																		  ,@p_transaction_value_date	= @payment_value_date
																		  ,@p_transaction_code			= @p_code
																		  ,@p_transaction_name			= N'Payment Voucher'
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

			exec dbo.xsp_fin_interface_journal_gl_link_transaction_detail_insert @p_id							= 0
																				 ,@p_gl_link_transaction_code	= @gl_link_transaction_code
																				 ,@p_branch_code				= @branch_code
																				 ,@p_branch_name				= @branch_name
																				 ,@p_gl_link_code				= @branch_gl_link_code
																				 ,@p_contra_gl_link_code		= null
																				 ,@p_agreement_no				= null
																				 ,@p_orig_currency_code			= @payment_orig_currency_code
																				 ,@p_orig_amount_db				= @payment_base_amount
																				 ,@p_orig_amount_cr				= 0
																				 ,@p_exch_rate					= 1
																				 ,@p_base_amount_db				= @payment_base_amount
																				 ,@p_base_amount_cr				= 0
																				 ,@p_remarks					= @payment_remarks
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

			declare cur_payment_voucher_detail cursor fast_forward read_only for
			
			select	branch_code
					,branch_name
					,orig_currency_code
					,base_amount
					,gl_link_code
					,department_code
					,department_name
					,division_code
					,division_name
					,remarks
					,branch_code
					,branch_name
			from	dbo.payment_voucher_detail 
			where	payment_voucher_code = @p_code

			open cur_payment_voucher_detail
		
			fetch next from cur_payment_voucher_detail 
			into	@branch_code
					,@branch_name
					,@payment_orig_currency_code
					,@payment_base_amount
					,@gl_link_code
					,@department_code	
					,@department_name	
					,@division_code		
					,@division_name	
					,@remarks	
					,@detail_branch_code
					,@detail_branch_name

			while @@fetch_status = 0
			begin
			-- journal
				if (@payment_base_amount > 0)
				begin
					set @db_amount =  0;
					set @cr_amount =  @payment_base_amount;
				end
				else 
				begin
					set @db_amount =  abs(@payment_base_amount);
					set @cr_amount =  0;
				end
					
				exec dbo.xsp_fin_interface_journal_gl_link_transaction_detail_insert @p_id							= 0
																					 ,@p_gl_link_transaction_code	= @gl_link_transaction_code
																					 ,@p_branch_code				= @detail_branch_code
																					 ,@p_branch_name				= @detail_branch_name
																					 ,@p_gl_link_code				= @gl_link_code
																					 ,@p_contra_gl_link_code		= null
																					 ,@p_agreement_no				= null
																					 ,@p_orig_currency_code			= @payment_orig_currency_code
																					 ,@p_orig_amount_db				= @db_amount
																					 ,@p_orig_amount_cr				= @cr_amount
																					 ,@p_exch_rate					= 1
																					 ,@p_base_amount_db				= @db_amount
																					 ,@p_base_amount_cr				= @cr_amount
																					 ,@p_remarks					= @remarks
																					 ,@p_division_code				= @division_code
																					 ,@p_division_name				= @division_name
																					 ,@p_department_code			= @department_code
																					 ,@p_department_name			= @department_name
																					 ,@p_cre_date					= @p_cre_date		
																					 ,@p_cre_by						= @p_cre_by			
																					 ,@p_cre_ip_address				= @p_cre_ip_address
																					 ,@p_mod_date					= @p_mod_date		
																					 ,@p_mod_by						= @p_mod_by			
																					 ,@p_mod_ip_address				= @p_mod_ip_address


			fetch next from cur_payment_voucher_detail 
				into	@branch_code
						,@branch_name
						,@payment_orig_currency_code
						,@payment_base_amount
						,@gl_link_code
						,@department_code	
						,@department_name	
						,@division_code		
						,@division_name	
						,@remarks	
						,@detail_branch_code
						,@detail_branch_name

			end
			close cur_payment_voucher_detail
			deallocate cur_payment_voucher_detail

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

			update	dbo.payment_voucher
			set		payment_status		= 'REVERSE'
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


