CREATE PROCEDURE dbo.xsp_et_main_to_cashier_received_request_insert_deposit
(
	@p_code					nvarchar(50)
	,@p_transaction_amount	decimal(18,2)
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
	declare @msg							nvarchar(max)
			,@cashier_received_request_code	nvarchar(50)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250) 
			,@currency						nvarchar(3)
			,@agreement_no					nvarchar(50)
			,@facility_code					nvarchar(50)
			,@facility_name					nvarchar(250)
			,@purpose_loan_code				nvarchar(50)
			,@purpose_loan_name				nvarchar(250)
			,@purpose_loan_detail_code		nvarchar(50)
			,@purpose_loan_detail_name		nvarchar(250)
			,@doc_ref_name					nvarchar(250)
			,@remark						nvarchar(4000) 

	begin try
	 
		set @doc_ref_name = 'DEPOSIT FINTECH' 
		
		select	@branch_code				= et.branch_code
				,@branch_name				= et.branch_name
				,@agreement_no				= et.agreement_no 
				,@remark					= 'DEPOSIT FINTECH ' + am.agreement_external_no + ' - ' + am.client_name + ' ' + et.et_remarks
				,@currency					= am.currency_code
				,@facility_code				= am.facility_code
				,@facility_name				= am.facility_name
				,@purpose_loan_code			= null
				,@purpose_loan_name			= null
				,@purpose_loan_detail_code	= null
				,@purpose_loan_detail_name	= null
		from	dbo.et_main et 
				inner join agreement_main am on (am.agreement_no = et.agreement_no)
		where	code = @p_code
		
		--exec dbo.xsp_lms_interface_cashier_received_request_insert @p_code						= @cashier_received_request_code output
		--															,@p_branch_code				= @branch_code 
		--															,@p_branch_name				= @branch_name
		--															,@p_request_status			= N'HOLD'
		--															,@p_request_currency_code	= @currency 
		--															,@p_request_date			= @p_mod_date
		--															,@p_request_amount			= @p_transaction_amount 
		--															,@p_request_remarks			= @remark
		--															,@p_agreement_no			= @agreement_no
		--															,@p_pdc_code				= NULL
		--															,@p_pdc_no					= NULL
		--															,@p_doc_ref_code			= @p_code
		--															,@p_doc_ref_name			= @doc_ref_name
		--															,@p_process_date			= null
		--															,@p_process_reff_no			= null
		--															,@p_process_reff_name		= null
		--															,@p_cre_date				= @p_mod_date		
		--															,@p_cre_by					= @p_mod_by			
		--															,@p_cre_ip_address			= @p_mod_ip_address
		--															,@p_mod_date				= @p_mod_date		
		--															,@p_mod_by					= @p_mod_by			
		--															,@p_mod_ip_address			= @p_mod_ip_address
		
		begin 
			set @p_transaction_amount = @p_transaction_amount * -1;
			--exec dbo.xsp_lms_interface_cashier_received_request_detail_insert @p_id									= 0
			--																	,@p_cashier_received_request_code	= @cashier_received_request_code 
			--																	,@p_branch_code						= @branch_code
			--																	,@p_branch_name						= @branch_name
			--																	,@p_gl_link_code					= 'DPINST'
			--																	,@p_agreement_no					= @agreement_no				
			--																	,@p_facility_code					= @facility_code				
			--																	,@p_facility_name					= @facility_name				
			--																	,@p_purpose_loan_code				= @purpose_loan_code			
			--																	,@p_purpose_loan_name				= @purpose_loan_name			
			--																	,@p_purpose_loan_detail_code		= @purpose_loan_detail_code	
			--																	,@p_purpose_loan_detail_name		= @purpose_loan_detail_name	
			--																	,@p_orig_currency_code				= @currency
			--																	,@p_orig_amount						= @p_transaction_amount 
			--																	,@p_division_code					= null
			--																	,@p_division_name					= null
			--																	,@p_department_code					= null
			--																	,@p_department_name					= null
			--																	,@p_remarks							= 'DEPOSIT FINTECH' 
			--																	,@p_cre_date						= @p_cre_date	   
			--																	,@p_cre_by							= @p_cre_by		   
			--																	,@p_cre_ip_address					= @p_cre_ip_address 
			--																	,@p_mod_date						= @p_mod_date	   
			--																	,@p_mod_by							= @p_mod_by		   
			--																	,@p_mod_ip_address					= @p_mod_ip_address 
					 
					 
		end 
		set @msg = dbo.xfn_finance_request_check_balance('CASHIER', @cashier_received_request_code) ;

		if @msg <> ''
		begin
			raiserror(@msg, 16, 1) ;
		end ;

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
	
	


