CREATE PROCEDURE dbo.xsp_deposit_release_post
(
	@p_code					nvarchar(50)
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
			,@received_request_code			nvarchar(50)
			,@gl_link_code					nvarchar(50)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@payment_branch_code			nvarchar(50)
			,@payment_branch_name			nvarchar(250)
			,@deposit_type					nvarchar(15)
			,@release_date					datetime
			,@release_amount				decimal(18, 2)
			,@release_detail_amount			decimal(18,2)
			,@release_bank_name				nvarchar(250)
			,@release_bank_account_no		nvarchar(50)
			,@release_bank_account_name		nvarchar(250)
			,@release_remarks				nvarchar(4000)
			,@deposit_currency_code			nvarchar(3)
			,@agreement_no			        nvarchar(50)
			,@facility_code			        nvarchar(50)
			,@facility_name			   		nvarchar(250)
			,@purpose_loan_code		   		nvarchar(50)
			,@purpose_loan_name		   		nvarchar(250)
			,@purpose_loan_detail_code  	nvarchar(50)
			,@purpose_loan_detail_name  	nvarchar(250)
			,@agreement_status				nvarchar(10)

	begin try
		select	@payment_branch_code		= am.branch_code
				,@payment_branch_name		= am.branch_name
				,@release_date				= release_date
				,@release_amount			= dr.release_amount
				,@release_bank_name			= release_bank_name
				,@release_bank_account_no	= release_bank_account_no
				,@release_bank_account_name	= release_bank_account_name
				,@deposit_currency_code		= dr.currency_code
				,@deposit_type				= drd.DEPOSIT_TYPE
				,@agreement_no			    = dr.agreement_no
				,@agreement_status			= agreement_status					
				--,@facility_code			    = facility_code			
				--,@facility_name			    = facility_name			
				--,@purpose_loan_code		    = purpose_loan_code		
				--,@purpose_loan_name		    = purpose_loan_name		
				--,@purpose_loan_detail_code   = purpose_loan_detail_code 
				--,@purpose_loan_detail_name   = purpose_loan_detail_name 
				,@release_remarks			= 'Release Deposit, Release No : ' + code + ' for ' + am.agreement_external_no + ' - ' + am.client_name + '. ' + release_remarks
		from	dbo.deposit_release dr
				left join dbo.deposit_release_detail drd on (drd.deposit_release_code = dr.code)
				inner join dbo.agreement_main am on (am.agreement_no = dr.agreement_no)
		where	code = @p_code

		if not exists (select 1 from dbo.deposit_release_detail where deposit_release_code = @p_code)
		begin
			set @msg = 'Please add Deposit';
			raiserror(@msg ,16,-1)
		end
	
		if exists (select 1 from deposit_release_detail where deposit_release_code = @p_code and deposit_type = 'SECURITY') and @agreement_status = 'GO LIVE'
		begin
			set @msg = 'This transaction cant be proceed, Deposit type : ' + @deposit_type + ', Agreement status : ' + @agreement_status;
			raiserror(@msg ,16,-1)
		end

		if exists (select 1 from dbo.deposit_release where code = @p_code and release_status <> 'ON PROCESS')
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed();
			raiserror(@msg ,16,-1)
		end
		else
		begin
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
			else if @deposit_type = 'OTHER'
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


			if exists (SELECT 1 FROM dbo.SYS_GLOBAL_PARAM where CODE = 'BPFRD' and VALUE = 'HO')
			begin
			    select	@branch_name	= description
						,@branch_code	= value 
				from	dbo.sys_global_param
				where	code = 'HO'
			end
			else
			begin
			    set @branch_code = @payment_branch_code
			    set @branch_name = @payment_branch_name
			end
			

			exec dbo.xsp_payment_request_insert @p_code							= @received_request_code output
												,@p_branch_code					= @branch_code
												,@p_branch_name					= @branch_name
												,@p_payment_branch_code			= @payment_branch_code
												,@p_payment_branch_name			= @payment_branch_name
												,@p_payment_source				= N'RELEASE DEPOSIT'
												,@p_payment_request_date		= @release_date
												,@p_payment_source_no			= @p_code
												,@p_payment_status				= N'HOLD'
												,@p_payment_currency_code		= @deposit_currency_code
												,@p_payment_amount				= @release_amount
												,@p_payment_remarks				= @release_remarks
												,@p_to_bank_name				= @release_bank_name			
												,@p_to_bank_account_name		= @release_bank_account_name	
												,@p_to_bank_account_no			= @release_bank_account_no
												,@p_payment_transaction_code	= null
												,@p_tax_payer_reff_code         = null
			                                    ,@p_tax_type				    = null
			                                    ,@p_tax_file_no			        = null
			                                    ,@p_tax_file_name		        = null
												,@p_cre_date					= @p_cre_date		
												,@p_cre_by						= @p_cre_by			
												,@p_cre_ip_address				= @p_cre_ip_address
												,@p_mod_date					= @p_mod_date		
												,@p_mod_by						= @p_mod_by			
												,@p_mod_ip_address				= @p_mod_ip_address
			 

			declare cur_deposit_release_detail cursor fast_forward read_only for
			
			select	srd.deposit_type
					,srd.release_amount
			from	dbo.deposit_release_detail srd
			where	srd.deposit_release_code = @p_code

			open cur_deposit_release_detail
		
			fetch next from cur_deposit_release_detail 
			into	@deposit_type
					,@release_detail_amount

			while @@fetch_status = 0
			begin

				-- journal
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
					else if @deposit_type = 'OTHER'
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

					exec dbo.xsp_payment_request_detail_insert @p_id						= 0
															   ,@p_payment_request_code		= @received_request_code
															   ,@p_branch_code				= @payment_branch_code
															   ,@p_branch_name				= @payment_branch_name
															   ,@p_gl_link_code				= @gl_link_code
															   ,@p_agreement_no				= @agreement_no			  
															   ,@p_facility_code			= null --@facility_code			  
															   ,@p_facility_name			= null --@facility_name			  
															   ,@p_purpose_loan_code		= null --@purpose_loan_code		  
															   ,@p_purpose_loan_name		= null --@purpose_loan_name		  
															   ,@p_purpose_loan_detail_code = null --@purpose_loan_detail_code
															   ,@p_purpose_loan_detail_name = null --@purpose_loan_detail_name
															   ,@p_orig_currency_code		= @deposit_currency_code
															   ,@p_orig_amount				= @release_detail_amount
															   ,@p_division_code			= null
															   ,@p_division_name			= null
															   ,@p_department_code			= null
															   ,@p_department_name			= null
															   ,@p_remarks					= @release_remarks
															   ,@p_cre_date					= @p_cre_date		
															   ,@p_cre_by					= @p_cre_by			
															   ,@p_cre_ip_address			= @p_cre_ip_address
															   ,@p_mod_date					= @p_mod_date		
															   ,@p_mod_by					= @p_mod_by			
															   ,@p_mod_ip_address			= @p_mod_ip_address

				
				fetch next from cur_deposit_release_detail 
				into	@deposit_type
						,@release_detail_amount
			
			end
			close cur_deposit_release_detail
			deallocate cur_deposit_release_detail

			update	dbo.deposit_release
			set		release_status		= 'APPROVE'
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

