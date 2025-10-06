CREATE PROCEDURE [dbo].[xsp_opl_interface_approval_request_approve]
(
	@p_code				nvarchar(50)
	,@p_approval_status nvarchar(10) = 'APPROVE'
	,@p_approval_code	nvarchar(50) = ''
	,@p_request_status  nvarchar(10) = 'APPROVE'
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg		nvarchar(max)
			,@reff_no	nvarchar(50)
			,@reff_name nvarchar(250) ;

	begin try
		select	@reff_no = reff_no
				,@reff_name = reff_name
		from	opl_interface_approval_request
		where	code = @p_code ;

		if (@reff_name = 'APPLICATION APPROVAL')
		begin
			exec dbo.xsp_application_main_approve @p_application_no		= @reff_no
												  ,@p_approval_reff		= 'Application'
												  ,@p_approval_remark	= N'Application Approved'
												  ,@p_mod_date			= @p_mod_date		
												  ,@p_mod_by			= @p_mod_by			
												  ,@p_mod_ip_address	= @p_mod_ip_address	
		end ;
		else if (@reff_name = 'EARLY TERMINATION APPROVAL')
		begin
			exec dbo.xsp_et_main_approve @p_code			 = @reff_no 
										 ,@p_approval_reff	 = N'ET'
										 ,@p_approval_remark = N'ET Approved' 
										 ,@p_mod_date		 = @p_mod_date		
										 ,@p_mod_by			 = @p_mod_by			
										 ,@p_mod_ip_address  = @p_mod_ip_address	
		end ;
		else if (@reff_name = 'WRITE OFF APPROVAL')
		begin
			exec dbo.xsp_write_off_main_approve @p_code				 = @reff_no 
											    ,@p_approval_reff	 = N'WO'
											    ,@p_approval_remark  = N'WO Approved' 
											    ,@p_mod_date		 = @p_mod_date		
											    ,@p_mod_by			 = @p_mod_by			
											    ,@p_mod_ip_address   = @p_mod_ip_address	
		end ;
		else if (@reff_name = 'WAIVE APPROVAL')
		begin 
			exec dbo.xsp_waived_obligation_approve @p_code					= @reff_no
												   ,@p_approval_reff		= N'WAIVE' 
												   ,@p_approval_remark		= N'Waive Approved'
												   ,@p_mod_date				= @p_mod_date		
												   ,@p_mod_by				= @p_mod_by			
												   ,@p_mod_ip_address		= @p_mod_ip_address
			
		end ; 
		else if (@reff_name = 'MATURITY CONTINUE APPROVAL')
		begin 
			exec dbo.xsp_maturity_approve @p_code				= @reff_no
										  ,@p_approval_reff		= N'MATURITY' 
										  ,@p_approval_remark	= N'MATURITY Approved'
										  ,@p_mod_date			= @p_mod_date		
										  ,@p_mod_by			= @p_mod_by			
										  ,@p_mod_ip_address	= @p_mod_ip_address
			
		end ;
		else if (@reff_name = 'WITHHOLDING SETTLEMENT AUDIT APPROVAL')
		begin 
			exec dbo.xsp_withholding_settlement_audit_approve @p_code				= @reff_no
															  ,@p_approval_reff		= N'WITHHOLDING SETTLEMENT AUDIT' 
															  ,@p_approval_remark	= N'WITHHOLDING SETTLEMENT AUDIT Approved'
															  ,@p_mod_date			= @p_mod_date		
															  ,@p_mod_by			= @p_mod_by			
															  ,@p_mod_ip_address	= @p_mod_ip_address
			
		end ;
		else if (@reff_name = 'CHANGE DUE DATE APPROVAL')
		begin 
			exec dbo.xsp_due_date_change_main_approve @p_code				= @reff_no
													  ,@p_approval_reff		= N'CHANGE DUE DATE'
													  ,@p_approval_remark	= N'CHANGE DUE DATE Approved'
													  ,@p_mod_date			= @p_mod_date		
													  ,@p_mod_by			= @p_mod_by			
													  ,@p_mod_ip_address	= @p_mod_ip_address
			
		end ;
		else if (@reff_name = 'STOP BILLING APPROVAL')
		begin
		    exec dbo.xsp_stop_billing_approve @p_code = @reff_no -- nvarchar(50)
		    								  ,@p_approval_reff = N'STOP BILLING' -- nvarchar(250)
		    								  ,@p_approval_remark = N'STOP BILLING Approved' -- nvarchar(4000)
		    								  ,@p_mod_date = @p_mod_date
		    								  ,@p_mod_by = @p_mod_by
		    								  ,@p_mod_ip_address = @p_mod_ip_address
		    
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




