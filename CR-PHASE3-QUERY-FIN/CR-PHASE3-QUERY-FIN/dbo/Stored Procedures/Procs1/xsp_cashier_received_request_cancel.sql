/*
	Created : Nia, 28 Sep 2020
*/
CREATE PROCEDURE dbo.xsp_cashier_received_request_cancel 
(
	@p_code				 nvarchar(50)
	,@p_request_remarks  nvarchar(4000)
	--
	,@p_cre_date		 datetime
	,@p_cre_by			 nvarchar(15)
	,@p_cre_ip_address	 nvarchar(15)
	,@p_mod_date		 datetime
	,@p_mod_by			 nvarchar(15)
	,@p_mod_ip_address	 nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max)
			,@doc_ref_code	nvarchar(50)
			,@doc_ref_name	nvarchar(250);

	begin try
	
	select @doc_ref_code  = doc_ref_code
	       ,@doc_ref_name = doc_ref_name
	from cashier_received_request
	where code = @p_code

	if @doc_ref_name in ('INSURANCE ENDORSEMENT','INSURANCE REGISTER', 'INSURANCE RENEWAL','SETTLEMENT NOTARY','LEGAL REQUEST',
						'REALIZATION PUBLIC SERVICE CUSTOMER','DP PUBLIC SERVICE',
						'DUE DATE','EARLY TERMINATION','WO RECOVERY', 'INVOICE SEND')
	begin
		if exists (select 1 from dbo.cashier_received_request where code = @p_code and request_status = 'HOLD')
		begin
			--double transaction
			if @doc_ref_name in ('SETTLEMENT NOTARY','REALIZATION PUBLIC SERVICE CUSTOMER')
			begin
				if exists (select 1 from received_request where code = @doc_ref_code and received_status <> 'HOLD')
				begin
					set @msg = 'This data already process';
					raiserror(@msg, 16, -1) ;
				end
				else
				begin
					--cancel rr
					update	dbo.received_request 
					set		received_status		= 'CANCEL'
							,received_remarks	= received_remarks + @p_request_remarks
							--
							,mod_date		    = @p_mod_date		
							,mod_by			    = @p_mod_by			
							,mod_ip_address	    = @p_mod_ip_address
					where	received_source_no	= @doc_ref_code

					update	dbo.fin_interface_received_request
					set		received_status	   = 'CANCEL'
							,process_reff_name = @p_request_remarks
							,process_reff_no   = 'CANCEL'
							--
							,mod_date		= @p_mod_date		
							,mod_by			= @p_mod_by			
							,mod_ip_address	= @p_mod_ip_address
					where	received_source_no	= @doc_ref_code
				end				

				if exists(select 1 from payment_request where code = @doc_ref_code and payment_status <> 'HOLD')
				begin
					set @msg = 'This data already process';
					raiserror(@msg, 16, -1) ;
				end
				else
				begin
					--cancel pr
					update	dbo.payment_request 
					set		payment_status		= 'CANCEL'
							,payment_remarks	= payment_remarks + @p_request_remarks
							--
							,mod_date		    = @p_mod_date		
							,mod_by			    = @p_mod_by			
							,mod_ip_address	    = @p_mod_ip_address
					where	payment_source_no	= @doc_ref_code

					update	dbo.fin_interface_payment_request
					set		payment_status	   = 'CANCEL'
							,process_reff_name = @p_request_remarks
							,process_reff_no   = 'CANCEL'
							--
							,mod_date		    = @p_mod_date		
							,mod_by			    = @p_mod_by			
							,mod_ip_address	    = @p_mod_ip_address
					where	payment_source_no	= @doc_ref_code
				end				
			end

		    update	dbo.cashier_received_request 
			set		request_status	= 'CANCEL'
					,request_remarks = request_remarks + @p_request_remarks
					--
					,mod_date		= @p_mod_date		
					,mod_by			= @p_mod_by			
					,mod_ip_address	= @p_mod_ip_address
			where	code			= @p_code

			update	dbo.fin_interface_cashier_received_request
			set		request_status	   = 'CANCEL'
					,process_reff_name = @p_request_remarks
					,process_reff_no   = 'CANCEL'
					--
					,mod_date		= @p_mod_date		
					,mod_by			= @p_mod_by			
					,mod_ip_address	= @p_mod_ip_address
			where	code			= @p_code
		end
        else
		begin
		    set @msg = 'Error data already proceed';
			raiserror(@msg, 16, -1) ;
		end	
	end
	else
	begin
		set @msg = 'This transaction cant be cancel ';
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
