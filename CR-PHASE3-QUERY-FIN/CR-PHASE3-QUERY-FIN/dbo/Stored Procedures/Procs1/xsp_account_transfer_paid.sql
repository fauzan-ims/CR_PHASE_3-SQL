CREATE PROCEDURE dbo.xsp_account_transfer_paid
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
			,@cashier_code				nvarchar(50)
			,@cashier_main_code			nvarchar(50)
			,@bank_mutation_code		nvarchar(50)
			,@to_gl_link_code			nvarchar(50)
			,@to_branch_code			nvarchar(50)
			,@to_branch_name			nvarchar(250)
			,@to_branch_bank_code		nvarchar(50)
			,@to_branch_bank_name		nvarchar(250)
			,@from_orig_amount			decimal(18,2)
			,@from_exch_rate			decimal(18,6)
			,@from_branch_code			nvarchar(50)
			,@from_branch_name			nvarchar(50)
			,@from_gl_link_code			nvarchar(250)
			,@from_branch_bank_code		nvarchar(50)
			,@from_branch_bank_name		nvarchar(250)
			,@to_orig_amount			decimal(18,2)
			,@to_exch_rate				decimal(18,6)
			,@reff_source_name			nvarchar(250)
			,@transfer_remarks			nvarchar(4000)
			,@remarks					nvarchar(4000)
			,@from_currency_code		nvarchar(3)
			,@to_currency_code			nvarchar(3)
			,@is_from					nvarchar(1)
			,@from_base_amount			decimal(18,2)
			,@to_base_amount			decimal(18,2)
			,@base_amount_cr			decimal(18,2)
			,@base_amount_db			decimal(18,2)
			,@transfer_trx_date			datetime
			,@transfer_value_date		datetime
			,@close_amount				decimal(18,2)
			,@intransit_gl_link_code	nvarchar(50)
			,@system_date				datetime	 = dbo.xfn_get_system_date()

	begin try

		if exists	(
						select	1 
						from	dbo.account_transfer at
								inner join dbo.cashier_main cm on (cm.code = at.cashier_code)
						where	at.code = @p_code 
								and cm.cashier_close_amount < at.from_orig_amount
					)
		begin
			select	@close_amount	= cm.cashier_close_amount 
			from	dbo.account_transfer at
					inner join dbo.cashier_main cm on (cm.code = at.cashier_code)
			where	at.code = @p_code 
			 
			set @msg = 'From Amount must be less than or equal to Cashier Close Amount. Your Close Amount : ' + convert(nvarchar(max), format(@close_amount, '#,##0.00'));
			raiserror(@msg ,16,-1)
		end
	
		if exists (select 1 from dbo.account_transfer where code = @p_code and transfer_status <> 'HOLD')
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed();
			raiserror(@msg ,16,-1)
		end
		else
		begin
			
			select	@cashier_code				= cashier_code 
					,@transfer_trx_date			= transfer_trx_date
					,@transfer_value_date		= transfer_value_date
					,@from_branch_code			= from_branch_code
					,@from_branch_name			= from_branch_name
					,@from_currency_code		= from_currency_code
					,@from_gl_link_code			= from_gl_link_code
					,@from_branch_bank_code		= from_branch_bank_code
					,@from_branch_bank_name		= from_branch_bank_name
					,@from_exch_rate			= from_exch_rate
					,@from_orig_amount			= from_orig_amount
					,@to_branch_code			= to_branch_code
					,@to_branch_name			= to_branch_name
					,@to_currency_code			= to_currency_code
					,@to_gl_link_code			= to_gl_link_code
					,@to_branch_bank_code		= to_branch_bank_code
					,@to_branch_bank_name		= to_branch_bank_name
					,@to_exch_rate				= to_exch_rate
					,@to_orig_amount			= to_orig_amount
					,@transfer_remarks			= transfer_remarks
					,@is_from					= is_from
					,@from_base_amount			= from_orig_amount * from_exch_rate
					,@to_base_amount			= to_orig_amount * to_exch_rate
			from	dbo.account_transfer
			where	code = @p_code

			if (isnull(@from_currency_code,'') = '') or (isnull(@from_gl_link_code,'') = '') or (isnull(@from_branch_bank_code,'') = '') or (isnull(@from_branch_bank_name,'') = '')
			begin
				set @msg = 'Please Insert From Bank';
				raiserror(@msg ,16,-1)
			end

			-- bank mutation to
				exec dbo.xsp_bank_mutation_insert @p_code				= @bank_mutation_code output 
											      ,@p_branch_code		= @to_branch_code
											      ,@p_branch_name		= @to_branch_name
											      ,@p_gl_link_code		= @to_gl_link_code
											      ,@p_branch_bank_code	= @to_branch_bank_code
											      ,@p_branch_bank_name	= @to_branch_bank_name
											      ,@p_balance_amount	= @to_orig_amount
											      ,@p_cre_date			= @p_cre_date		
											      ,@p_cre_by			= @p_cre_by			
											      ,@p_cre_ip_address	= @p_cre_ip_address
											      ,@p_mod_date			= @p_mod_date		
											      ,@p_mod_by			= @p_mod_by			
											      ,@p_mod_ip_address	= @p_mod_ip_address

			exec dbo.xsp_bank_mutation_history_insert @p_id						= 0
													  ,@p_bank_mutation_code	= @bank_mutation_code
													  ,@p_transaction_date		= @system_date
													  ,@p_value_date			= @transfer_value_date
													  ,@p_source_reff_code		= @p_code
													  ,@p_source_reff_name		= N'Account Transfer' -- nvarchar(250)
													  ,@p_orig_amount			= @to_orig_amount
													  ,@p_orig_currency_code	= @to_currency_code
													  ,@p_exch_rate				= @to_exch_rate
													  ,@p_base_amount			= @to_base_amount
													  ,@p_remarks				= @transfer_remarks
													  ,@p_cre_date				= @p_cre_date		
													  ,@p_cre_by				= @p_cre_by			
													  ,@p_cre_ip_address		= @p_cre_ip_address
													  ,@p_mod_date				= @p_mod_date		
													  ,@p_mod_by				= @p_mod_by			
													  ,@p_mod_ip_address		= @p_mod_ip_address


			set @reff_source_name = 'Account Transfer ' + @transfer_remarks
			-- Journal From Bank
			exec dbo.xsp_fin_interface_journal_gl_link_transaction_insert @p_id							= 0
																		  ,@p_code						= @gl_link_transaction_code output
																		  ,@p_branch_code				= @from_branch_code 
																		  ,@p_branch_name				= @from_branch_name 
																		  ,@p_transaction_status		= N'NEW' 
																		  ,@p_transaction_date			= @transfer_trx_date
																		  ,@p_transaction_value_date	= @transfer_value_date
																		  ,@p_transaction_code			= @p_code
																		  ,@p_transaction_name			= N'Account Transfer'
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

			set @remarks = 'Account Transfer ' + @p_code + ' ' + @transfer_remarks
			if(isnull(@cashier_code,'') <> '')
			begin
				if exists (select 1 from dbo.cashier_main where code = @cashier_code and cashier_status = 'OPEN')
				begin
					set @remarks = @remarks + '. Cashier No ' + @cashier_code
				end
			end

			select	@intransit_gl_link_code = value 
			from	dbo.sys_global_param
			where	code = 'INTRACC'

			exec dbo.xsp_fin_interface_journal_gl_link_transaction_detail_insert @p_id							= 0
																				 ,@p_gl_link_transaction_code	= @gl_link_transaction_code
																				 ,@p_branch_code				= @from_branch_code
																				 ,@p_branch_name				= @from_branch_name
																				 ,@p_gl_link_code				= @from_gl_link_code
																				 ,@p_contra_gl_link_code		= null
																				 ,@p_agreement_no				= null
																				 ,@p_orig_currency_code			= @from_currency_code
																				 ,@p_orig_amount_db				= 0
																				 ,@p_orig_amount_cr				= @from_orig_amount
																				 ,@p_exch_rate					= @from_exch_rate
																				 ,@p_base_amount_db				= 0
																				 ,@p_base_amount_cr				= @from_base_amount
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

			-- awal comment 
			exec dbo.xsp_fin_interface_journal_gl_link_transaction_detail_insert @p_id							= 0
																				 ,@p_gl_link_transaction_code	= @gl_link_transaction_code
																				 ,@p_branch_code				= @to_branch_code
																				 ,@p_branch_name				= @to_branch_name
																				 ,@p_gl_link_code				= @intransit_gl_link_code
																				 ,@p_contra_gl_link_code		= null
																				 ,@p_agreement_no				= null
																				 ,@p_orig_currency_code			= @from_currency_code
																				 ,@p_orig_amount_db				= @from_orig_amount
																				 ,@p_orig_amount_cr				= 0
																				 ,@p_exch_rate					= @from_exch_rate
																				 ,@p_base_amount_db				= @from_base_amount
																				 ,@p_base_amount_cr				= 0
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

			if	(isnull(@gl_link_transaction_code,'') <> '')
			begin
				update dbo.fin_interface_journal_gl_link_transaction
				set		transaction_status	= 'HOLD'
						,mod_date			= @p_mod_date
						,mod_by				= @p_mod_by
						,mod_ip_address		= @p_mod_ip_address
				where	code				= @gl_link_transaction_code
			end

			-- Journal From Bank
			exec dbo.xsp_fin_interface_journal_gl_link_transaction_insert @p_id							= 0
																		  ,@p_code						= @gl_link_transaction_code output
																		  ,@p_branch_code				= @to_branch_code 
																		  ,@p_branch_name				= @to_branch_name 
																		  ,@p_transaction_status		= N'NEW' 
																		  ,@p_transaction_date			= @transfer_trx_date
																		  ,@p_transaction_value_date	= @transfer_value_date
																		  ,@p_transaction_code			= @p_code
																		  ,@p_transaction_name			= N'Account Transfer'
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
																				 ,@p_branch_code				= @from_branch_code
																				 ,@p_branch_name				= @from_branch_name
																				 ,@p_gl_link_code				= @intransit_gl_link_code
																				 ,@p_contra_gl_link_code		= null
																				 ,@p_agreement_no				= null
																				 ,@p_orig_currency_code			= @to_currency_code
																				 ,@p_orig_amount_db				= 0
																				 ,@p_orig_amount_cr				= @to_orig_amount
																				 ,@p_exch_rate					= @to_exch_rate
																				 ,@p_base_amount_db				= 0
																				 ,@p_base_amount_cr				= @to_base_amount
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

			--- batas akhir coment

			exec dbo.xsp_fin_interface_journal_gl_link_transaction_detail_insert @p_id							= 0
																				 ,@p_gl_link_transaction_code	= @gl_link_transaction_code
																				 ,@p_branch_code				= @to_branch_code
																				 ,@p_branch_name				= @to_branch_name
																				 ,@p_gl_link_code				= @to_gl_link_code
																				 ,@p_contra_gl_link_code		= null
																				 ,@p_agreement_no				= null
																				 ,@p_orig_currency_code			= @to_currency_code
																				 ,@p_orig_amount_db				= @to_orig_amount
																				 ,@p_orig_amount_cr				= 0
																				 ,@p_exch_rate					= @to_exch_rate
																				 ,@p_base_amount_db				= @to_base_amount
																				 ,@p_base_amount_cr				= 0
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

			set @from_orig_amount = @from_orig_amount * -1;
			set @from_base_amount = @from_base_amount * -1;
			-- bank mutation from
				exec dbo.xsp_bank_mutation_insert @p_code				= @bank_mutation_code output 
											      ,@p_branch_code		= @from_branch_code
											      ,@p_branch_name		= @from_branch_name
											      ,@p_gl_link_code		= @from_gl_link_code
											      ,@p_branch_bank_code  = @from_branch_bank_code
											      ,@p_branch_bank_name	= @from_branch_bank_name
											      ,@p_balance_amount	= @from_orig_amount
											      ,@p_cre_date			= @p_cre_date		
											      ,@p_cre_by			= @p_cre_by			
											      ,@p_cre_ip_address	= @p_cre_ip_address
											      ,@p_mod_date			= @p_mod_date		
											      ,@p_mod_by			= @p_mod_by			
											      ,@p_mod_ip_address	= @p_mod_ip_address

			exec dbo.xsp_bank_mutation_history_insert @p_id						= 0
												      ,@p_bank_mutation_code	= @bank_mutation_code
												      ,@p_transaction_date		= @p_cre_date
												      ,@p_value_date			= @transfer_value_date
												      ,@p_source_reff_code		= @p_code
												      ,@p_source_reff_name		= N'Account Transfer' -- nvarchar(250)
												      ,@p_orig_amount			= @from_orig_amount
												      ,@p_orig_currency_code	= @from_currency_code
												      ,@p_exch_rate				= @from_exch_rate
												      ,@p_base_amount			= @from_base_amount
													  ,@p_remarks				= @transfer_remarks
												      ,@p_cre_date				= @p_cre_date		
												      ,@p_cre_by				= @p_cre_by			
												      ,@p_cre_ip_address		= @p_cre_ip_address
												      ,@p_mod_date				= @p_mod_date		
												      ,@p_mod_by				= @p_mod_by			
												      ,@p_mod_ip_address		= @p_mod_ip_address

			-- set Cashier Amount 
			if(isnull(@cashier_code,'') <> '')
			begin
					if exists (select 1 from dbo.cashier_main where code = @cashier_code and cashier_status = 'OPEN')
					begin
						exec dbo.xsp_cashier_main_update_mutation @p_code				= @cashier_code
																  ,@p_amount			= @from_orig_amount
																  ,@p_cre_date			= @p_cre_date		
																  ,@p_cre_by			= @p_cre_by			
																  ,@p_cre_ip_address	= @p_cre_ip_address
																  ,@p_mod_date			= @p_mod_date		
																  ,@p_mod_by			= @p_mod_by			
																  ,@p_mod_ip_address	= @p_mod_ip_address
					end
					else
					begin
					    exec dbo.xsp_cashier_main_open @p_code					= @cashier_code
					    							   ,@p_cre_date				= @p_cre_date		
					    							   ,@p_cre_by				= @p_cre_by			
					    							   ,@p_cre_ip_address		= @p_cre_ip_address
					    							   ,@p_mod_date				= @p_mod_date		
					    							   ,@p_mod_by				= @p_mod_by			
					    							   ,@p_mod_ip_address		= @p_mod_ip_address
					end
			end

			-- ketika data dari request OPEX
			if(isnull(@is_from,'') <> '')
			begin
				update	dbo.fin_interface_account_transfer
				set		transfer_status			= 'PAID'
						,mod_date				= @p_mod_date
						,mod_by					= @p_mod_by
						,mod_ip_address			= @p_mod_ip_address
				where	code					= @p_code
			end

			update	dbo.account_transfer
			set		transfer_status		= 'PAID'
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



