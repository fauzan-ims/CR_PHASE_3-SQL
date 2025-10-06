CREATE PROCEDURE dbo.xsp_ams_interface_received_request_cancel 
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
			,@received_source		nvarchar(50)
			,@received_source_no	nvarchar(250)
			,@remark				nvarchar(4000);

	begin try

		select  @received_source		= received_source
				,@received_source_no	= received_source_no
				,@remark				= 'Received cancel, ' + process_reff_name
		from    dbo.efam_interface_received_request
        where	code = @p_code
	
		if (@received_source = 'REVERSE DP PUBLIC SERVICE')
		begin 
			update order_main
			set    order_status		 = 'HOLD'
				   --
				   ,mod_date		 = @p_mod_date		
				   ,mod_by			 = @p_mod_by			
				   ,mod_ip_address	 = @p_mod_ip_address	
			where  code = @received_source_no		
		end
		else if @received_source = 'REALIZATION FOR PUBLIC SERVICE'
		begin
			update register_main
			set    register_status = 'REALIZATION'
				   --
				   ,mod_date		 = @p_mod_date		
				   ,mod_by			 = @p_mod_by			
				   ,mod_ip_address	 = @p_mod_ip_address	
			where  code = @received_source_no	
		end
		else if @received_source = 'REGISTER'
		begin
			update register_main
			set    register_status = 'ON PROCESS'
				   --
				   ,mod_date		 = @p_mod_date		
				   ,mod_by			 = @p_mod_by			
				   ,mod_ip_address	 = @p_mod_ip_address	
			where  code = @received_source_no	
		end
		else if @received_source = 'CLAIM'
		begin
			update claim_main
			set claim_status	= 'ON PROCESS'
				--
				,mod_date       = @p_mod_date
				,mod_by         = @p_mod_by
				,mod_ip_address = @p_mod_ip_address
			where code = @received_source_no
		
			exec dbo.xsp_claim_progress_insert @p_id					  = 0
			                                   ,@p_claim_code			  = @received_source_no
			                                   ,@p_claim_progress_code    = 'CANCEL'
			                                   ,@p_claim_progress_date    = @p_cre_date
			                                   ,@p_claim_progress_remarks = @remark
			                                   ,@p_cre_date				  = @p_cre_date		
			                                   ,@p_cre_by				  = @p_cre_by			
			                                   ,@p_cre_ip_address		  = @p_cre_ip_address	
			                                   ,@p_mod_date				  = @p_mod_date		
			                                   ,@p_mod_by				  = @p_mod_by			
			                                   ,@p_mod_ip_address		  = @p_mod_ip_address	
		end
		else if (@received_source = 'TERMINATE')
		begin
			update dbo.termination_main
			set    termination_status = 'ON PROCESS'
					--
					,mod_date		  = @p_mod_date		
					,mod_by			  = @p_mod_by			
					,mod_ip_address	  = @p_mod_ip_address	
			where  code				  = @received_source_no
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

