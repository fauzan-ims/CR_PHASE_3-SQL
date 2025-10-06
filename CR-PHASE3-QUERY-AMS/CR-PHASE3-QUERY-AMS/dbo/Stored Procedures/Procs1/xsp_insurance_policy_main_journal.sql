/*
exec xsp_insurance_policy_main_journal
*/
-- Louis Senin, 13 Maret 2023 15.43.45 -- 
CREATE PROCEDURE dbo.xsp_insurance_policy_main_journal
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
	declare @msg			   nvarchar(max)
			,@gllink_trx_code  nvarchar(50)
			,@branch_code	   nvarchar(50)
			,@branch_name	   nvarchar(250)
			,@gl_link_code	   nvarchar(50)
			,@debet_or_credit  nvarchar(10)
			,@currency		   nvarchar(3)
			,@orig_amount_db   decimal(18, 2)
			,@orig_amount_cr   decimal(18, 2)
			,@transaction_name nvarchar(250)
			,@transaction_code nvarchar(50)
			,@sp_name		   nvarchar(250)
			,@return_value	   decimal(18, 2) ;

	
	begin try
		select	@branch_code = branch_code
				,@branch_name = branch_name
				,@currency = currency_code
		from	dbo.insurance_policy_main
		where	code = @p_reff_code ;

		exec dbo.xsp_efam_interface_journal_gl_link_transaction_insert	@p_code						= @gllink_trx_code output	
																		,@p_company_code			= 'DSF'	 						
																		,@p_branch_code				= @branch_code					 			
																		,@p_branch_name				= @branch_name					 		
																		,@p_transaction_status		= 'HOLD'						 		
																		,@p_transaction_date		= @p_trx_date					 
																		,@p_transaction_value_date	= @p_value_date					 
																		,@p_transaction_code		= @p_reff_code					 
																		,@p_transaction_name		= @p_reff_name					 
																		,@p_reff_module_code		= 'IFINOPL'						 
																		,@p_reff_source_no			= @p_reff_code					 
																		,@p_reff_source_name		= @p_reff_name	
																		,@p_is_journal_reversal		= '0'
																		,@p_transaction_type		= null
																		--				 	
																		,@p_cre_date				= @p_mod_date					 
																		,@p_cre_by					= @p_mod_by						 		
																		,@p_cre_ip_address			= @p_mod_ip_address				 	
																		,@p_mod_date				= @p_mod_date
																		,@p_mod_by					= @p_mod_by
																		,@p_mod_ip_address			= @p_mod_ip_address
		begin
		 
			declare c_jurnal cursor local fast_forward read_only for
			select  mt.sp_name
					,mtp.debet_or_credit
					,mtp.gl_link_code
					,mt.transaction_name
					,mt.code
			from	dbo.master_transaction_parameter mtp 
					left join dbo.sys_general_subcode sgs on (sgs.code = mtp.process_code)
					left join dbo.master_transaction mt on (mt.code = mtp.transaction_code)
			where	mtp.process_code = 'INSPR10'

			open c_jurnal
			fetch c_jurnal 
			into @sp_name
				,@debet_or_credit
				,@gl_link_code
			    ,@transaction_name
			    ,@transaction_code

			while @@fetch_status = 0
			begin

				-- nilainya exec dari MASTER_TRANSACTION.sp_name
				exec @return_value = @sp_name @p_reff_code ; -- sp ini mereturn value angka 

				if (@debet_or_credit ='DEBIT')
				begin
						set @orig_amount_db = @return_value
						set @orig_amount_cr = 0
				end
				else
				begin
						set @orig_amount_db = 0
						set @orig_amount_cr = @return_value
				end

				--adjustment
				if @transaction_code in
				(
					'ANETBUY', 'APREMIDISC', 'PREMIADJUS', 'PREMIPPH'
				)
				   and	@return_value < 0
				begin
					set @orig_amount_cr = abs(@return_value) ;
					set @orig_amount_db = 0 ;
				end ;
				else if @transaction_code in
					 (
						 'ANETBUY', 'APREMIDISC', 'PREMIADJUS', 'PREMIPPH'
					 )
						and @return_value > 0
				begin
					set @orig_amount_cr = 0 ;
					set @orig_amount_db = @return_value ;
				end ;

				if @transaction_code in
				(
					'PREMIPPN'
				)
				   and	@return_value > 0
				begin
					set @orig_amount_cr = @return_value ;
					set @orig_amount_db = 0 ;
				end ;
				else if @transaction_code in
					 (
						 'PREMIPPN'
					 )
						and @return_value < 0
				begin
					set @orig_amount_cr = 0 ;
					set @orig_amount_db = abs(@return_value) ;
				end ;

				if (isnull(@gl_link_code, '') = '')
				begin
					set @msg = 'Please Setting GL Link For ' + @transaction_name ;

					raiserror(@msg, 16, -1) ;
				end ;

					
					exec dbo.xsp_efam_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code	 = @gllink_trx_code
																						  ,@p_company_code				 = 'DSF'
																						  ,@p_cost_center_code			 = null
																						  ,@p_cost_center_name			 = null   
																						  ,@p_branch_code				 = @branch_code					 
																						  ,@p_branch_name				 = @branch_name					  
																						  ,@p_gl_link_code				 = @gl_link_code				  
																						  ,@p_agreement_no				 = null				  
																						  ,@p_facility_code				 = null							  
																						  ,@p_facility_name				 = null	  
																						  ,@p_purpose_loan_code			 = null	  
																						  ,@p_purpose_loan_name			 = null	  
																						  ,@p_purpose_loan_detail_code   = null	  
																						  ,@p_purpose_loan_detail_name   = null	  
																						  ,@p_orig_currency_code		 = @currency					 
																						  ,@p_orig_amount_db			 = @orig_amount_db				 
																						  ,@p_orig_amount_cr			 = @orig_amount_cr				 
																						  ,@p_exch_rate					 = 1							 
																						  ,@p_base_amount_db			 = @orig_amount_db				 
																						  ,@p_base_amount_cr			 = @orig_amount_cr				 
																						  ,@p_division_code				 = ''							 
																						  ,@p_division_name				 = ''							 
																						  ,@p_department_code			 = ''							 
																						  ,@p_department_name			 = ''							 
																						  ,@p_remarks					 = @transaction_name			 
																						  --															 
																						  ,@p_cre_date					 = @p_mod_date					 
																						  ,@p_cre_by					 = @p_mod_by					 
																						  ,@p_cre_ip_address			 = @p_mod_ip_address
																						  ,@p_mod_date					 = @p_mod_date
																						  ,@p_mod_by					 = @p_mod_by
																						  ,@p_mod_ip_address			 = @p_mod_ip_address

				fetch c_jurnal 
				into @sp_name
					,@debet_or_credit
					,@gl_link_code
					,@transaction_name
					,@transaction_code

			end
			close c_jurnal
			deallocate c_jurnal

		end

		-- balancing
		begin
			if ((
					select	sum(orig_amount_db) - sum(orig_amount_cr)
					from	dbo.efam_interface_journal_gl_link_transaction_detail
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
