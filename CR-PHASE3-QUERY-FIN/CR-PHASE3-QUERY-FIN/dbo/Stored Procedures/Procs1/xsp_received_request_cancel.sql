/*
	Created : Nia, 28 Sep 2020
*/
CREATE PROCEDURE dbo.xsp_received_request_cancel 
(
	@p_code				 nvarchar(50)
	,@p_received_remarks nvarchar(4000)
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
	declare @msg			        nvarchar(max)
			,@received_source       nvarchar(50)
			,@received_source_no	nvarchar(50);
	
	begin try
	select @received_source		= received_source
		   ,@received_source_no = received_source_no
	from   dbo.received_request
	where code = @p_code

	if @received_source in ('CLAIM','TERMINATE','SETTLEMENT','REALIZATION FOR PUBLIC SERVICE','REVERSE DP PUBLIC SERVICE','REGISTER','OPEX ADJUSTMENT','SOLD SETTLEMENT')
		OR (LEFT(@received_source,27) = 'BATCH DISBURSEMENT RECEIVED')
		OR (LEFT(@received_source,26) = 'BATCH RESTRUCTURE APPROVED')
	begin
		if exists (select 1 from dbo.received_request where code = @p_code and received_status = 'HOLD')
		begin
			--double transaction
			if @received_source in ('SETTLEMENT','REALIZATION FOR PUBLIC SERVICE','OPEX ADJUSTMENT')
			begin
				if exists (select 1 from cashier_received_request where code = @received_source_no and request_status <> 'HOLD')
				begin
					set @msg = 'This data already process';
					raiserror(@msg, 16, -1) ;
				end
				else
				begin
					--cancel crr
					update	dbo.cashier_received_request 
					set		request_status	= 'CANCEL'
							,request_remarks = request_remarks + @p_received_remarks
							--
							,mod_date		= @p_mod_date		
							,mod_by			= @p_mod_by			
							,mod_ip_address	= @p_mod_ip_address
					where	doc_ref_code	= @received_source_no

					update	dbo.fin_interface_cashier_received_request
					set		request_status	   = 'CANCEL'
							,process_reff_name = @p_received_remarks
							,process_reff_no   = 'CANCEL'
							--
							,mod_date		= @p_mod_date		
							,mod_by			= @p_mod_by			
							,mod_ip_address	= @p_mod_ip_address
					where	doc_ref_code	= @received_source_no
				end				

				if exists (select 1 from payment_request where code = @received_source_no and payment_status <> 'HOLD')
				begin
					set @msg = 'This data already process';
					raiserror(@msg, 16, -1) ;
				end
				else
				begin
					--cancel pr
					update	dbo.payment_request 
					set		payment_status		= 'CANCEL'
							,payment_remarks	= payment_remarks + @p_received_remarks
							--
							,mod_date		    = @p_mod_date		
							,mod_by			    = @p_mod_by			
							,mod_ip_address	    = @p_mod_ip_address
					where	payment_source_no	= @received_source_no

					update	dbo.fin_interface_payment_request
					set		payment_status	   = 'CANCEL'
							,process_reff_name = @p_received_remarks
							,process_reff_no   = 'CANCEL'
							--
							,mod_date		    = @p_mod_date		
							,mod_by			    = @p_mod_by			
							,mod_ip_address	    = @p_mod_ip_address
					where	payment_source_no	= @received_source_no
				end
				
			end

		    update	dbo.received_request 
			set		received_status	= 'CANCEL'
					,received_remarks = received_remarks + @p_received_remarks
					--
					,mod_date		= @p_mod_date		
					,mod_by			= @p_mod_by			
					,mod_ip_address	= @p_mod_ip_address
			where	code			= @p_code

			update	dbo.fin_interface_received_request
			set		received_status	   = 'CANCEL'
					,process_reff_name = @p_received_remarks
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
