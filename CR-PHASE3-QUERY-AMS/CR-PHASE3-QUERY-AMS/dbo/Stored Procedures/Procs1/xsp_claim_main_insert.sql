CREATE PROCEDURE dbo.xsp_claim_main_insert
(
	@p_code					   nvarchar(50) output
	,@p_branch_code			   nvarchar(50)
	,@p_branch_name			   nvarchar(250)
	,@p_policy_code			   nvarchar(50)
	--,@p_claim_status		   nvarchar(10)
	--,@p_claim_progress_status  nvarchar(10) = 'ENTRY'
	,@p_claim_amount		   decimal(18, 2) = 0
	,@p_claim_remarks		   nvarchar(4000)
	,@p_claim_reff_external_no nvarchar(50) = ''
	,@p_claim_loss_type		   nvarchar(50)
	,@p_claim_request_code	   nvarchar(50) = null
	,@p_loss_date			   datetime		= null
	,@p_customer_report_date   datetime		= null
	,@p_finance_report_date	   datetime		= null
	,@p_result_report_date	   datetime		= NULL
	,@p_received_request_code  nvarchar(50)	= ''
	,@p_received_voucher_no	   nvarchar(50)	= NULL
	,@p_received_voucher_date  datetime		= NULL
	,@p_is_policy_terminate	   nvarchar(1)	 =''
	,@p_is_ex_gratia		   nvarchar(1)	= ''
	,@p_claim_reason_code	   nvarchar(50)
	--
	,@p_cre_date			   datetime
	,@p_cre_by				   nvarchar(15)
	,@p_cre_ip_address		   nvarchar(15)
	,@p_mod_date			   datetime
	,@p_mod_by				   nvarchar(15)
	,@p_mod_ip_address		   nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@system_date			datetime      = dbo.xfn_get_system_date()
			,@year					nvarchar(2)
			,@month					nvarchar(2) 
			,@policy_process_status nvarchar(10);

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @p_code output
												,@p_branch_code = @p_branch_code
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'AMSCLM'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'CLAIM_MAIN'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	if @p_is_policy_terminate = 'T'
		set @p_is_policy_terminate = '1' ;
	else
		set @p_is_policy_terminate = '0' ;


	if @p_is_ex_gratia = 'T'
		set @p_is_ex_gratia = '1' ;
	else
		set @p_is_ex_gratia = '0' ;

	begin try
		select @policy_process_status = isnull(policy_process_status, '')
		from dbo.insurance_policy_main
		where  code = @p_policy_code

		if (@policy_process_status <> '')
		begin
			set @msg = 'this policy already proceed in ' + upper(left(@policy_process_status, 1)) + lower(substring(@policy_process_status, 2, len(@policy_process_status))) ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@p_loss_date > dbo.xfn_get_system_date())
		begin
			set @msg = 'Loss Date must be less than System Date' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@p_customer_report_date > dbo.xfn_get_system_date())
		begin
			set @msg = 'Client Report Date must be less than System Date' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@p_customer_report_date < @p_loss_date)
		begin
			set @msg = 'Client Report Date must be greater than Loss Date' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@p_finance_report_date > dbo.xfn_get_system_date())
		begin
			set @msg = 'Report To Insurance Date must be less than System Date' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@p_finance_report_date < @p_customer_report_date)
		begin
			set @msg = 'Report To Insurance Date must be greater than Customer Report Date' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@p_result_report_date > dbo.xfn_get_system_date())
		begin
			set @msg = 'Result Report Date must be less than System Date' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@p_result_report_date < @p_finance_report_date)
		begin
			set @msg = 'Result Report Date must be greater than Report To Insurance Date' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@p_finance_report_date is not null)
		   and	(@p_claim_reff_external_no = '')
		begin
			set @msg = 'Please insert Claim Reff External No' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@p_finance_report_date is null)
		   and	(isnull(@p_claim_reff_external_no, '') <> '')
		begin
			set @msg = 'Please insert Customer Report Date' ;

			raiserror(@msg, 16, -1) ;
		end ;

		insert into claim_main
		(
			code
			,branch_code
			,branch_name
			,policy_code
			,claim_status
			,claim_progress_status
			,claim_amount
			,claim_remarks
			,claim_reff_external_no
			,claim_loss_type
			,claim_request_code
			,loss_date
			,customer_report_date
			,finance_report_date
			,result_report_date
			,received_request_code
			,received_voucher_no
			,received_voucher_date
			,is_policy_terminate
			,is_ex_gratia
			,claim_reason_code
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_code
			,@p_branch_code
			,@p_branch_name
			,@p_policy_code
			,'HOLD'
			,'HOLD'
			,@p_claim_amount
			,@p_claim_remarks
			,@p_claim_reff_external_no
			,@p_claim_loss_type
			,@p_claim_request_code
			,@p_loss_date
			,@p_customer_report_date
			,@p_finance_report_date
			,@p_result_report_date
			,@p_received_request_code
			,@p_received_voucher_no
			,@p_received_voucher_date
			,@p_is_policy_terminate
			,@p_is_ex_gratia
			,@p_claim_reason_code
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		exec dbo.xsp_claim_progress_insert @p_id						= 0       
											,@p_claim_code				= @p_code                 
											,@p_claim_progress_code		= 'ENTRY'       
											,@p_claim_progress_date		= @system_date
											,@p_claim_progress_remarks	= 'CLAIM'                 
											,@p_cre_date				= @p_cre_date		
											,@p_cre_by					= @p_cre_by			
											,@p_cre_ip_address			= @p_cre_ip_address
											,@p_mod_date				= @p_mod_date		
											,@p_mod_by					= @p_mod_by			
											,@p_mod_ip_address			= @p_mod_ip_address

		update dbo.insurance_policy_main
		set	   policy_process_status = 'CLAIM'
		where  code = @p_policy_code

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





