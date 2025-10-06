CREATE PROCEDURE dbo.xsp_termination_main_update
(
	@p_code							nvarchar(50)
	,@p_branch_code					nvarchar(50)
	,@p_branch_name					nvarchar(250)
	,@p_policy_code					nvarchar(50)
	,@p_termination_status			nvarchar(10)
	,@p_termination_date			datetime
	,@p_termination_amount			decimal(18, 2) = NULL
	,@p_termination_approved_amount decimal(18, 2) = 0
	,@p_termination_remarks			nvarchar(4000)
	,@p_termination_request_code    nvarchar(50)   = NULL
    ,@p_termination_reason_code	    nvarchar(50)
	--
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg			 nvarchar(max) 
			,@expired_date	 datetime
			,@effective_date DATETIME;

	begin try
		select @effective_date = ipm.policy_eff_date
			   ,@expired_date  = ipm.policy_exp_date
		from dbo.insurance_policy_main ipm
		where ipm.code = @p_policy_code

		--IF (@p_termination_date < dbo.xfn_get_system_date())
		--BEGIN
		--	set @msg = 'Date must be greater than System Date' ;
		--	raiserror(@msg, 16, -1) ;
		--END
   
		IF (@p_termination_date > @expired_date)
		BEGIN
			set @msg = 'Date must be less than Expired Date' ;
			raiserror(@msg, 16, -1) ;
		END

		IF (@p_termination_date < @effective_date)
		BEGIN
			set @msg = 'Date must be greater than Effective Date' ;
			raiserror(@msg, 16, -1) ;
		END

		SET @p_termination_amount = dbo.xfn_get_terminate(@p_policy_code, @p_termination_date)

		update	termination_main
		set		branch_code						= @p_branch_code
				,branch_name					= @p_branch_name
				,policy_code					= @p_policy_code
				,termination_status				= @p_termination_status
				,termination_date				= @p_termination_date
				,termination_amount				= @p_termination_amount
				,termination_approved_amount	= @p_termination_approved_amount
				,termination_remarks			= @p_termination_remarks
				,termination_request_code       = @p_termination_request_code
				,termination_reason_code        = @p_termination_reason_code
				--
				,mod_date						= @p_mod_date
				,mod_by							= @p_mod_by
				,mod_ip_address					= @p_mod_ip_address
		where	code							= @p_code ;
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

