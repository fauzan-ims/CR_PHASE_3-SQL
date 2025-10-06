-- Louis Rabu, 08 Februari 2023 15.34.20 -- 
CREATE PROCEDURE [dbo].[xsp_endorsement_main_payment_request]
(
	@p_code				nvarchar(50)
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
	declare @msg						 nvarchar(max)
			,@payment_request_code		 nvarchar(50)
			,@branch_code				 nvarchar(50)
			,@branch_name				 nvarchar(250)
			,@endorsement_payment_amount decimal(18, 2)
			,@bank_name					 nvarchar(250)
			,@bank_account_no			 nvarchar(50)
			,@bank_account_name			 nvarchar(250)
			,@insurance_code			 nvarchar(50)
			,@payment_remarks			 nvarchar(4000)
			,@sp_name					 nvarchar(250)
			,@debet_or_credit			 nvarchar(10)
			,@orig_amount				 decimal(18, 2)
			,@payment_amount			 decimal(18, 2)
			,@gl_link_code				 nvarchar(50)
			,@return_value				 decimal(18, 2)
			,@currency					 nvarchar(3) 
			,@tax_file_type				 nvarchar(10)
			,@tax_file_no				 nvarchar(50)
			,@fa_code					 nvarchar(50)
			,@tax_file_name				 nvarchar(250)
			,@system_date				 datetime = dbo.xfn_get_system_date() ;

	begin try	
							
			select  @branch_code					= em.branch_code
					,@branch_name					= em.branch_name
					,@endorsement_payment_amount	= isnull(em.endorsement_payment_amount, 0)
					,@payment_remarks				= 'Payment endorsement no ' + em.code + ' ' + mi.insurance_name + ', for '-- + ipm.fa_code + ' - ' + aa.item_name
					,@insurance_code				= ipm.insurance_code  
					,@currency					    = ipm.currency_code 
					--,@fa_code						= ipm.fa_code
			from    dbo.endorsement_main em
					left join dbo.insurance_policy_main ipm on (ipm.code = em.policy_code)
					--left join dbo.asset aa on (aa.code =ipm.fa_code)
					left join dbo.master_insurance mi on (mi.code = ipm.insurance_code)
			where	em.code = @p_code
			
			select top 1 @bank_name           = isnull(bank_name, '')
						,@bank_account_no     = isnull(bank_account_no, '')
						,@bank_account_name   = isnull(bank_account_name, '')
			from dbo.master_insurance_bank mib  
			where mib.insurance_code = @insurance_code and is_default = '1'

			select @tax_file_type   = tax_file_type
			 	   ,@tax_file_no    = tax_file_no
				   ,@tax_file_name  = tax_file_name
			from dbo.master_insurance
			where code = @insurance_code
	
			exec dbo.xsp_efam_interface_payment_request_insert @p_code					 = @payment_request_code output			  	  
															   ,@p_company_code			 = 'DSF'								  	  
															   ,@p_branch_code			 = @branch_code							  	  
															   ,@p_branch_name			 = @branch_name		 	
															   ,@p_payment_branch_code	 = @branch_code
															   ,@p_payment_branch_name	 = @branch_name		
															   ,@p_payment_request_date	 = @system_date			   
															   ,@p_payment_source		 = 'ENDORSE'								   
															   ,@p_payment_source_no	 = @p_code								  		  
															   ,@p_payment_status		 = 'HOLD'								   
															   ,@p_payment_amount		 = @endorsement_payment_amount				  	  
															   ,@p_to_bank_account_name  = @bank_account_name    			   
															   ,@p_to_bank_name			 = @bank_name           				  		  
															   ,@p_to_bank_account_no	 = @bank_account_no      			  		  
															   ,@p_payment_remarks		 = @payment_remarks						    
															   ,@p_process_date			 = @p_cre_date							  		  
															   ,@p_process_reff_no		 = null									  	  
															   ,@p_process_reff_name	 = null									  			  
															   ,@p_settle_date			 = null									  			  
															   ,@p_payment_currency_code = @currency							  	  
															   ,@p_tax_payer_reff_code	 = @insurance_code						  		  
															   ,@p_tax_type				 = @tax_file_type						  		  
															   ,@p_tax_file_no			 = @tax_file_no							  		  
															   ,@p_tax_file_name		 = @tax_file_name						    	  
															   ,@p_job_status			 = 'HOLD'								  			  
															   ,@p_failed_remarks		 = ''									  			  
															   --						 										  	  
															   ,@p_cre_date				 = @p_cre_date
															   ,@p_cre_by				 = @p_cre_by
															   ,@p_cre_ip_address		 = @p_cre_ip_address
															   ,@p_mod_date				 = @p_mod_date
															   ,@p_mod_by				 = @p_mod_by
															   ,@p_mod_ip_address		 = @p_mod_ip_address ;  

				-- loop tabel dbo.master_transaction_parameter mtp  mtp.process_code ='INSPRO5'
				--				join ke MASTER_TRANSACTION
				declare cur_paymentrequest cursor local fast_forward read_only for
				select  mt.sp_name
						,mtp.debet_or_credit
						,mtp.gl_link_code
				from	dbo.master_transaction_parameter mtp 
						left join dbo.sys_general_subcode sgs on (sgs.code = mtp.process_code)
						left join dbo.master_transaction mt on (mt.code = mtp.transaction_code)
				where	mtp.process_code = 'INSPRO5'	
			
				open cur_paymentrequest
				fetch cur_paymentrequest 
				into @sp_name
					 ,@debet_or_credit
					 ,@gl_link_code

				while @@fetch_status = 0
				begin
					-- nilainya exec dari MASTER_TRANSACTION.sp_name
					exec @return_value = @sp_name @p_code ; -- sp ini mereturn value angka 

					if (@debet_or_credit = 'DEBIT')
						begin
							set @orig_amount = @return_value
						end
					else
					begin
							set @orig_amount = @return_value 
					end
					
						-- setial loop insert ke efam_interface_payment_request_detail
						exec dbo.xsp_efam_interface_payment_request_detail_insert @p_payment_request_code	   = @payment_request_code		 
																				  ,@p_company_code			   = 'DSF'	 
						                                                          ,@p_branch_code		       = @branch_code				 			 
						                                                          ,@p_branch_name		       = @branch_name				 				 
						                                                          ,@p_gl_link_code		       = @gl_link_code				 				 
						                                                          ,@p_fa_code			       = @fa_code						 			 
						                                                          ,@p_facility_code		       = null		     			 					 
						                                                          ,@p_facility_name		       = null		     			 			 
						                                                          ,@p_purpose_loan_code        = null						 			 
						                                                          ,@p_purpose_loan_name        = null						 		 
						                                                          ,@p_purpose_loan_detail_code = null						 		 
						                                                          ,@p_purpose_loan_detail_name = null						  
						                                                          ,@p_orig_currency_code	   = @currency					  
						                                                          ,@p_orig_amount	           = @orig_amount				 		 
						                                                          ,@p_division_code            = ''							 				 
						                                                          ,@p_division_name            = ''							 			 
						                                                          ,@p_department_code          = ''							 			 
						                                                          ,@p_department_name          = ''							 			 
						                                                          ,@p_remarks				   = @payment_remarks			 			 
																				  --			 
						                                                          ,@p_cre_date				   = @p_cre_date		 
						                                                          ,@p_cre_by				   = @p_cre_by	
						                                                          ,@p_cre_ip_address		   = @p_cre_ip_address
						                                                          ,@p_mod_date				   = @p_mod_date		 
						                                                          ,@p_mod_by				   = @p_mod_by	 
						                                                          ,@p_mod_ip_address		   = @p_mod_ip_address	 	 
					
					fetch cur_paymentrequest 
					into @sp_name
						 ,@debet_or_credit
						 ,@gl_link_code

				end
				close cur_paymentrequest
				deallocate cur_paymentrequest

				select @payment_amount  = sum(payment_amount)
				from dbo.efam_interface_payment_request
				where code = @p_code

				select @orig_amount	= sum(orig_amount) 
				from dbo.efam_interface_payment_request_detail
				where payment_request_code = @p_code

				--+ validasi : total detail =  payment_amount yang di header
				if (@payment_amount <> @orig_amount)
				begin
					set @msg = 'Amount does not balance';
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
		else if (@error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used() ;
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




