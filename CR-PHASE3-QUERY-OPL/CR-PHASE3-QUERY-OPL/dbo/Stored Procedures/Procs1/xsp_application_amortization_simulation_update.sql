CREATE PROCEDURE dbo.xsp_application_amortization_simulation_update
(
	@p_application_simulation_code	 nvarchar(50)
	,@p_installment_no				 int
	,@p_due_date					 datetime
	,@p_principal_amount			 decimal(18, 2)
	,@p_installment_amount			 decimal(18, 2)
	,@p_installment_principal_amount decimal(18, 2)
	,@p_installment_interest_amount	 decimal(18, 2)
	,@p_os_principal_amount			 decimal(18, 2)
	,@p_os_interest_amount			 decimal(18, 2)
	--
	,@p_mod_date					 datetime
	,@p_mod_by						 nvarchar(15)
	,@p_mod_ip_address				 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	application_amortization_simulation
		set		due_date						= @p_due_date
				,principal_amount				= @p_principal_amount
				,installment_amount				= @p_installment_amount
				,installment_principal_amount	= @p_installment_principal_amount
				,installment_interest_amount	= @p_installment_interest_amount
				,os_principal_amount			= @p_os_principal_amount
				,os_interest_amount				= @p_os_interest_amount
				--
				,mod_date						= @p_mod_date
				,mod_by							= @p_mod_by
				,mod_ip_address					= @p_mod_ip_address
		where	application_simulation_code		= @p_application_simulation_code
				and installment_no				= @p_installment_no ;
	end try
	Begin catch
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

