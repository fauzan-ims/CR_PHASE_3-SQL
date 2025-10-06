CREATE PROCEDURE dbo.xsp_termination_main_cancel 
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
	declare @msg						nvarchar(max)
			,@receipt_status			nvarchar(10)
			,@process_date				datetime
			,@termination_request_code  nvarchar(50)
			,@policy_code				nvarchar(50);
			
	begin try		
		select @termination_request_code = termination_request_code
		       ,@policy_code			 = policy_code
		from   dbo.termination_main
		where  code = @p_code

		select	@receipt_status		= received_status
				,@process_date		= process_date	
		from	dbo.efam_interface_received_request
		where	received_source_no	= @p_code

		if exists (select 1 from dbo.termination_main where code = @p_code and termination_status = 'HOLD' or termination_status = 'ON PROCESS')
		begin
			if @termination_request_code is null
			begin
				update	dbo.termination_main 
				set		termination_status	= 'CANCEL'
						--
						,mod_date			= @p_mod_date		
						,mod_by				= @p_mod_by			
						,mod_ip_address		= @p_mod_ip_address
				where	code				= @p_code
			end
			else
			begin
				delete dbo.termination_main
				where code = @p_code

				update dbo.termination_request
				set    request_status = 'HOLD'
				where  termination_code = @p_code
			end
		end
		else if exists (select 1 from dbo.termination_main where code = @p_code and termination_status = 'APPROVE')
		begin
			if @termination_request_code is null
			begin
				if @receipt_status = 'HOLD'
				begin
					update	dbo.efam_interface_received_request 
					set		received_status	= 'CANCEL'
							--
							,mod_date		= @p_mod_date		
							,mod_by			= @p_mod_by			
							,mod_ip_address	= @p_mod_ip_address
					where	received_source_no	= @p_code	
					
					update	dbo.termination_main --tambahan
						set		termination_status	= 'CANCEL'
								--
								,mod_date			= @p_mod_date		
								,mod_by				= @p_mod_by			
								,mod_ip_address		= @p_mod_ip_address
						where	code				= @p_code
								    
				end
				else if @receipt_status = 'ON PROCESS'
				begin
					if isnull(@process_date,'') = NULL
					begin 
						update	dbo.efam_interface_received_request 
						set		received_status	= 'CANCEL'
								--
								,mod_date		= @p_mod_date		
								,mod_by			= @p_mod_by			
								,mod_ip_address	= @p_mod_ip_address
						where	received_source_no	= @p_code

						update	dbo.termination_main 
						set		termination_status	= 'CANCEL' --'IN MODULE FINANCE'
								--
								,mod_date			= @p_mod_date		
								,mod_by				= @p_mod_by			
								,mod_ip_address		= @p_mod_ip_address
						where	code				= @p_code		
					end
					else
					begin
						set @msg = 'Data already proceed by module finance. Please reject transaction';
						raiserror(@msg, 16, -1) ;
					end		    
				end
				else if @receipt_status = 'PAID'
				begin	
					set @msg = 'Receive request already received, Please reverse transaction for cancel';
					raiserror(@msg, 16, -1) ;  
				end			
				else if @receipt_status = 'CANCEL'
				begin					
					update	dbo.termination_main 
					set		termination_status	= 'CANCEL'
							--
							,mod_date			= @p_mod_date		
							,mod_by				= @p_mod_by			
							,mod_ip_address		= @p_mod_ip_address
					where	code				= @p_code  
				end
			end
			else
			begin
				delete dbo.termination_main
				where code = @p_code

				update dbo.termination_request
				set    request_status = 'HOLD'
				where  termination_code = @p_code
			end
		end
        else
		begin
			set @msg = 'Error data already proceed';
			raiserror(@msg, 16, -1) ;
		end	
		
		--update policy_process_status pada policy
		update dbo.insurance_policy_main
		set	   policy_process_status = null
		where  code = @policy_code
					
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

