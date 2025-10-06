CREATE PROCEDURE dbo.xsp_endorsement_main_cancel 
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
	declare @msg					   nvarchar(max)
			,@payment_status		   nvarchar(10)
			,@process_date			   datetime
			,@endorsement_request_code nvarchar(50)
			,@policy_code			   nvarchar(50);
			
	begin try
		select @endorsement_request_code = endorsement_request_code 
			   ,@policy_code			 = policy_code
		from dbo.endorsement_main
		where code = @p_code

		select	@payment_status		= payment_status	
				,@process_date		= process_date	
		from	efam_interface_payment_request
		where	payment_source_no	= @p_code	

		if exists (select 1 from dbo.endorsement_main where code = @p_code and endorsement_status = 'HOLD')
		begin
			if @endorsement_request_code is null
			begin
				update	dbo.endorsement_main 
				set		endorsement_status	= 'CANCEL'
						--
						,mod_date			= @p_mod_date		
						,mod_by				= @p_mod_by			
						,mod_ip_address		= @p_mod_ip_address
				where	code				= @p_code
			end
			else
			begin
				delete dbo.endorsement_main
				where CODE = @p_code

				update dbo.endorsement_request
				set    endorsement_request_status = 'HOLD'
				where endorsement_code = @p_code
			end
		end
		else if exists (select 1 from dbo.endorsement_main where code = @p_code and endorsement_status = 'APPROVE')
		begin
			if @endorsement_request_code is null
			begin
		
				if @payment_status in ('HOLD','REVERSE')
				begin
					update	dbo.efam_interface_payment_request 
					set		payment_status	= 'CANCEL'
							--
							,mod_date		= @p_mod_date		
							,mod_by			= @p_mod_by			
							,mod_ip_address	= @p_mod_ip_address
					where	code			= @p_code	
				
					update	dbo.endorsement_main 
					set		endorsement_status	= 'CANCEL'
							--
							,mod_date			= @p_mod_date		
							,mod_by				= @p_mod_by			
							,mod_ip_address		= @p_mod_ip_address
					where	code				= @p_code		    
				end
				else if @payment_status = 'ON PROCESS'
				begin
					if isnull(@process_date,'') = ''
					begin
						update	dbo.efam_interface_payment_request 
						set		payment_status	= 'CANCEL'
								--
								,mod_date		= @p_mod_date		
								,mod_by			= @p_mod_by			
								,mod_ip_address	= @p_mod_ip_address
						where	code			= @p_code	
				
						update	dbo.endorsement_main 
						set		endorsement_status	= 'CANCEL'
								--
								,mod_date			= @p_mod_date		
								,mod_by				= @p_mod_by			
								,mod_ip_address		= @p_mod_ip_address
						where	code				= @p_code
					end
					else	
					begin
						set @msg = 'Data already proceed by module finance. Please reject from finance transaction';
						raiserror(@msg, 16, -1) ;
					end				    
				end
				else if @payment_status = 'PAID'
				begin	
					set @msg = 'Receive request already received, Please reverse transaction for cancel';
					raiserror(@msg, 16, -1) ;
				end			
				else --if @payment_status = 'CANCEL'
				begin	
					update	dbo.endorsement_main 
					set		endorsement_status	= 'CANCEL'
							--
							,mod_date			= @p_mod_date		
							,mod_by				= @p_mod_by			
							,mod_ip_address		= @p_mod_ip_address
					where	code				= @p_code 
				end
			end
			else
			begin
			    delete dbo.endorsement_main
				where CODE = @p_code

				update dbo.endorsement_request
				set    endorsement_request_status = 'HOLD'
				where endorsement_code = @p_code
			end
		end
        else
		begin
			set @msg = 'Error data already proceed';
			raiserror(@msg, 16, -1) ;
		end		

		--update policy
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

