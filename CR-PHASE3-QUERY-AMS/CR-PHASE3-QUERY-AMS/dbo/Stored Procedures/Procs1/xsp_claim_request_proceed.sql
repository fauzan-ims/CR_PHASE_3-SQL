/*
	alterd : Nia, 29 Mei 2020
*/
CREATE PROCEDURE dbo.xsp_claim_request_proceed
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
	declare @msg						nvarchar(max)
			,@branch_code				nvarchar(50)
			,@branch_name				nvarchar(50)
			,@policy_code				nvarchar(50)
			,@request_date              datetime
			,@claim_main_code			nvarchar(50);

	select  @branch_code		  = cr.branch_code
			,@branch_name		  = cr.branch_name
			,@policy_code		  = cr.policy_code
			,@request_date		  = request_date
	from	dbo.claim_request cr		 
	where	cr.code				  = @p_code

	begin try

		if exists (select 1 from dbo.claim_request where code = @p_code and request_status = 'HOLD')
		begin
			
			exec dbo.xsp_claim_main_insert @p_code						= @claim_main_code OUTPUT  
			                               ,@p_branch_code				= @branch_code                    
			                               ,@p_branch_name				= @branch_name                    
			                               ,@p_policy_code				= @policy_code    
			                               ,@p_claim_amount				= 0                   
			                               ,@p_claim_remarks			= 'CLAIM'                    
			                               ,@p_claim_reff_external_no	= ''     
			                               ,@p_claim_loss_type			= ''                    
			                               ,@p_claim_request_code		= @p_code                    
			                               ,@p_loss_date				= @request_date
			                               ,@p_customer_report_date		= @request_date 
			                               ,@p_finance_report_date		= NULL  
			                               ,@p_result_report_date		= NULL  
			                               ,@p_received_request_code	= null                    
			                               ,@p_received_voucher_no		= null                    
			                               ,@p_received_voucher_date	= null  
			                               ,@p_is_policy_terminate		= N'0'          
			                               ,@p_is_ex_gratia				= N'0'                       
			                               ,@p_cre_date					= @p_cre_date		
			                               ,@p_cre_by					= @p_cre_by			
			                               ,@p_cre_ip_address			= @p_cre_ip_address
			                               ,@p_mod_date					= @p_mod_date		
			                               ,@p_mod_by					= @p_mod_by			
			                               ,@p_mod_ip_address			= @p_mod_ip_address;                                 
			                      
			set @request_date = dbo.xfn_get_system_date()
			exec dbo.xsp_claim_progress_insert @p_id						= 0,
			                                   @p_claim_code				= @claim_main_code,  
			                                   @p_claim_progress_code		= N'ENTRY',         
			                                   @p_claim_progress_date		= @request_date, 
			                                   @p_claim_progress_remarks	= N'CLAIM REGISTER',
			                                   @p_cre_date					= @p_cre_date,		
			                                   @p_cre_by					= @p_cre_by,			
			                                   @p_cre_ip_address			= @p_cre_ip_address,
			                                   @p_mod_date					= @p_mod_date,		
			                                   @p_mod_by					= @p_mod_by,		
			                                   @p_mod_ip_address			= @p_mod_ip_address

			update	dbo.claim_request
			set		request_status = 'POST'
					,claim_code	= @claim_main_code
					--
					,mod_date		= @p_mod_date		
					,mod_by			= @p_mod_by			
					,mod_ip_address	= @p_mod_ip_address
			where	code			= @p_code;

		end
		else
		begin
		    set @msg = 'Data already proceed';
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


