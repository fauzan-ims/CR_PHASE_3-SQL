CREATE PROCEDURE dbo.application_fee_to_interface_cashier_receive_insert
(
	@p_application_no	   nvarchar(50)
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
	declare @msg	nvarchar(max);
	begin try

	declare  @branch_code					nvarchar(50)
	    	,@branch_name					nvarchar(250)
	    	,@request_currency_code			nvarchar(5)
	    	,@request_date					datetime
	    	,@request_amount				decimal(18, 2)
	    	,@request_remarks				nvarchar(4000)
			,@fee_code						nvarchar(50)
			,@fee_name						nvarchar(250)
			,@client_name					nvarchar(250) 
			,@cashier_received_request_code nvarchar(50)
			,@agreement_no					nvarchar(50)
			,@facility_code					nvarchar(50)
			,@facility_name					nvarchar(250)
			,@gl_link_code					nvarchar(50) 
			,@application_external_no		nvarchar(50); 
	
	set @request_date = dbo.xfn_get_system_date();

	select	 @branch_code				= am.branch_code
			,@branch_name				= am.branch_name
			,@request_currency_code		= am.currency_code
			,@client_name				= cm.client_name
			,@agreement_no				= am.agreement_no
			,@facility_code				= am.facility_code			
			,@facility_name				= mf.description	
			,@application_external_no	= am.application_external_no		
	from	dbo.application_main am 
			inner join dbo.client_main cm on (cm.code  = am.client_code)
			left join dbo.master_facility mf on (mf.code = am.facility_code)
	where	am.application_no = @p_application_no ;

	declare interfacecashierreceivedrequest cursor fast_forward read_only 
	for select	 pf.fee_code
				,mf.description
				,sum(pf.fee_amount)
				,pf.currency_code
				,am.agreement_no
				,mf.gl_link_code
		from	application_fee pf 
				inner join dbo.master_fee mf on (mf.code	  = pf.fee_code)
				inner join application_main am on (am.application_no = pf.application_no)
		where	pf.application_no = @p_application_no
		group by pf.fee_code, mf.description, pf.currency_code, am.agreement_no, mf.gl_link_code
		having sum(pf.fee_amount) > 0
	
	open interfacecashierreceivedrequest
	
	fetch next from interfacecashierreceivedrequest 
	into  @fee_code
		 ,@fee_name
		 ,@request_amount
		 ,@request_currency_code
		 ,@agreement_no
		 ,@gl_link_code
	
	while @@fetch_status = 0
	begin	    
		if exists
		(
			select	1
			from	dbo.opl_interface_cashier_received_request
			where	doc_reff_code		  = @p_application_no
					and doc_reff_name	  = 'Application FEE'
					and request_status in
		(
			'HOLD', 'PAID'
		)
					and doc_reff_fee_code = @fee_code
		)
		begin
			set @msg = 'Fee ' + @fee_name + ' already exist' ;

			raiserror(@msg, 16, 1) ;
		end ;

		set @request_remarks = 'Application Fee ' + @fee_name + ' For ' + @application_external_no + ' - ' + @client_name
	    exec dbo.xsp_opl_interface_cashier_received_request_insert @p_code						= @cashier_received_request_code output
	    														   ,@p_branch_code			  	= @branch_code
	    														   ,@p_branch_name			  	= @branch_name
	    														   ,@p_request_status		  	= N'HOLD'
	    														   ,@p_request_currency_code 	= @request_currency_code
	    														   ,@p_request_date		  		= @request_date
	    														   ,@p_request_amount		  	= @request_amount
	    														   ,@p_request_remarks		  	= @request_remarks
	    														   ,@p_agreement_no		  		= null 	
	    														   ,@p_pdc_code			  		= null		
	    														   ,@p_pdc_no				  	= null		
	    														   ,@p_doc_reff_code		  	= @p_application_no
																   ,@p_doc_reff_name		  	= 'APPLICATION FEE'
	    														   ,@p_doc_reff_fee_code	  	= @fee_code
	    														   ,@p_process_date		  		= null
	    														   ,@p_process_branch_code	  	= null
	    														   ,@p_process_branch_name	  	= null
																   ,@p_process_reff_no		  	= null
																   ,@p_process_reff_name	  	= null
																   ,@p_process_gl_link_code  	= null
																	--
	    														   ,@p_cre_date					= @p_cre_date	   
	    														   ,@p_cre_by					= @p_cre_by		   
	    														   ,@p_cre_ip_address			= @p_cre_ip_address 
	    														   ,@p_mod_date					= @p_mod_date	   
	    														   ,@p_mod_by					= @p_mod_by		   
	    														   ,@p_mod_ip_address			= @p_mod_ip_address 
	    
		set @request_amount = @request_amount * -1
			
		exec dbo.xsp_opl_interface_cashier_received_request_detail_insert @p_id								= 0
																		  ,@p_cashier_received_request_code = @cashier_received_request_code 
																		  ,@p_branch_code					= @branch_code
																		  ,@p_branch_name					= @branch_name
																		  ,@p_gl_link_code					= @gl_link_code
																		  ,@p_agreement_no					= @agreement_no				
																		  ,@p_facility_code					= @facility_code				
																		  ,@p_facility_name					= @facility_name				
																		  ,@p_purpose_loan_code				= null	
																		  ,@p_purpose_loan_name				= null	
																		  ,@p_purpose_loan_detail_code		= null
																		  ,@p_purpose_loan_detail_name		= null
																		  ,@p_orig_currency_code			= @request_currency_code
																		  ,@p_orig_amount					= @request_amount 
																		  ,@p_division_code					= null
																		  ,@p_division_name					= null
																		  ,@p_department_code				= null
																		  ,@p_department_name				= null
																		  ,@p_remarks						= @request_remarks
																		  ,@p_cre_date						= @p_cre_date	   
																		  ,@p_cre_by						= @p_cre_by		   
																		  ,@p_cre_ip_address				= @p_cre_ip_address 
																		  ,@p_mod_date						= @p_mod_date	   
																		  ,@p_mod_by						= @p_mod_by		   
																		  ,@p_mod_ip_address				= @p_mod_ip_address  
	
		fetch next from interfacecashierreceivedrequest 
		into  @fee_code
			 ,@fee_name
			 ,@request_amount
			 ,@request_currency_code
			 ,@agreement_no
			 ,@gl_link_code
	end
	
	close interfacecashierreceivedrequest
	deallocate interfacecashierreceivedrequest
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
end ; 



