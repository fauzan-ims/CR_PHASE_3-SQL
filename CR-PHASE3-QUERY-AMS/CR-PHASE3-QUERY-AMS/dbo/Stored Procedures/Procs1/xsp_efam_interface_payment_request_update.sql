CREATE PROCEDURE dbo.xsp_efam_interface_payment_request_update
(
	@p_id					  bigint
	,@p_code				  nvarchar(50)
	,@p_company_code		  nvarchar(50)
	,@p_branch_code			  nvarchar(50)
	,@p_branch_name			  nvarchar(250)
	,@p_payment_branch_code	  nvarchar(50)
	,@p_payment_branch_name	  nvarchar(250)
	,@p_payment_source		  nvarchar(50)
	,@p_payment_request_date  datetime
	,@p_payment_source_no	  nvarchar(50)
	,@p_payment_status		  nvarchar(10)
	,@p_payment_currency_code nvarchar(3)
	,@p_payment_amount		  decimal(18, 2)
	,@p_payment_remarks		  nvarchar(4000)
	,@p_to_bank_account_name  nvarchar(250)
	,@p_to_bank_name		  nvarchar(250)
	,@p_to_bank_account_no	  nvarchar(50)
	,@p_tax_type			  nvarchar(10)
	,@p_tax_file_no			  nvarchar(50)
	,@p_tax_payer_reff_code	  nvarchar(50)
	,@p_tax_file_name		  nvarchar(50)
	,@p_process_date		  datetime
	,@p_process_reff_no		  nvarchar(50)
	,@p_process_reff_name	  nvarchar(250)
	,@p_settle_date			  datetime
	,@p_job_status			  nvarchar(10)
	,@p_failed_remarks		  nvarchar(4000)
	--
	,@p_mod_date			  datetime
	,@p_mod_by				  nvarchar(15)
	,@p_mod_ip_address		  nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	efam_interface_payment_request
		set		code					= @p_code
				,company_code			= @p_company_code
				,branch_code			= @p_branch_code
				,branch_name			= @p_branch_name
				,payment_branch_code	= @p_payment_branch_code
				,payment_branch_name	= @p_payment_branch_name
				,payment_source			= @p_payment_source
				,payment_request_date	= @p_payment_request_date
				,payment_source_no		= @p_payment_source_no
				,payment_status			= @p_payment_status
				,payment_currency_code	= @p_payment_currency_code
				,payment_amount			= @p_payment_amount
				,payment_remarks		= @p_payment_remarks
				,to_bank_account_name	= @p_to_bank_account_name
				,to_bank_name			= @p_to_bank_name
				,to_bank_account_no		= @p_to_bank_account_no
				,tax_type				= @p_tax_type
				,tax_file_no			= @p_tax_file_no
				,tax_payer_reff_code	= @p_tax_payer_reff_code
				,tax_file_name			= @p_tax_file_name
				,process_date			= @p_process_date
				,process_reff_no		= @p_process_reff_no
				,process_reff_name		= @p_process_reff_name
				,settle_date			= @p_settle_date
				,job_status				= @p_job_status
				,failed_remarks			= @p_failed_remarks
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	id						= @p_id ;
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
