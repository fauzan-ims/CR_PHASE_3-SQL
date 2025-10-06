CREATE PROCEDURE dbo.xsp_ams_interface_payment_request_cancel 
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
	declare @msg					nvarchar(max)
			,@payment_source		nvarchar(50)
			,@payment_source_no		nvarchar(250)
			,@remark				nvarchar(4000);

	begin try

		select  @payment_source			= payment_source
				,@payment_source_no		= payment_source_no
				,@remark				= 'Payment cancel, ' + process_reff_name
		from    dbo.efam_interface_payment_request
        where	code = @p_code
	
		if (@payment_source = 'DP ORDER PUBLIC SERVICE')
		begin 
			update order_main
			set    order_status = 'HOLD'
				   --
				   ,mod_date		 = @p_mod_date		
				   ,mod_by			 = @p_mod_by			
				   ,mod_ip_address	 = @p_mod_ip_address	
			where  code = @payment_source_no		
		end
		else if (@payment_source = 'REALIZATION FOR PUBLIC SERVICE')
		begin
			update register_main
			set    register_status = 'REALIZATION'
				   --
				   ,mod_date		 = @p_mod_date		
				   ,mod_by			 = @p_mod_by			
				   ,mod_ip_address	 = @p_mod_ip_address	
			where  code = @payment_source_no	
		end
		else if (@payment_source = 'POLICY')
		begin 
			update insurance_policy_main
			set    policy_payment_status = 'HOLD'
				   --
				   ,mod_date			 = @p_mod_date		
				   ,mod_by				 = @p_mod_by			
				   ,mod_ip_address		 = @p_mod_ip_address	
			where  code					 = @payment_source_no
	
			exec dbo.xsp_insurance_policy_main_history_insert @p_id						= 0
			                                                  ,@p_policy_code			= @payment_source_no
			                                                  ,@p_history_date			= @p_cre_date
			                                                  ,@p_history_type			= 'CANCEL'
			                                                  ,@p_policy_status			= 'POLICY'
			                                                  ,@p_history_remarks		= @remark
			                                                  ,@p_cre_date				= @p_cre_date		
															  ,@p_cre_by				= @p_cre_by			
															  ,@p_cre_ip_address		= @p_cre_ip_address	
															  ,@p_mod_date				= @p_mod_date		
															  ,@p_mod_by				= @p_mod_by			
															  ,@p_mod_ip_address		= @p_mod_ip_address
		end
		else if (@payment_source = 'ENDORSE')
		begin
			update endorsement_main
			set    endorsement_status = 'HOLD'
				   --
				   ,mod_date		 = @p_mod_date		
				   ,mod_by			 = @p_mod_by			
				   ,mod_ip_address	 = @p_mod_ip_address	
			where  code				 = @payment_source_no
			                                     								
		end	
		else if (@payment_source = 'RENEWAL')
		begin
			update insurance_payment_schedule_renewal
			set    payment_renual_status = 'HOLD'
				   --
				   ,mod_date		 = @p_mod_date		
				   ,mod_by			 = @p_mod_by			
				   ,mod_ip_address	 = @p_mod_ip_address	
			where  code = @payment_source_no
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
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
