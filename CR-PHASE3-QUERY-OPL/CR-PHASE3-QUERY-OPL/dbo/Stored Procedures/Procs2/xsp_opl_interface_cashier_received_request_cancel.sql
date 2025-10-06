-- Louis Selasa, 13 Desember 2022 18.16.46 -- 
CREATE PROCEDURE [dbo].[xsp_opl_interface_cashier_received_request_cancel]
(
	@p_code					 nvarchar(50)
	,@p_process_date		 datetime	    = null
	,@p_process_reff_no		 nvarchar(50)   = 'default'
	,@p_process_reff_name	 nvarchar(250)  = 'default'
	,@p_doc_reff_code		 nvarchar(50)
	--
	,@p_mod_date			 datetime
	,@p_mod_by				 nvarchar(15)
	,@p_mod_ip_address		 nvarchar(15)
	,@p_request_status		nvarchar(50) = ''
)
as
begin
	declare @msg				nvarchar(max)
			,@plafond_id		bigint
			,@agreement_no	   nvarchar(50)
			,@process_date	   datetime
			,@doc_reff_code		nvarchar(50)
			,@doc_reff_name		nvarchar(250)
			,@doc_reff_fee_code nvarchar(50) ;

	begin try
		set @p_process_date = dbo.xfn_get_system_date();

		select	@doc_reff_code		= doc_reff_code
				,@doc_reff_name		= doc_reff_name
				,@doc_reff_fee_code = doc_reff_fee_code
				,@agreement_no		= agreement_no
				,@process_date		= process_date
		from	opl_interface_cashier_received_request
		where	code				= @p_code ;
		 
		if (@doc_reff_name = 'WO RECOVERY')
		begin
			update dbo.write_off_recovery
			set		recovery_status			= 'HOLD'
					--
					,mod_by					= @p_mod_by
					,mod_date				= @p_mod_date
					,mod_ip_address			= @p_mod_ip_address
			where   code					= @p_code
					
		end
	
		if(@p_request_status = 'REVERSAL')
		begin
			update	dbo.opl_interface_cashier_received_request
			set		process_date		= @p_process_date
					,process_reff_no	= @p_process_reff_no
					,process_reff_name	= @p_process_reff_name
					,request_status		= 'HOLD'
					--
					,mod_date			= @p_mod_date		
					,mod_by				= @p_mod_by		
					,mod_ip_address		= @p_mod_ip_address
			where	code				= @p_code ;

			exec dbo.xsp_invoice_reversal @p_invoice_no		 = @doc_reff_code
										  ,@p_payment_date	 = @process_date
										  ,@p_mod_date		 = @p_mod_date
										  ,@p_mod_by		 = @p_mod_by
										  ,@p_mod_ip_address = @p_mod_ip_address
		end			
		else
		begin
			update	dbo.opl_interface_cashier_received_request
			set		process_date		= @p_process_date
					,process_reff_no	= @p_process_reff_no
					,process_reff_name	= @p_process_reff_name
					,request_status		= 'CANCEL'
					--
					,mod_date			= @p_mod_date		
					,mod_by				= @p_mod_by		
					,mod_ip_address		= @p_mod_ip_address
			where	code				= @p_code ;
			
			if exists
			(
				select	1
				from	dbo.credit_note
				where	code = @doc_reff_code
			)
			begin
				select	@doc_reff_code = invoice_no
				from	dbo.credit_note
				where	code = @doc_reff_code ;
			end ;
        
			exec dbo.xsp_invoice_cancel_paid @p_invoice_no		= @doc_reff_code
											 ,@p_mod_date		= @p_mod_date
											 ,@p_mod_by			= @p_mod_by
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




