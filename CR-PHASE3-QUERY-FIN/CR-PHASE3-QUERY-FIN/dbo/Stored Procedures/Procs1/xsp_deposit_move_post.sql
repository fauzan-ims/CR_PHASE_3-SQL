CREATE PROCEDURE [dbo].[xsp_deposit_move_post]
(
	@p_code					nvarchar(50)
	,@p_rate				decimal(18, 6)
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
			,@gl_link_transaction_code		nvarchar(50)
			,@from_gl_link_code				nvarchar(50)
			,@to_gl_link_code				nvarchar(50)
			,@from_deposit_code				nvarchar(50)
			,@to_deposit_code				nvarchar(50)
			,@from_agreement_no				nvarchar(50)
			,@to_agreement_no				nvarchar(50)
			,@from_branch_code				nvarchar(50)
			,@from_branch_name				nvarchar(250)
			,@to_branch_code				nvarchar(50)
			,@to_branch_name				nvarchar(250)
			,@reff_source_name				nvarchar(250)
			,@move_remarks					nvarchar(4000)
			,@to_deposit_type_code			nvarchar(15)
			,@from_deposit_type_code		nvarchar(15)
			,@to_amount						decimal(18, 2)
			,@to_base_amount				decimal(18, 2)
			,@base_amount_cr				decimal(18, 2)
			,@base_amount_db				decimal(18, 2)
			,@from_currency_code			nvarchar(3)
			,@to_currency_code				nvarchar(3)
			,@move_date						datetime
			,@from_agreement_external_no	nvarchar(50)
			,@from_client_name				nvarchar(250)
			,@to_agreement_external_no		nvarchar(50)
			,@to_client_name				nvarchar(250)
			,@first							int = 1
			,@total_to_amount				decimal(18, 2)
			,@total_to_base_amount			decimal(18, 2)

	begin try
	
		if exists (select 1 from dbo.deposit_move where code = @p_code and move_status <> 'ON PROCESS')
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed();
			raiserror(@msg ,16,-1)
		end
		else
		begin
        
		update dbo.deposit_move
		set move_date = dbo.xfn_get_system_date()
		where code = @p_code

			select	@from_deposit_code				= dm.from_deposit_code
					,@from_deposit_type_code		= dm.from_deposit_type_code
					,@from_agreement_no				= dm.from_agreement_no
					,@move_date						= dm.move_date
					,@from_branch_code				= amf.branch_code
					,@from_branch_name				= amf.branch_name
					,@move_remarks					= dm.move_remarks
					,@from_agreement_external_no	= amf.agreement_external_no
					,@from_client_name				= amf.client_name
					,@from_currency_code			= amf.currency_code
					,@to_currency_code				= amf.currency_code
					,@total_to_amount				= dm.total_to_amount
					,@total_to_base_amount			= dm.total_to_amount * @p_rate
			from	dbo.deposit_move dm
					inner join dbo.agreement_main amf on (amf.agreement_no = dm.from_agreement_no)
			where	code = @p_code

			declare currDepositMoveDetail cursor fast_forward read_only for -- Louis Senin, 30 Juni 2025 19.26.26 -- diganti menjadi loop dari detail
			select	amt.agreement_external_no
					,amt.client_name
					,amt.branch_code
					,amt.branch_name
					,dm.to_agreement_no
					,dm.to_deposit_type_code
					,dm.to_amount
					,dm.to_amount * @p_rate
			from	dbo.deposit_move_detail dm
					inner join dbo.agreement_main amt on (amt.agreement_no = dm.to_agreement_no)
			where	deposit_move_code = @p_code ;
			open currDepositMoveDetail ;

			fetch next from currDepositMoveDetail
			into	@to_agreement_external_no	
					,@to_client_name			
					,@to_branch_code			
					,@to_branch_name
					,@to_agreement_no			
					,@to_deposit_type_code		
					,@to_amount					
					,@to_base_amount			

			while @@fetch_status = 0
			begin 
				if (@first = 1)
				begin
					set @total_to_amount = @total_to_amount * -1;
					set @total_to_base_amount = @total_to_base_amount * -1;
					exec dbo.xsp_fin_interface_agreement_deposit_history_insert @p_id						= 0                    
																				,@p_branch_code				= @from_branch_code
																				,@p_branch_name				= @from_branch_name
																				,@p_agreement_no			= @from_agreement_no -- dikurangi 
																				,@p_agreement_deposit_code  = null
																				,@p_deposit_type			= @from_deposit_type_code
																				,@p_transaction_date		= @p_cre_date
																				,@p_orig_amount				= @total_to_amount
																				,@p_orig_currency_code		= @from_currency_code
																				,@p_exch_rate				= @p_rate  
																				,@p_base_amount				= @total_to_base_amount
																				,@p_source_reff_module		= 'IFINFIN'
																				,@p_source_reff_code		= @p_code
																				,@p_source_reff_name		= 'Deposit Move'
																				,@p_cre_date				= @p_cre_date		
																				,@p_cre_by					= @p_cre_by			
																				,@p_cre_ip_address			= @p_cre_ip_address
																				,@p_mod_date				= @p_mod_date		
																				,@p_mod_by					= @p_mod_by			
																				,@p_mod_ip_address			= @p_mod_ip_address
					set @total_to_amount = abs(@total_to_amount);
					set @total_to_base_amount = abs(@total_to_base_amount);
				end
				
				set @to_amount = abs(@to_amount);
				set @to_base_amount = abs(@to_base_amount);

				exec dbo.xsp_fin_interface_agreement_deposit_history_insert @p_id						= 0                    
																			,@p_branch_code				= @from_branch_code
																			,@p_branch_name				= @from_branch_name
																			,@p_agreement_no			= @to_agreement_no  
																			,@p_agreement_deposit_code  = null
																			,@p_deposit_type			= @to_deposit_type_code
																			,@p_transaction_date		= @p_cre_date
																			,@p_orig_amount				= @to_amount
																			,@p_orig_currency_code		= @to_currency_code
																			,@p_exch_rate				= @p_rate  
																			,@p_base_amount				= @to_base_amount
																			,@p_source_reff_module		= 'IFINFIN'
																			,@p_source_reff_code		= @p_code
																			,@p_source_reff_name		= 'Deposit Move'
																			,@p_cre_date				= @p_cre_date		
																			,@p_cre_by					= @p_cre_by			
																			,@p_cre_ip_address			= @p_cre_ip_address
																			,@p_mod_date				= @p_mod_date		
																			,@p_mod_by					= @p_mod_by			
																			,@p_mod_ip_address			= @p_mod_ip_address

				if (@first = 1)
				begin
					set @reff_source_name = 'Deposit Move, From Agreement : ' + @from_agreement_external_no + ' - ' + @from_client_name 
											+ ', to Agreement : ' + @to_agreement_external_no + ' - ' + @to_client_name + '. ' + @move_remarks;
					exec dbo.xsp_fin_interface_journal_gl_link_transaction_insert @p_id							= 0
																				  ,@p_code						= @gl_link_transaction_code output
																				  ,@p_branch_code				= @from_branch_code 
																				  ,@p_branch_name				= @from_branch_name 
																				  ,@p_transaction_status		= 'NEW' 
																				  ,@p_transaction_date			= @move_date
																				  ,@p_transaction_value_date	= @move_date
																				  ,@p_transaction_code			= 'DPSMVE'
																				  ,@p_transaction_name			= 'DEPOSIT MOVE'
																				  ,@p_reff_module_code			= 'IFINFIN'
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

					if (@from_deposit_type_code = 'INSTALLMENT')	
					begin																	
						select	@from_gl_link_code = gl_link_code 
						from	dbo.master_transaction
						where	code = 'DPINST'
					end
					else if (@from_deposit_type_code = 'INSURANCE')	
					begin																	 
						select	@from_gl_link_code = gl_link_code 
						from	dbo.master_transaction
						where	code = 'DPINSI'
					end
					else if (@from_deposit_type_code = 'OTHER')
					begin																	
						select	@from_gl_link_code = gl_link_code 
						from	dbo.master_transaction
						where	code = 'DPOTH'
					end
					else
					begin
						select	@from_gl_link_code = gl_link_code 
						from	dbo.master_transaction
						where	code = 'DPSCT'
					end
			
					exec dbo.xsp_fin_interface_journal_gl_link_transaction_detail_insert @p_id							= 0
																						 ,@p_gl_link_transaction_code	= @gl_link_transaction_code
																						 ,@p_branch_code				= @from_branch_code
																						 ,@p_branch_name				= @from_branch_name
																						 ,@p_gl_link_code				= @from_gl_link_code
																						 ,@p_contra_gl_link_code		= null
																						 ,@p_agreement_no				= @from_agreement_no
																						 ,@p_orig_currency_code			= @from_currency_code
																						 ,@p_orig_amount_db				= 0
																						 ,@p_orig_amount_cr				= @total_to_amount
																						 ,@p_exch_rate					= @p_rate
																						 ,@p_base_amount_db				= 0
																						 ,@p_base_amount_cr				= @total_to_base_amount
																						 ,@p_remarks					= @reff_source_name
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
				if (@to_deposit_type_code = 'INSTALLMENT')	
				begin																	
					select	@to_gl_link_code = gl_link_code 
					from	dbo.master_transaction
					where	code = 'DPINST'
				end
				else if (@to_deposit_type_code = 'INSURANCE')	
				begin																	 
					select	@to_gl_link_code = gl_link_code 
					from	dbo.master_transaction
					where	code = 'DPINSI'
				end
				else if (@to_deposit_type_code = 'OTHER')
				begin																	
					select	@to_gl_link_code = gl_link_code 
					from	dbo.master_transaction
					where	code = 'DPOTH'
				end
				else
				begin
					select	@to_gl_link_code = gl_link_code 
					from	dbo.master_transaction
					where	code = 'DPSCT'
				end

				exec dbo.xsp_fin_interface_journal_gl_link_transaction_detail_insert @p_id							= 0
																					 ,@p_gl_link_transaction_code	= @gl_link_transaction_code
																					 ,@p_branch_code				= @to_branch_code
																					 ,@p_branch_name				= @to_branch_name
																					 ,@p_gl_link_code				= @to_gl_link_code
																					 ,@p_contra_gl_link_code		= null
																					 ,@p_agreement_no				= @to_agreement_no
																					 ,@p_orig_currency_code			= @to_currency_code
																					 ,@p_orig_amount_db				= @to_amount
																					 ,@p_orig_amount_cr				= 0
																					 ,@p_exch_rate					= @p_rate
																					 ,@p_base_amount_db				= @to_base_amount
																					 ,@p_base_amount_cr				= 0
																					 ,@p_remarks					= @reff_source_name
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
				set @first = 2;

				fetch next from currDepositMoveDetail
				into	@to_agreement_external_no	
						,@to_client_name			
						,@to_branch_code			
						,@to_branch_name
						,@to_agreement_no			
						,@to_deposit_type_code		
						,@to_amount					
						,@to_base_amount		
			end ;

			close currDepositMoveDetail ;
			deallocate currDepositMoveDetail ;
			

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

			update	dbo.deposit_move
			set		move_status			= 'POST'
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
