CREATE PROCEDURE dbo.xsp_deposit_revenue_post
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
			,@gl_link_code				nvarchar(50)
			,@deposit_code				nvarchar(50)
			,@revenue_amount			decimal(18, 2)
			,@amount					decimal(18, 2)
			,@base_amount				decimal(18, 2)
			,@base_amount_cr			decimal(18, 2)
			,@base_amount_db			decimal(18, 2)
			,@rate						decimal(18, 6)
			,@branch_code				nvarchar(50)
			,@branch_name				nvarchar(250)
			,@reff_source_name			nvarchar(250)
			,@client_name				nvarchar(250)
			,@revenue_date				datetime
			,@deposit_currency_code		nvarchar(3)
			,@currency_code				nvarchar(3)
			,@deposit_type				nvarchar(15)
			,@agreement_no				nvarchar(50)
			,@agreement_external_no		nvarchar(50)
			,@revenue_remarks			nvarchar(4000)
			,@index						bigint
			,@id						bigint

	begin try
	
		if exists (select 1 from dbo.deposit_revenue where code = @p_code and revenue_status <> 'HOLD')
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed();
			raiserror(@msg ,16,-1)
		end

		if not exists (select 1 from dbo.deposit_revenue_detail where deposit_revenue_code = @p_code)
		begin
			set @msg = 'Please add Deposit';
			raiserror(@msg ,16,-1)
		end
		else
		begin
			
			select	@amount			= revenue_amount
					,@rate			= exch_rate
					,@currency_code	= currency_code
			from	dbo.deposit_revenue
			where	code	= @p_code

			declare cur_deposit_revenue_detail cursor fast_forward read_only for
			
			select	srd.id
					,srd.deposit_code
					,srd.revenue_amount
					,sr.branch_code
					,sr.branch_name
					,am.currency_code
					,sr.revenue_date
					,sr.agreement_no
					,am.client_name
					,am.agreement_external_no
					,srd.deposit_type
					,sr.revenue_remarks
					,row_number() over(order by srd.id asc) as row#
			from	dbo.deposit_revenue_detail srd
					inner join dbo.deposit_revenue sr on (sr.code = srd.deposit_revenue_code)
					inner join dbo.agreement_main am on (am.agreement_no = sr.agreement_no)
			where	deposit_revenue_code = @p_code

			open cur_deposit_revenue_detail
		
			fetch next from cur_deposit_revenue_detail 
			into	@id
					,@deposit_code
					,@revenue_amount
					,@branch_code
					,@branch_name
					,@deposit_currency_code
					,@revenue_date
					,@agreement_no
					,@client_name
					,@agreement_external_no
					,@deposit_type
					,@revenue_remarks
					,@index

			while @@fetch_status = 0
			begin

				if exists (select 1 from dbo.deposit_revenue_detail where id = @id and revenue_amount > deposit_amount)
				begin
					close cur_deposit_revenue_detail
					deallocate cur_deposit_revenue_detail
					set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Revenue Amount','Deposit Amount');
					raiserror(@msg ,16,-1)
				end

				set @revenue_amount = @revenue_amount * -1;
				set @base_amount = @revenue_amount * @rate;

				--01/07/2021 deposit insert ke fin_interface_agreement_deposit_history
				exec dbo.xsp_fin_interface_agreement_deposit_history_insert @p_id						= 0                    
						                                                    ,@p_branch_code				= @branch_code
						                                                    ,@p_branch_name				= @branch_name
						                                                    ,@p_agreement_no			= @agreement_no
						                                                    ,@p_deposit_type			= @deposit_type
																			,@p_agreement_deposit_code  = @deposit_code
						                                                    ,@p_transaction_date		= @p_cre_date
						                                                    ,@p_orig_amount				= @revenue_amount
						                                                    ,@p_orig_currency_code		= @deposit_currency_code
						                                                    ,@p_exch_rate				= @rate  
						                                                    ,@p_base_amount				= @base_amount
						                                                    ,@p_source_reff_module		= 'IFINFIN'
						                                                    ,@p_source_reff_code		= @p_code
						                                                    ,@p_source_reff_name		= 'Deposit Revenue'
						                                                    ,@p_cre_date				= @p_cre_date		
																			,@p_cre_by					= @p_cre_by			
																			,@p_cre_ip_address			= @p_cre_ip_address
																			,@p_mod_date				= @p_mod_date		
																			,@p_mod_by					= @p_mod_by			
																			,@p_mod_ip_address			= @p_mod_ip_address  


				-- journal
				    if (@index = 1)
					begin
						set @reff_source_name = 'Deposit Revenue, Deposit No : ' + @deposit_code + ' for ' + @agreement_external_no + ' - ' + @client_name + '. ' + @revenue_remarks
						exec dbo.xsp_fin_interface_journal_gl_link_transaction_insert @p_id							= 0
																					  ,@p_code						= @gl_link_transaction_code output
																					  ,@p_branch_code				= @branch_code 
																					  ,@p_branch_name				= @branch_name 
																					  ,@p_transaction_status		= 'NEW' 
																					  ,@p_transaction_date			= @revenue_date
																					  ,@p_transaction_value_date	= @revenue_date
																					  ,@p_transaction_code			= 'DPSRVN'
																					  ,@p_transaction_name			= 'DEPOSIT REVENUE'
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

						
						select	@gl_link_code = value 
						from	dbo.sys_global_param
						where	code = 'GLLINKRD'

						set @base_amount = @amount * @rate;
						exec dbo.xsp_fin_interface_journal_gl_link_transaction_detail_insert @p_id							= 0
																							 ,@p_gl_link_transaction_code	= @gl_link_transaction_code
																							 ,@p_branch_code				= @branch_code
																							 ,@p_branch_name				= @branch_name
																							 ,@p_gl_link_code				= @gl_link_code
																							 ,@p_contra_gl_link_code		= null
																							 ,@p_agreement_no				= @agreement_no
																							 ,@p_orig_currency_code			= @currency_code
																							 ,@p_orig_amount_db				= 0
																							 ,@p_orig_amount_cr				= @amount
																							 ,@p_exch_rate					= @rate
																							 ,@p_base_amount_db				= 0
																							 ,@p_base_amount_cr				= @base_amount
																							 ,@p_remarks					= @revenue_remarks
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

					if (@deposit_type = 'INSTALLMENT')	
					begin																	
						select	@gl_link_code = gl_link_code 
						from	dbo.master_transaction
						where	code = 'DPINST'
					end
					else if (@deposit_type = 'INSURANCE')	
					begin																	 
						select	@gl_link_code = gl_link_code 
						from	dbo.master_transaction
						where	code = 'DPINSI'
					end
					else if (@deposit_type = 'OTHER')
					begin																	
						select	@gl_link_code = gl_link_code 
						from	dbo.master_transaction
						where	code = 'DPOTH'
					end
					else
					begin
						select	@gl_link_code = gl_link_code 
						from	dbo.master_transaction
						where	code = 'DPSCT'
					end
					
					set @revenue_amount = abs(@revenue_amount)
					set @base_amount = @revenue_amount * @rate;

					exec dbo.xsp_fin_interface_journal_gl_link_transaction_detail_insert @p_id							= 0
																						 ,@p_gl_link_transaction_code	= @gl_link_transaction_code
																						 ,@p_branch_code				= @branch_code
																						 ,@p_branch_name				= @branch_name
																						 ,@p_gl_link_code				= @gl_link_code
																						 ,@p_contra_gl_link_code		= null
																						 ,@p_agreement_no				= @agreement_no
																						 ,@p_orig_currency_code			= @deposit_currency_code
																						 ,@p_orig_amount_db				= @revenue_amount
																						 ,@p_orig_amount_cr				= 0
																						 ,@p_exch_rate					= @rate
																						 ,@p_base_amount_db				= @base_amount
																						 ,@p_base_amount_cr				= 0
																						 ,@p_remarks					= @revenue_remarks
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

				fetch next from cur_deposit_revenue_detail 
				into	@id
						,@deposit_code
						,@revenue_amount
						,@branch_code
						,@branch_name
						,@deposit_currency_code
						,@revenue_date
						,@agreement_no
						,@client_name
						,@agreement_external_no
						,@deposit_type
						,@revenue_remarks
						,@index
			
			end
			close cur_deposit_revenue_detail
			deallocate cur_deposit_revenue_detail
			
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

			update	dbo.deposit_revenue
			set		revenue_status		= 'POST'
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
