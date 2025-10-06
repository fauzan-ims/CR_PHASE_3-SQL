CREATE PROCEDURE dbo.xsp_insurance_payment_schedule_renewal_proceed
(
	@p_code			   nvarchar(50)
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
	 
)
as
begin
	declare @msg					   nvarchar(max)
			,@policy_code			   nvarchar(50)
			,@insurance_code		   nvarchar(50)
			,@branch_code			   nvarchar(50)
			,@branch_name			   nvarchar(250)
			,@total_premi_buy_amount   decimal(18, 2)
			,@bank_name				   nvarchar(250)
			,@bank_account_no		   nvarchar(50)
			,@bank_account_name		   nvarchar(250)
			,@payment_remarks		   nvarchar(4000)
			,@policy_payment_type	   nvarchar(5)
			,@policy_eff_date		   datetime
			,@policy_exp_date		   datetime
			,@max_year				   int
			,@currency				   nvarchar(3)
			,@payment_request_code	   nvarchar(50)
			,@agreement_no			   nvarchar(50)
			,@gl_link_code			   nvarchar(50)
			,@sp_name				   nvarchar(250)
			,@transaction_name		   nvarchar(250)
			,@debet_or_credit		   nvarchar(10)
			,@orig_amount			   decimal(18, 2)
			,@return_value			   decimal(18, 2)
			,@payment_amount		   decimal(18, 2)
			,@facility_code			   nvarchar(50)
			,@facility_name			   nvarchar(250)
			,@purpose_loan_code		   nvarchar(50)
			,@purpose_loan_name		   nvarchar(250)
			,@purpose_loan_detail_code nvarchar(50)
			,@purpose_loan_detail_name nvarchar(250)
			,@tax_file_type			   nvarchar(10)
			,@tax_file_no			   nvarchar(50)
			,@fa_code				   nvarchar(50)
			,@is_taxable			   nvarchar(1)
			,@tax_file_name			   nvarchar(250)
			,@insurance_name		   nvarchar(250)
			,@system_date			   datetime = dbo.xfn_get_system_date() ;

	begin try
    
		select @insurance_code	            = pm.insurance_code
				,@branch_code	            = pm.branch_code
				,@branch_name	            = pm.branch_name
				,@policy_code	            = ip.policy_code
				,@total_premi_buy_amount    = ip.total_payment_amount
			    ,@payment_remarks		    = 'Payment Renual Insurance ' --+ pm.fa_code + ' To ' --+ aa.item_name  
				,@currency					= pm.currency_code 
				--,@fa_code					= pm.fa_code
		from dbo.insurance_payment_schedule_renewal ip
				inner join dbo.insurance_policy_main pm on (pm.code = ip.policy_code)
				--inner join dbo.asset aa on (aa.code = pm.fa_code)
				inner join dbo.master_insurance mi on (mi.code = pm.insurance_code)
		where ip.code = @p_code
		
		select top 1 @bank_name           = bank_name
			        ,@bank_account_no     = bank_account_no
			        ,@bank_account_name   = bank_account_name
		from dbo.master_insurance_bank
		where insurance_code = @insurance_code and is_default = '1' 

		if (@bank_name is null)
		begin
			set @msg = 'Please setting default insurance bank' ;
			raiserror(@msg, 16, -1) ;
		end
			select @tax_file_type   = tax_file_type
				   ,@tax_file_no    = tax_file_no
				   ,@tax_file_name	= tax_file_name
				   ,@insurance_name	= insurance_name
			from dbo.master_insurance
			where code = @insurance_code
															    
			exec dbo.xsp_efam_interface_payment_request_insert @p_code					 = @payment_request_code output			  	  
															   ,@p_company_code			 = 'DSF'								  	  
															   ,@p_branch_code			 = @branch_code							  	  
															   ,@p_branch_name			 = @branch_name		 	
															   ,@p_payment_branch_code	 = @branch_code
															   ,@p_payment_branch_name	 = @branch_name		
															   ,@p_payment_request_date	 = @system_date			   
															   ,@p_payment_source		 = 'INSURANCE RENEWAL'								   
															   ,@p_payment_source_no	 = @p_code								  		  
															   ,@p_payment_status		 = 'HOLD'								   
															   ,@p_payment_amount		 = @total_premi_buy_amount				  	  
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
			
				-- loop tabel dbo.master_transaction_parameter mtp  mtp.process_code ='INSPRO9'
				--				join ke MASTER_TRANSACTION
				declare cur_endorse cursor local fast_forward read_only for
				select  mt.sp_name
						,mtp.debet_or_credit
						,mtp.gl_link_code
						,mt.transaction_name
				from	dbo.master_transaction_parameter mtp 
						left join dbo.sys_general_subcode sgs on (sgs.code = mtp.process_code)
						left join dbo.master_transaction mt on (mt.code = mtp.transaction_code)
				where	mtp.process_code = 'INSPRO9'	
			
				open cur_endorse
				fetch cur_endorse 
				into @sp_name
					 ,@debet_or_credit
					 ,@gl_link_code
					 ,@transaction_name

				while @@fetch_status = 0
				begin
					-- nilainya exec dari MASTER_TRANSACTION.sp_name
					exec @return_value = @sp_name @p_code ; -- sp ini mereturn value angka 
				
					if (@debet_or_credit ='DEBIT')
					begin
							set @orig_amount = @return_value

					end
					else
					begin
							set @orig_amount = @return_value * -1
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
						          
					fetch cur_endorse 
					into @sp_name
						 ,@debet_or_credit
						 ,@gl_link_code
						 ,@transaction_name

				end
				close cur_endorse
				deallocate cur_endorse

				select @payment_amount  = isnull(sum(payment_amount),0)
				from dbo.efam_interface_payment_request
				where code = @p_code

				select @orig_amount = isnull(sum(orig_amount),0)
				from dbo.efam_interface_payment_request_detail
				where payment_request_code = @p_code

				--+ validasi : total detail =  payment_amount yang di header
				if (@payment_amount <> @orig_amount)
				begin
					set @msg = 'Amount does not balance';
    				raiserror(@msg, 16, -1) ;
				end

			update dbo.insurance_payment_schedule_renewal
			set payment_renual_status = 'ON PROCESS'
			where code = @p_code

			exec dbo.xsp_insurance_policy_main_history_insert @p_id					= 0
															  ,@p_policy_code		= @policy_code
															  ,@p_history_date		= @p_mod_date
															  ,@p_history_type		= 'PAYMENT RENEWAL PROCEED'
															  ,@p_policy_status		= 'PAYMENT RENEWAL'
															  ,@p_history_remarks	= 'PAYMENT RENEWAL PROCEED'
															  ,@p_cre_date			= @p_mod_date	   
															  ,@p_cre_by			= @p_mod_by		 
															  ,@p_cre_ip_address	= @p_mod_ip_address
															  ,@p_mod_date			= @p_mod_date		 
															  ,@p_mod_by			= @p_mod_by	 
															  ,@p_mod_ip_address	= @p_mod_ip_address
			

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
