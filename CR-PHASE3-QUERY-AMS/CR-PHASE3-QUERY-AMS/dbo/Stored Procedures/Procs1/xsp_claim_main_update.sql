CREATE procedure [dbo].[xsp_claim_main_update]
(
	@p_code						nvarchar(50)
	,@p_branch_code				nvarchar(50)
	,@p_branch_name				nvarchar(250)
	,@p_policy_code				nvarchar(50)
	,@p_claim_status			nvarchar(10)
	,@p_claim_progress_status	nvarchar(10)
	,@p_claim_amount			decimal		= 0
	,@p_claim_remarks			nvarchar(4000)
	,@p_claim_reff_external_no	nvarchar(50)
	,@p_claim_loss_type			nvarchar(50)
	,@p_claim_request_code		nvarchar(50) = null	--'CR01' --sementara
	,@p_loss_date				datetime
	,@p_customer_report_date	datetime
	,@p_finance_report_date		datetime		= null
	,@p_result_report_date		datetime		= null
	,@p_received_request_code	nvarchar(50) = null
	,@p_received_voucher_no		nvarchar(50) = null
	,@p_received_voucher_date	datetime		= null
	,@p_is_policy_terminate		nvarchar(1)	= null
	,@p_is_ex_gratia			nvarchar(1)	= null
	,@p_claim_reason_code		nvarchar(50)
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_policy_terminate = 'T'
		set @p_is_policy_terminate = '1' ;
	else
		set @p_is_policy_terminate = '0' ;

	if @p_is_ex_gratia = 'T'
		set @p_is_ex_gratia = '1' ;
	else
		set @p_is_ex_gratia = '0' ;

	begin try
		if (@p_loss_date > dbo.xfn_get_system_date())
		begin
			set @msg = N'Loss Date must be less than System Date' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@p_customer_report_date > dbo.xfn_get_system_date())
		begin
			set @msg = N'Customer Report Date must be less than System Date' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@p_customer_report_date < @p_loss_date)
		begin
			set @msg = N'Customer Report Date must be greater than Loss Date' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@p_finance_report_date > dbo.xfn_get_system_date())
		begin
			set @msg = N'Finance Report Date must be less than System Date' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@p_finance_report_date < @p_customer_report_date)
		begin
			set @msg = N'Finance Report Date must be greater than Customer Report Date' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@p_result_report_date > dbo.xfn_get_system_date())
		begin
			set @msg = N'Result Report Date must be less than System Date' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@p_result_report_date < @p_finance_report_date)
		begin
			set @msg = N'Result Report Date must be greater than Finance Report Date' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@p_finance_report_date is not null)
		   and	(@p_claim_reff_external_no = '')
		begin
			set @msg = N'Please insert Claim Reff External No' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@p_finance_report_date is null)
		   and	(isnull(@p_claim_reff_external_no, '') <> '')
		begin
			set @msg = N'Please insert Customer Report Date' ;

			raiserror(@msg, 16, -1) ;
		end ;

		update	claim_main
		set		branch_code						= @p_branch_code
				,branch_name					= @p_branch_name
				,policy_code					= @p_policy_code
				,claim_status					= @p_claim_status
				,claim_progress_status			= @p_claim_progress_status
				,claim_amount					= @p_claim_amount
				,claim_remarks					= @p_claim_remarks
				,claim_reff_external_no			= @p_claim_reff_external_no
				,claim_loss_type				= @p_claim_loss_type
				,claim_request_code				= @p_claim_request_code
				,loss_date						= @p_loss_date
				,customer_report_date			= @p_customer_report_date
				,finance_report_date			= @p_finance_report_date
				,result_report_date				= @p_result_report_date
				,received_request_code			= @p_received_request_code
				,received_voucher_no			= @p_received_voucher_no
				,received_voucher_date			= @p_received_voucher_date
				,is_policy_terminate			= @p_is_policy_terminate
				,is_ex_gratia					= @p_is_ex_gratia
				,claim_reason_code				= @p_claim_reason_code
				--
				,mod_date						= @p_mod_date
				,mod_by							= @p_mod_by
				,mod_ip_address					= @p_mod_ip_address
		where	code = @p_code ;
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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
