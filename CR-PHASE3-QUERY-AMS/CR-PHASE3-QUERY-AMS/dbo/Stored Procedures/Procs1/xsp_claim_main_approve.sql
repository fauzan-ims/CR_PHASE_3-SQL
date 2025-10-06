CREATE PROCEDURE dbo.xsp_claim_main_approve
(		
	@p_code					NVARCHAR(50)
	,@p_claim_amount		DECIMAL(18, 2)
	,@p_is_policy_terminate	NVARCHAR(1) = ''
	,@p_is_ex_gratia		NVARCHAR(1)	= ''
	,@p_result_report_date	DATETIME
	--
	,@p_cre_date			DATETIME
	,@p_cre_by				NVARCHAR(15)
	,@p_cre_ip_address		NVARCHAR(15)
	,@p_mod_date			DATETIME
	,@p_mod_by				NVARCHAR(15)
	,@p_mod_ip_address		NVARCHAR(15)
)
AS
BEGIN
/*
	Log Update :
	hariw 05 May 2020 09:16 pm :	penambahan parameter + perbaikan logic insert ke interface dan remark transaksi
	
*/		
	declare @msg									nvarchar(max)
			,@received_amount						decimal(18, 2)
			,@received_remark						nvarchar(4000)
			,@branch_code							nvarchar(50)
			,@branch_name							nvarchar(250)
			,@claim_progress_remarks				nvarchar(4000)
			,@efam_interface_received_request_code	nvarchar(50)
			,@sp_name								nvarchar(250)
			,@gl_link_code							nvarchar(50)
			,@debet_or_credit						nvarchar(10)
			,@orig_amount_db						decimal(18, 2)
			,@return_value							decimal(18, 2)
			,@currency								nvarchar(3)
			,@process_reff_no						nvarchar(50)
			,@process_reff_name						nvarchar(250)
			,@sum_insured							decimal(12)
			,@system_date							datetime = dbo.xfn_get_system_date()
			,@code_sale								nvarchar(50)
			,@asset_code							nvarchar(50)
			,@claim_amount							decimal(18,2)
			,@sell_request_amount					decimal(18,2)
			,@claim_remark							nvarchar(4000)

	begin try 
	if @p_is_policy_terminate = 'T'
		set @p_is_policy_terminate = '1' ;
	else
		set @p_is_policy_terminate = '0' ;

	if @p_is_ex_gratia = 'T'
		set @p_is_ex_gratia = '1' ;
	else
		set @p_is_ex_gratia = '0' ;

	select	@received_amount		    = cm.claim_amount
			,@claim_progress_remarks    = 'Claim Approve ' + case @p_is_ex_gratia 
																when '1' then 'Ex Gratia' 
																else '' 
															  end
			,@branch_code               = cm.branch_code
			,@branch_name			    = cm.branch_name
			,@currency				    = ipm.currency_code 
			,@process_reff_no			= ipm.policy_no
			,@received_remark		    = 'Receive insurance claim, ' + @p_code + ' for Branch ' + cm.branch_name + ' - ' + cm.claim_remarks
			--,@sum_insured				= sum_insured
			,@process_reff_name			= 'CLAIM APPROVED ' + @p_code + ' for Branch ' + cm.branch_name + ' - ' + cm.claim_remarks
			,@claim_remark				= cm.claim_remarks
	from	dbo.claim_main cm
			inner	join dbo.insurance_policy_main ipm	on (ipm.code = cm.policy_code)
			--inner join asset aa on (aa.code = ipm.fa_code)
	where	cm.code					= @p_code
    		 
		if (@p_claim_amount < 1)
		begin
			set @msg = 'Claim Amount must be greater than 0' ;
			raiserror(@msg, 16, -1) ;
		end
        
		if (@p_claim_amount > @sum_insured)
		begin
			set @msg = 'Claim Amount must be less than sum insured' ;
			raiserror(@msg, 16, -1) ;
		end

		if exists (select 1 from dbo.claim_main 
					where code = @p_code 
					and (result_report_date = NULL 
					or  isnull(claim_amount,'') = NULL)
				)
		begin
			set @msg = 'Please input Result Report To Insurance Date and Claim Amount' ;
			raiserror(@msg, 16, -1) ;
		end
        
		--if(cast(@p_result_report_date as date) < cast(getdate() as date))
		--begin
		--	set @msg = 'Result Report date must be greater than system date.' ;
		--	raiserror(@msg, 16, -1) ;
		--end

		--if(cast(@claim_date as date) < cast(getdate() as date))
		--begin
		--	raiserror('Result Report date must be greater than Client Report date',16,0)
		--	return
		--end

		if exists (select 1 from dbo.claim_main where code = @p_code and claim_status = 'ON PROCESS')
		begin			
			update	dbo.claim_main
			set		claim_status		 = 'APPROVE'
					,claim_amount		 = @p_claim_amount			
					,is_policy_terminate = @p_is_policy_terminate	
					,is_ex_gratia		 = @p_is_ex_gratia			
					,result_report_date  = @p_result_report_date
					--
					,mod_date			 = @p_mod_date		
					,mod_by				 = @p_mod_by			
					,mod_ip_address		 = @p_mod_ip_address
			where	code				 = @p_code

			--insert ke sale request
			exec dbo.xsp_sale_insert @p_code					= @code_sale output
									 ,@p_company_code			= 'DSF'
									 ,@p_sale_date				= @system_date
									 ,@p_description			= ''
									 ,@p_branch_code			= @branch_code
									 ,@p_branch_name			= @branch_name
									 ,@p_sale_amount_header		= @p_claim_amount
									 ,@p_remark					= @claim_remark
									 ,@p_status					= 'HOLD'
									 ,@p_sell_type				= 'CLAIM'
									 ,@p_auction_code			= ''
									 ,@p_buyer_name				= 'CLAIM'
									 ,@p_claim_amount			= @p_claim_amount
									 ,@p_cre_date				= @p_mod_date		
									 ,@p_cre_by					= @p_mod_by			
									 ,@p_cre_ip_address			= @p_mod_ip_address
									 ,@p_mod_date				= @p_mod_date		
									 ,@p_mod_by					= @p_mod_by			
									 ,@p_mod_ip_address			= @p_mod_ip_address

			
			DECLARE curr_sale_req CURSOR FAST_FORWARD READ_ONLY FOR
			SELECT ipa.fa_code
			FROM dbo.claim_detail_asset cda
			LEFT JOIN dbo.claim_main cm ON (cda.claim_code = cm.code)
			LEFT JOIN dbo.insurance_policy_asset ipa ON (ipa.code = cda.policy_asset_code)
			LEFT JOIN dbo.asset ass ON (ass.code = ipa.fa_code)
			WHERE claim_code = @p_code
			
			OPEN curr_sale_req
			
			FETCH NEXT FROM curr_sale_req 
			INTO @asset_code

			WHILE @@fetch_status = 0
			BEGIN
				
				EXEC dbo.xsp_sale_detail_insert @p_id							= 0
												,@p_sale_code					= @code_sale
												,@p_asset_code					= @asset_code
												,@p_description					= @claim_remark
												,@p_total_income				= 0
												,@p_total_expense				= 0
												,@p_buyer_type					= ''
												,@p_buyer_name					= ''
												,@p_buyer_area_phone			= ''
												,@p_buyer_area_phone_no			= ''
												,@p_buyer_address				= ''
												,@p_file_name					= ''
												,@p_file_paths					= ''
												,@p_ktp_no						= ''
												,@p_sale_value					= 0
												,@p_total_fee_amount			= 0
												,@p_total_ppn_amount			= 0
												,@p_total_pph_amount			= 0
												,@p_faktur_no					= ''
												,@p_borrowing_interest_amount	= 0
												,@p_claim_amount				= @p_claim_amount
												,@p_cre_date					= @p_mod_date		
												,@p_cre_by						= @p_mod_by			
												,@p_cre_ip_address				= @p_mod_ip_address
												,@p_mod_date					= @p_mod_date		
												,@p_mod_by						= @p_mod_by			
												,@p_mod_ip_address				= @p_mod_ip_address
				
			    --exec dbo.xsp_sale_detail_insert @p_id						= 0
			    --								,@p_sale_code				= @code_sale
			    --								,@p_asset_code				= @asset_code
			    --								,@p_description				= @claim_remark
			    --								,@p_total_income			= 0
			    --								,@p_total_expense			= 0
			    --								,@p_buyer_type				= ''
			    --								,@p_buyer_name				= ''
			    --								,@p_buyer_area_phone		= ''
			    --								,@p_buyer_area_phone_no		= ''
			    --								,@p_buyer_address			= ''
			    --								,@p_file_name				= ''
			    --								,@p_file_paths				= ''
			    --								,@p_ktp_no					= ''
							--					,@p_sell_request_amount		= @p_claim_amount
			    --								,@p_cre_date				= @p_mod_date		
			    --								,@p_cre_by					= @p_mod_by			
			    --								,@p_cre_ip_address			= @p_mod_ip_address
			    --								,@p_mod_date				= @p_mod_date		
			    --								,@p_mod_by					= @p_mod_by			
			    --								,@p_mod_ip_address			= @p_mod_ip_address
			    
			
			    FETCH NEXT FROM curr_sale_req 
				INTO @asset_code
			END
			
			CLOSE curr_sale_req
			deallocate curr_sale_req
			
			
			--exec dbo.xsp_efam_interface_received_request_insert @p_code						= @efam_interface_received_request_code OUTPUT 		
			--												   ,@p_company_code				= 'DSF' 				   
			--                                                   ,@p_branch_code				= @branch_code                 						 		   
			--                                                   ,@p_branch_name				= @branch_name                        					 			   
			--                                                   ,@p_received_source			= 'CLAIM'                  							 		   
			--                                                   ,@p_received_source_no		= @p_code       
			--												   ,@p_received_request_date	= @system_date       								   
			--                                                   ,@p_received_status			= 'HOLD'                  							 	   
			--                                                   ,@p_received_amount			= @p_claim_amount                 					 		   
			--                                                   ,@p_received_remarks			= @received_remark             					  
			--                                                   ,@p_process_date				= @p_mod_date										 		   
			--                                                   ,@p_process_reff_no			= @process_reff_no	               					 	   
			--                                                   ,@p_process_reff_name		= @process_reff_name     							 		   
			--												   ,@p_settle_date				= null												 		   
			--                                                   ,@p_received_currency_code	= @currency											 	   
			--                                                   ,@p_job_status				= 'HOLD'											 			   
			--                                                   ,@p_failed_remarks			= null    		
			--												   --									 			   
			--                                                   ,@p_cre_date					= @p_cre_date										 		   
			--												   ,@p_cre_by					= @p_cre_by			
			--												   ,@p_cre_ip_address			= @p_cre_ip_address
			--												   ,@p_mod_date					= @p_mod_date		
			--												   ,@p_mod_by					= @p_mod_by			
			--												   ,@p_mod_ip_address			= @p_mod_ip_address
			
			-- loop tabel dbo.master_transaction_parameter mtp  mtp.process_code ='INSPRO4'
			--				join ke MASTER_TRANSACTION
				--declare cur_parameter cursor local fast_forward read_only for
				--select  mt.sp_name
				--		,mtp.debet_or_credit
				--		,mtp.gl_link_code 
				--from	dbo.master_transaction_parameter mtp 
				--		left join dbo.sys_general_subcode sgs on (sgs.code = mtp.process_code)
				--		left join dbo.master_transaction mt on (mt.code = mtp.transaction_code)
				--where	mtp.process_code = 'INSPRO4'	
			
				--open cur_parameter
				--fetch cur_parameter 
				--into @sp_name
				--	 ,@debet_or_credit
				--	 ,@gl_link_code 

				--while @@fetch_status = 0
				--begin
				--	-- nilainya exec dari MASTER_TRANSACTION.sp_name
				--	exec @return_value = @sp_name @p_code ; -- sp ini mereturn value angka 
				--	if @debet_or_credit = 'CREDIT'
				--	begin
				--		set @orig_amount_db = @return_value * -1
				--	end
				--	else
				--	begin
				--		set @orig_amount_db = @return_value
				--	end
		
				--		-- setial loop insert ke efam_INTERFACE_PAYMENT_REQUEST_DETAIL
				--		exec dbo.xsp_efam_interface_received_request_detail_insert @p_received_request_code		= @efam_interface_received_request_code		
				--																   ,@p_company_code				= 'DSF'	
				--		                                                           ,@p_branch_code				= @branch_code											
				--		                                                           ,@p_branch_name				= @branch_name												
				--		                                                           ,@p_gl_link_code				= @gl_link_code												
				--		                                                           ,@p_agreement_no				= null												
				--		                                                           ,@p_facility_code			= null  													
				--		                                                           ,@p_facility_name			= null  													
				--		                                                           ,@p_purpose_loan_code        = null 													
				--		                                                           ,@p_purpose_loan_name        = null 										
				--		                                                           ,@p_purpose_loan_detail_code = null 										
				--		                                                           ,@p_purpose_loan_detail_name = null 										
				--		                                                           ,@p_orig_currency_code		= @currency									
				--		                                                           ,@p_orig_amount				= @orig_amount_db										
				--		                                                           ,@p_division_code            = ''															
				--		                                                           ,@p_division_name            = ''											
				--		                                                           ,@p_department_code          = ''											
				--		                                                           ,@p_department_name          = ''											
				--		                                                           ,@p_remarks					= @process_reff_name
				--																   --						
				--		                                                           ,@p_cre_date					= @p_cre_date		 							
				--		                                                           ,@p_cre_by					= @p_cre_by	
				--		                                                           ,@p_cre_ip_address			= @p_cre_ip_address
				--		                                                           ,@p_mod_date					= @p_mod_date		 
				--		                                                           ,@p_mod_by					= @p_mod_by	 
				--		                                                           ,@p_mod_ip_address			= @p_mod_ip_address	 
						

				--	fetch cur_parameter 
				--	into @sp_name
				--		 ,@debet_or_credit
				--		 ,@gl_link_code 

				--end
				--close cur_parameter
				--deallocate cur_parameter

				select @received_amount  = sum(iipr.received_amount)
				from   dbo.efam_interface_received_request iipr
				where code = @p_code

				select @orig_amount_db = sum(orig_amount) 
				from  dbo.efam_interface_received_request_detail
				where received_request_code = @p_code

				--+ validasi : total detail =  payment_amount yang di header
				if (@received_amount <> @orig_amount_db)
				begin
					set @msg = 'Amount does not balance';
    				raiserror(@msg, 16, -1) ;
				end

			exec dbo.xsp_claim_progress_insert @p_id						= 0                         
			                                   ,@p_claim_code				= @p_code                 
				                               ,@p_claim_progress_code		= 'CPGA'                
				                               ,@p_claim_progress_date		= @system_date
				                               ,@p_claim_progress_remarks	= @claim_progress_remarks             
				                               ,@p_cre_date					= @p_cre_date		
				                               ,@p_cre_by					= @p_cre_by			
				                               ,@p_cre_ip_address			= @p_cre_ip_address
				                               ,@p_mod_date					= @p_mod_date		
				                               ,@p_mod_by					= @p_mod_by			
				                               ,@p_mod_ip_address			= @p_mod_ip_address
			
		end
		else
		begin
		    raiserror('Data already proceed',16,1)
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


