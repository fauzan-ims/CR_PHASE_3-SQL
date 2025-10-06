CREATE PROCEDURE dbo.xsp_termination_main_approve 
(
	@p_code							nvarchar(50)
	,@p_termination_approved_amount decimal(18, 2)
	--
	,@p_cre_date		datetime
	,@p_cre_by			nvarchar(15)
	,@p_cre_ip_address	nvarchar(15)
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg								    nvarchar(max)
			,@branch_code						    nvarchar(50)
			,@branch_name						    nvarchar(250)
			,@termination_remarks				    nvarchar(4000)
			,@efam_interface_received_request_code  nvarchar(50)
			,@sp_name							    nvarchar(250)
			,@gl_link_code						    nvarchar(50)
			,@debet_or_credit					    nvarchar(10)
			,@orig_amount_db					    decimal(18, 2)
			,@received_amount					    decimal(18, 2)
			,@return_value						    decimal(18, 2)
			,@currency							    nvarchar(3)
			,@process_reff_no					    nvarchar(50)
			,@process_reff_name					    nvarchar(250)
			,@estimeted_amount					    decimal(18, 2) 
			,@system_date						    datetime = dbo.xfn_get_system_date()
			,@branch_code_asset					    nvarchar(50)
			,@branch_name_asset					    nvarchar(250)
			,@terminate_remark						nvarchar(4000)
			,@item_name								nvarchar(250)
			,@reason								nvarchar(250)
			,@termination_id						int

	begin try
		
		if @p_termination_approved_amount is null
		begin
			set @msg = 'Please input Approved Amount' ;
			raiserror(@msg, 16, -1) ;
		end
       
		if (@p_termination_approved_amount < 1)
		begin
			set @msg = 'Approved Amount must be greater than 0' ;
			raiserror(@msg, 16, -1) ;
		end

		select	@termination_remarks		= 'Receive insurance termination, ' + @p_code + ' for Branch : ' + tm.branch_name + ' - ' + tm.termination_remarks
				,@branch_code				= tm.branch_code
				,@branch_name				= tm.branch_name
				,@currency					= ipm.currency_code
				--,@process_reff_no			= ipm.fa_code
				,@estimeted_amount			= tm.termination_amount
				,@process_reff_name			= 'TERMINATION APPROVED ' + @p_code + ' for Branch : ' + tm.branch_name +' - ' + tm.termination_remarks
				,@reason					= sgs.description
		from	dbo.termination_main tm
		inner	join dbo.insurance_policy_main ipm	on (ipm.code = tm.policy_code)
		left join dbo.sys_general_subcode sgs on (sgs.code = tm.termination_reason_code)
		where	tm.code					= @p_code
		
		--if (@p_termination_approved_amount > @estimeted_amount)
		--begin
		--	set @msg = 'Approved Amount must be less than Estimated Amount ' + convert(varchar, cast(@estimeted_amount as money), 1) ;
		--	raiserror(@msg, 16, -1) ;
		--end

		if exists (select 1 from dbo.termination_main where code = @p_code and termination_status = 'ON PROCESS')
		begin
					update	dbo.termination_main 
					set		termination_status	= 'APPROVE'
							,termination_approved_amount = @p_termination_approved_amount
							--
							,mod_date			= @p_mod_date		
							,mod_by				= @p_mod_by			
							,mod_ip_address		= @p_mod_ip_address
					where	code				= @p_code
					
					
					exec dbo.xsp_efam_interface_received_request_insert @p_id						= 0
																		,@p_code					= @efam_interface_received_request_code output
																		,@p_company_code			= 'DSF' 
																		,@p_branch_code				= @branch_code
																		,@p_branch_name				= @branch_name
																		,@p_received_source			= 'TERMINATE'
																		,@p_received_request_date	= @system_date
																		,@p_received_source_no		= @p_code
																		,@p_received_status			= 'HOLD' 
																		,@p_received_currency_code	= @currency
																		,@p_received_amount			= @p_termination_approved_amount
																		,@p_received_remarks		= @termination_remarks
																		,@p_process_date			= @p_mod_date
																		,@p_process_reff_no			= @process_reff_no
																		,@p_process_reff_name		= @process_reff_name
																		,@p_settle_date				= null
																		,@p_job_status				= 'HOLD'
																		,@p_failed_remarks			= null
																		--									 			   
																		,@p_cre_date				= @p_cre_date										 		   
																		,@p_cre_by					= @p_cre_by			
																		,@p_cre_ip_address			= @p_cre_ip_address
																		,@p_mod_date				= @p_mod_date		
																		,@p_mod_by					= @p_mod_by			
																		,@p_mod_ip_address			= @p_mod_ip_address 
					
					--exec dbo.xsp_efam_interface_received_request_insert @p_code						= @efam_interface_received_request_code OUTPUT 		
					--												   ,@p_company_code				= 'DSF' 				   
					--												   ,@p_branch_code				= @branch_code                 						 		   
					--												   ,@p_branch_name				= @branch_name                        					 			   
					--												   ,@p_received_source			= 'TERMINATE'                  							 		   
					--												   ,@p_received_source_no		= @p_code       
					--												   ,@p_received_request_date	= @system_date       								   
					--												   ,@p_received_status			= 'HOLD'                  							 	   
					--												   ,@p_received_amount			= @p_termination_approved_amount                 					 		   
					--												   ,@p_received_remarks			= @termination_remarks                					  
					--												   ,@p_process_date				= @p_mod_date										 		   
					--												   ,@p_process_reff_no			= @process_reff_no	               					 	   
					--												   ,@p_process_reff_name		= @process_reff_name     							 		   
					--												   ,@p_settle_date				= null												 		   
					--												   ,@p_received_currency_code	= @currency											 	   
					--												   ,@p_job_status				= 'HOLD'											 			   
					--												   ,@p_failed_remarks			= null    		
					--												   --									 			   
					--												   ,@p_cre_date					= @p_cre_date										 		   
					--												   ,@p_cre_by					= @p_cre_by			
					--												   ,@p_cre_ip_address			= @p_cre_ip_address
					--												   ,@p_mod_date					= @p_mod_date		
					--												   ,@p_mod_by					= @p_mod_by			
					--												   ,@p_mod_ip_address			= @p_mod_ip_address 

					-- loop tabel dbo.master_transaction_parameter mtp  mtp.process_code ='INSPRO6'
					declare cur_parameter cursor local fast_forward read_only for
					--select  mt.sp_name
					--		,mtp.debet_or_credit
					--		,mtp.gl_link_code
					--from	dbo.master_transaction_parameter mtp 
					--		left join dbo.sys_general_subcode sgs on (sgs.code = mtp.process_code)
					--		left join dbo.master_transaction mt on (mt.code = mtp.transaction_code)
					--where	mtp.process_code = 'INSPRO6'
					select	mt.sp_name
							,mtp.debet_or_credit
							,mtp.gl_link_code
							,ass.branch_code
							,ass.branch_name
							,ass.item_name
							,tda.id
					from	dbo.master_transaction_parameter  mtp
							left join dbo.sys_general_subcode sgs on (sgs.code = mtp.process_code)
							left join dbo.master_transaction  mt on (mt.code   = mtp.transaction_code)
							inner join dbo.termination_detail_asset tda on (tda.termination_code = @p_code)
							inner join dbo.insurance_policy_asset ipa on (ipa.code = tda.policy_asset_code)
							inner join dbo.asset ass on (ass.code = ipa.fa_code)
					where	mtp.process_code = 'INSPRO6' ;

			
					open cur_parameter
					fetch cur_parameter 
					into @sp_name
						 ,@debet_or_credit
						 ,@gl_link_code
						 ,@branch_code_asset
						 ,@branch_name_asset
						 ,@item_name
						 ,@termination_id

					while @@fetch_status = 0
					begin
						-- nilainya exec dari MASTER_TRANSACTION.sp_name
						exec @return_value = @sp_name @termination_id ; -- sp ini mereturn value angka 
					    
						if @debet_or_credit = 'CREDIT'
						begin
							set @orig_amount_db = @return_value * -1
						end
						else
						begin
							set @orig_amount_db = @return_value
						end
						
						set @terminate_remark = 'Terminate for asset ' + @item_name + '. Branch : ' + @branch_name_asset + '. Because of : ' + @reason
							-- setial loop insert ke efam_INTERFACE_PAYMENT_REQUEST_DETAIL							
							exec dbo.xsp_efam_interface_received_request_detail_insert @p_id							= 0
																					   ,@p_received_request_code		= @efam_interface_received_request_code
																					   ,@p_company_code					= 'DSF'
																					   ,@p_branch_code					= @branch_code_asset
																					   ,@p_branch_name					= @branch_name_asset
																					   ,@p_gl_link_code					= @gl_link_code
																					   ,@p_agreement_no					= null
																					   ,@p_facility_code				= null
																					   ,@p_facility_name				= null
																					   ,@p_purpose_loan_code			= null
																					   ,@p_purpose_loan_name			= null
																					   ,@p_purpose_loan_detail_code		= null
																					   ,@p_purpose_loan_detail_name		= null
																					   ,@p_orig_currency_code			= @currency
																					   ,@p_orig_amount					= @orig_amount_db
																					   ,@p_division_code				= ''
																					   ,@p_division_name				= ''
																					   ,@p_department_code				= ''
																					   ,@p_department_name				= ''
																					   ,@p_remarks						= @terminate_remark
																					   ,@p_ext_pph_type					= ''
																					   ,@p_ext_vendor_code				= ''
																					   ,@p_ext_vendor_name				= ''
																					   ,@p_ext_vendor_npwp				= ''
																					   ,@p_ext_vendor_address			= ''
																					   ,@p_ext_vendor_type				= ''
																					   ,@p_ext_income_type				= ''
																					   ,@p_ext_income_bruto_amount		= 0
																					   ,@p_ext_tax_rate_pct				= 0
																					   ,@p_ext_pph_amount				= 0
																					   ,@p_ext_description				= ''
																					   ,@p_ext_tax_number				= ''
																					   ,@p_ext_sale_type				= ''
																					   ,@p_ext_tax_date					= ''
																					   --									 			   
																						,@p_cre_date					= @p_cre_date										 		   
																						,@p_cre_by						= @p_cre_by			
																						,@p_cre_ip_address				= @p_cre_ip_address
																						,@p_mod_date					= @p_mod_date		
																						,@p_mod_by						= @p_mod_by			
																						,@p_mod_ip_address				= @p_mod_ip_address 
							
							--exec dbo.xsp_efam_interface_received_request_detail_insert @p_received_request_code		= @efam_interface_received_request_code		
							--														   ,@p_company_code				= 'DSF'	
							--														   ,@p_branch_code				= @branch_code_asset											
							--														   ,@p_branch_name				= @branch_name_asset										
							--														   ,@p_gl_link_code				= @gl_link_code												
							--														   ,@p_agreement_no				= null												
							--														   ,@p_facility_code			= null  													
							--														   ,@p_facility_name			= null  													
							--														   ,@p_purpose_loan_code        = null 													
							--														   ,@p_purpose_loan_name        = null 										
							--														   ,@p_purpose_loan_detail_code = null 										
							--														   ,@p_purpose_loan_detail_name = null 										
							--														   ,@p_orig_currency_code		= @currency									
							--														   ,@p_orig_amount				= @orig_amount_db										
							--														   ,@p_division_code            = ''															
							--														   ,@p_division_name            = ''											
							--														   ,@p_department_code          = ''											
							--														   ,@p_department_name          = ''											
							--														   ,@p_remarks					= @terminate_remark	
							--														   --						
							--														   ,@p_cre_date					= @p_cre_date		 							
							--														   ,@p_cre_by					= @p_cre_by	
							--														   ,@p_cre_ip_address			= @p_cre_ip_address
							--														   ,@p_mod_date					= @p_mod_date		 
							--														   ,@p_mod_by					= @p_mod_by	 
							--														   ,@p_mod_ip_address			= @p_mod_ip_address	  
						
						
						fetch cur_parameter 
						into @sp_name
							 ,@debet_or_credit
							 ,@gl_link_code
							 ,@branch_code_asset
							 ,@branch_name_asset
							 ,@item_name
							 ,@termination_id

					end
					close cur_parameter
					deallocate cur_parameter


					select @received_amount  = isnull(received_amount,0)
					from   dbo.efam_interface_received_request 
					where code = @efam_interface_received_request_code

					select @orig_amount_db = isnull(abs(sum(orig_amount)),0)
					from  dbo.efam_interface_received_request_detail
					where received_request_code = @efam_interface_received_request_code

					--+ validasi : total detail =  payment_amount yang di header
					if (@received_amount <> @orig_amount_db)
					begin
						set @msg = 'Amount does not balance';
    					raiserror(@msg, 16, -1) ;
					end

					update dbo.termination_main 
					set received_request_code = @efam_interface_received_request_code
					where code = @p_code
									
		end
        else
		begin
			set @msg = 'Error data already proceed' ;

			raiserror(@msg, 16, -1) ;
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
end ;


