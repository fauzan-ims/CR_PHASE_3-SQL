CREATE PROCEDURE dbo.xsp_claim_main_cancel
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
	declare @msg					nvarchar(max)
			,@received_status		nvarchar(50) = ''
			,@process_date			datetime
			,@claim_progress_code	nvarchar(20) 
			,@policy_code			nvarchar(50)
			,@claim_request_code	nvarchar(50)

	begin try
		SELECT @policy_code          = cm.policy_code
			   ,@claim_request_code  = cm.claim_request_code
		FROM   dbo.claim_main cm
		WHERE cm.CODE = @p_code
		--claim status = 'HOLD'
		if exists (select 1 from dbo.claim_main where code = @p_code and claim_status = 'HOLD' or claim_status = 'APPROVE')
		begin
			
			if exists (select 1 from dbo.claim_main  where code = @p_code and claim_status = 'HOLD')
			begin
				if @claim_request_code is null
				begin
					update	dbo.claim_main
					set		claim_status	= 'CANCEL'
							--
							,mod_date		= @p_mod_date		
							,mod_by			= @p_mod_by			
							,mod_ip_address	= @p_mod_ip_address
					where	code			= @p_code

					exec dbo.xsp_claim_progress_insert @p_id							= 0        
													   ,@p_claim_code				= @p_code                 
													   ,@p_claim_progress_code		= 'CANCEL'                 
													   ,@p_claim_progress_date		= @p_cre_date
													   ,@p_claim_progress_remarks	= 'CLAIM CANCEL'                 
													   ,@p_cre_date					= @p_cre_date		
													   ,@p_cre_by					= @p_cre_by			
													   ,@p_cre_ip_address			= @p_cre_ip_address
													   ,@p_mod_date					= @p_mod_date		
													   ,@p_mod_by					= @p_mod_by			
													   ,@p_mod_ip_address			= @p_mod_ip_address
			
					update dbo.insurance_policy_main
					set	   policy_process_status = null
					where  code = @policy_code
				end
				else 
				begin
					delete dbo.claim_main
					where  code = @p_code

					update dbo.claim_request
					set    request_status = 'HOLD'
						   ,claim_code    = null
					where claim_code = @p_code
				end
			end
			else if exists (select 1 from dbo.claim_main  where code = @p_code and claim_status = 'APPROVE')
			begin
				if @claim_request_code is null
				begin
					select	@received_status		= received_status
							,@process_date			= process_date
					from	dbo.efam_interface_received_request
					where	received_source_no			= @p_code

					if (@received_status = 'HOLD' ) --or @received_status = 'REVERSE')
					begin
						update	dbo.efam_interface_received_request
						set		received_status	= 'CANCEL'
								--
								,mod_date		= @p_mod_date		
								,mod_by			= @p_mod_by			
								,mod_ip_address	= @p_mod_ip_address
						where	received_source_no	= @p_code	
					
						update	dbo.claim_main
						set		claim_status	= 'CANCEL'
								--
								,mod_date		= @p_mod_date		
								,mod_by			= @p_mod_by			
								,mod_ip_address	= @p_mod_ip_address
						where	code			= @p_code
					end
					else if (@received_status= 'ON PROCESS')
					begin
						if (@process_date is null)
						begin
							update	dbo.efam_interface_received_request
							set		received_status	= 'CANCEL'
									--
									,mod_date		= @p_mod_date		
									,mod_by			= @p_mod_by			
									,mod_ip_address	= @p_mod_ip_address
							where	code			= @p_code

							update	dbo.claim_main
							set		claim_status	= 'CANCEL'
									--
									,mod_date		= @p_mod_date		
									,mod_by			= @p_mod_by			
									,mod_ip_address	= @p_mod_ip_address
							where	code			= @p_code
						end
						else if (@process_date is not null)
						begin
							 set @msg = 'Data already proceed by module Finance, Please reject from Finance' ;
							 raiserror(@msg, 16, -1) ;
						end
					end
					else if (@received_status = 'PAID')
					begin
						set @msg = 'Receive request already received, Please reverse transaction for cancel' ;
						raiserror(@msg, 16, -1) ;
					end
					else if (@received_status = 'CANCEL')
					begin
						update	dbo.claim_main
						set		claim_status	= 'CANCEL'
								--
								,mod_date		= @p_mod_date		
								,mod_by			= @p_mod_by			
								,mod_ip_address	= @p_mod_ip_address
						where	code			= @p_code
					end

					exec dbo.xsp_claim_progress_insert @p_id							= 0        
													   ,@p_claim_code				= @p_code                 
													   ,@p_claim_progress_code		= 'APPROVE'                 
													   ,@p_claim_progress_date		= @p_cre_date
													   ,@p_claim_progress_remarks	= 'CLAIM APPROVE'                 
													   ,@p_cre_date					= @p_cre_date		
													   ,@p_cre_by					= @p_cre_by			
													   ,@p_cre_ip_address			= @p_cre_ip_address
													   ,@p_mod_date					= @p_mod_date		
													   ,@p_mod_by					= @p_mod_by			
													   ,@p_mod_ip_address			= @p_mod_ip_address
			
					update dbo.insurance_policy_main
					set	   policy_process_status = null
					where  code = @policy_code
				end
				else
				begin
					delete dbo.claim_main
					where  code = @p_code

					update dbo.claim_request
					set    request_status = 'HOLD'
						   ,claim_code    = null
					where claim_code = @p_code
				end
			end	
		end
		else
		begin
		    raiserror('Data already proceed',16,1)
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

