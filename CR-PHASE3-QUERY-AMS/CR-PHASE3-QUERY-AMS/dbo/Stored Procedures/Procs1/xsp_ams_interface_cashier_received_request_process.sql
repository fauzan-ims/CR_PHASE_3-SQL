CREATE PROCEDURE dbo.xsp_ams_interface_cashier_received_request_process
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
			,@regis_main_code		nvarchar(50)
			,@trx_date				datetime = dbo.xfn_get_system_date()
			,@voucher				nvarchar(50)
			,@reff_no				nvarchar(50)
			,@reff_name				nvarchar(250)

	begin try
		
		select	@regis_main_code = doc_ref_code
				,@voucher		 = 'VCHR_' + right(@p_code,6)
				,@reff_no		 = 'REFF_NO_' + right(@p_code,6)
				,@reff_name		 = doc_ref_name
		from	dbo.ams_interface_cashier_received_request
		where	code = @p_code
				
		exec dbo.ams_interface_cashier_received_request_paid @p_code				= @p_code
															 ,@p_process_date		= @trx_date
															 ,@p_process_reff_no	= @reff_no
															 ,@p_process_reff_name	= @reff_name
															 ,@p_cre_date			= @p_cre_date		
															 ,@p_cre_by				= @p_cre_by			
															 ,@p_cre_ip_address		= @p_cre_ip_address	
															 ,@p_mod_date			= @p_mod_date		
															 ,@p_mod_by				= @p_mod_by			
															 ,@p_mod_ip_address		= @p_mod_ip_address	
		
		if @reff_name = 'DP PUBLIC SERVICE'
		begin
			exec dbo.xsp_register_main_paid @p_code							= @regis_main_code
											,@p_dp_from_customer_date		= @trx_date
											,@p_dp_from_customer_voucher	= @voucher
											,@p_cre_date					= @p_cre_date		
											,@p_cre_by						= @p_cre_by			
											,@p_cre_ip_address				= @p_cre_ip_address	
											,@p_mod_date					= @p_mod_date		
											,@p_mod_by						= @p_mod_by			
											,@p_mod_ip_address				= @p_mod_ip_address	
		end
		else
		begin
			exec dbo.xsp_register_main_realization_customer_paid @p_code							= @regis_main_code
																 ,@p_customer_settlement_date		= @trx_date
																 ,@p_customer_settlement_voucher	= @voucher
																 ,@p_cre_date						= @p_cre_date		
																 ,@p_cre_by							= @p_cre_by			
																 ,@p_cre_ip_address					= @p_cre_ip_address	
																 ,@p_mod_date						= @p_mod_date		
																 ,@p_mod_by							= @p_mod_by			
																 ,@p_mod_ip_address					= @p_mod_ip_address	
		end		
		
		update dbo.ams_interface_cashier_received_request
			set    settle_date = @p_mod_date
				   ,job_status  = 'POST'
				   ,failed_remarks = null
			where  code = @p_code

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

end

