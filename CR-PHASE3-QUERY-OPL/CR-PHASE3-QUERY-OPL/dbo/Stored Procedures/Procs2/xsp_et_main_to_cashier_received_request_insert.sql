CREATE PROCEDURE [dbo].[xsp_et_main_to_cashier_received_request_insert]
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
	declare @msg							nvarchar(max)
			,@cashier_received_request_code	nvarchar(50)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@gl_link_code					nvarchar(50)
			,@transaction_amount			decimal(18,2)
			,@debet_or_credit				nvarchar(10)
			,@currency						nvarchar(3)
			,@agreement_no					nvarchar(50)
			,@facility_code					nvarchar(50)
			,@facility_name					nvarchar(250)
			,@purpose_loan_code				nvarchar(50)
			,@purpose_loan_name				nvarchar(250)
			,@purpose_loan_detail_code		nvarchar(50)
			,@purpose_loan_detail_name		nvarchar(250)
			,@doc_ref_name					nvarchar(250)
			,@et_amount 					decimal(18,2)
			,@remark						nvarchar(4000)
			,@is_discount_jurnal			nvarchar(1)
			,@disc_amount					decimal(18,2)
			,@transaction_name				nvarchar(250)
			,@process_code					nvarchar(50)
			,@discount_gl_link_code			nvarchar(50) 
			,@transaction_code				nvarchar(50)
			,@client_no						nvarchar(50)	 = null -- Louis Rabu, 25 Juni 2025 10.52.37 -- 
			,@client_name					nvarchar(250)	 = null -- Louis Rabu, 25 Juni 2025 10.52.37 --

	begin try
	 
		set @doc_ref_name = 'EARLY TERMINATION'
		
		select	@branch_code				= et.branch_code
				,@branch_name				= et.branch_name
				,@agreement_no				= et.agreement_no
				,@et_amount					= et.et_amount
				,@remark					= 'EARLY TERMINATION ' + am.agreement_external_no + ' - ' + am.client_name + ' ' + et.et_remarks
				,@currency					= am.currency_code
				,@facility_code				= am.facility_code
				,@facility_name				= am.facility_name
				,@purpose_loan_code			= null
				,@purpose_loan_name			= null
				,@purpose_loan_detail_code	= null
				,@purpose_loan_detail_name	= null
				,@process_code				= 'ET'
				,@client_no					= client_no -- Louis Rabu, 25 Juni 2025 10.52.37 -- 
				,@client_name				= client_name -- Louis Rabu, 25 Juni 2025 10.52.37 --
		from	dbo.et_main et 
				inner join agreement_main am on (am.agreement_no = et.agreement_no)
		where	code = @p_code
		
		exec dbo.xsp_opl_interface_cashier_received_request_insert @p_code						= @cashier_received_request_code output
																	,@p_branch_code				= @branch_code 
																	,@p_branch_name				= @branch_name
																	,@p_request_status			= N'HOLD'
																	,@p_request_currency_code	= @currency 
																	,@p_request_date			= @p_mod_date
																	,@p_request_amount			= @et_amount 
																	,@p_request_remarks			= @remark
																	,@p_agreement_no			= @agreement_no
																	,@p_client_no				= @client_no	 -- Louis Rabu, 25 Juni 2025 10.52.37 -- 
																	,@p_client_name				= @client_name	 -- Louis Rabu, 25 Juni 2025 10.52.37 --
																	,@p_pdc_code				= NULL
																	,@p_pdc_no					= NULL
																	,@p_doc_reff_code			= @p_code
																	,@p_doc_reff_name			= @doc_ref_name
																	,@p_doc_reff_fee_code		= null
																	,@p_process_date			= null
																	,@p_process_reff_no			= null
																	,@p_process_reff_name		= null
																	,@p_cre_date				= @p_mod_date		
																	,@p_cre_by					= @p_mod_by			
																	,@p_cre_ip_address			= @p_mod_ip_address
																	,@p_mod_date				= @p_mod_date		
																	,@p_mod_by					= @p_mod_by			
																	,@p_mod_ip_address			= @p_mod_ip_address
		
		begin 
			declare c_jurnal cursor local fast_forward read_only for
			select	mtp.gl_link_code
					,case et.transaction_code
						 when 'SCDP' then rv.total_amount
						 else et.transaction_amount
					 end
					,mtp.debet_or_credit
					,mtp.is_discount_jurnal
					,et.disc_amount
					,mt.transaction_name
					,mtp.discount_gl_link_code
					,et.transaction_code
			from	dbo.et_transaction et
					inner join dbo.master_transaction_parameter mtp on (
																		   mtp.transaction_code = et.transaction_code
																		   and mtp.process_code = @process_code
																	   )
					inner join dbo.master_transaction mt on (mt.code = et.transaction_code)
					outer apply
			(
				select	total_amount
				from	dbo.et_transaction
				where	et_code				 = @p_code
						and transaction_code = 'RSDV'
			) rv
			where	et_code			   = @p_code
					and mtp.is_journal = '1' ;

			open c_jurnal
			fetch c_jurnal 
			into @gl_link_code
				,@transaction_amount
				,@debet_or_credit
				,@is_discount_jurnal
				,@disc_amount
				,@transaction_name
				,@discount_gl_link_code
				,@transaction_code

			while @@fetch_status = 0
			begin
					set @transaction_amount = abs(@transaction_amount);
					if (isnull(@gl_link_code, '') = '')
					begin
						set @msg = 'Please Setting GL Link For ' +@transaction_name;
						raiserror(@msg, 16, -1);
					end
					if (@is_discount_jurnal <> '1')
					begin
						set @transaction_amount = @transaction_amount - @disc_amount ;
					end ;

					if (@debet_or_credit = 'CREDIT')
					begin
						set @transaction_amount = @transaction_amount * -1 ;
						set @disc_amount = @disc_amount ;
					end ;
					else
					begin
						if (@transaction_code = 'OVD_INTER')
						begin
							set @disc_amount = @disc_amount ;
						end ;
						else
						begin
							set @disc_amount = @disc_amount * -1 ;
						end ;
					end ;
                   
					
					if (@transaction_amount <> 0)
					begin
						exec dbo.xsp_opl_interface_cashier_received_request_detail_insert @p_id								= 0
																						  ,@p_cashier_received_request_code	= @cashier_received_request_code 
																						  ,@p_branch_code					= @branch_code
																						  ,@p_branch_name					= @branch_name
																						  ,@p_gl_link_code					= @gl_link_code
																						  ,@p_agreement_no					= @agreement_no				
																						  ,@p_facility_code					= @facility_code				
																						  ,@p_facility_name					= @facility_name				
																						  ,@p_purpose_loan_code				= @purpose_loan_code			
																						  ,@p_purpose_loan_name				= @purpose_loan_name			
																						  ,@p_purpose_loan_detail_code		= @purpose_loan_detail_code	
																						  ,@p_purpose_loan_detail_name		= @purpose_loan_detail_name	
																						  ,@p_orig_currency_code			= @currency
																						  ,@p_orig_amount					= @transaction_amount 
																						  ,@p_division_code					= null
																						  ,@p_division_name					= null
																						  ,@p_department_code				= null
																						  ,@p_department_name				= null
																						  ,@p_remarks						= @transaction_name
																						  ,@p_cre_date						= @p_cre_date	   
																						  ,@p_cre_by						= @p_cre_by		   
																						  ,@p_cre_ip_address				= @p_cre_ip_address 
																						  ,@p_mod_date						= @p_mod_date	   
																						  ,@p_mod_by						= @p_mod_by		   
																						  ,@p_mod_ip_address				= @p_mod_ip_address 
					end
					
					if (@is_discount_jurnal ='1')
					begin
						if (@disc_amount <> 0)
						begin
							if (isnull(@discount_gl_link_code, '') = '')
							begin
								set @msg = 'Please Setting Discount GL Link For ' +@transaction_name;
								raiserror(@msg, 16, -1);
							end
							set @remark = 'DISCOUNT ' + @transaction_name ;
							--set @disc_amount = @disc_amount * -1;
							
							exec dbo.xsp_opl_interface_cashier_received_request_detail_insert @p_id								= 0
																							  ,@p_cashier_received_request_code = @cashier_received_request_code 
																							  ,@p_branch_code					= @branch_code
																							  ,@p_branch_name					= @branch_name
																							  ,@p_gl_link_code					= @discount_gl_link_code
																							  ,@p_agreement_no					= @agreement_no				
																							  ,@p_facility_code					= @facility_code				
																							  ,@p_facility_name					= @facility_name				
																							  ,@p_purpose_loan_code				= @purpose_loan_code			
																							  ,@p_purpose_loan_name				= @purpose_loan_name			
																							  ,@p_purpose_loan_detail_code		= @purpose_loan_detail_code	
																							  ,@p_purpose_loan_detail_name		= @purpose_loan_detail_name	
																							  ,@p_orig_currency_code			= @currency
																							  ,@p_orig_amount					= @disc_amount 
																							  ,@p_division_code					= null
																							  ,@p_division_name					= null
																							  ,@p_department_code				= null
																							  ,@p_department_name				= null
																							  ,@p_remarks						= @remark
																							  ,@p_cre_date						= @p_cre_date	   
																							  ,@p_cre_by						= @p_cre_by		   
																							  ,@p_cre_ip_address				= @p_cre_ip_address 
																							  ,@p_mod_date						= @p_mod_date	   
																							  ,@p_mod_by						= @p_mod_by		   
																							  ,@p_mod_ip_address				= @p_mod_ip_address 
						end
					end
					
					fetch c_jurnal 
					into @gl_link_code
						,@transaction_amount
						,@debet_or_credit
						,@is_discount_jurnal
						,@disc_amount
						,@transaction_name
						,@discount_gl_link_code
						,@transaction_code
						
			end
			close c_jurnal
			deallocate c_jurnal

		end 
		set @msg = dbo.xfn_finance_request_check_balance('CASHIER', @cashier_received_request_code) ;

		if @msg <> ''
		begin
			raiserror(@msg, 16, 1) ;
		end ;

	end try
	begin catch

		declare @error int ;
		begin -- close cursor
			if cursor_status('global', 'c_jurnal') >= -1
			begin
				if cursor_status('global', 'c_jurnal') > -1
				begin
					close c_jurnal ;
				end ;

				deallocate c_jurnal ;
			end ;
		end ;

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
	
	




