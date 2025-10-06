create procedure [dbo].[xsp_insurance_return_to_hold]
(
	@p_code			   nvarchar(50)
	,@p_return_reason  nvarchar(4000)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if exists
		(
			select	1
			from	dbo.insurance_policy_main
			where	code					  = @p_code
					and policy_payment_status <> 'ON CHECK'
		)
		begin
			set @msg = N'Error data already proceed' ;

			raiserror(@msg, 16, 1) ;
		end ;
		else
		begin
			update	dbo.insurance_policy_main
			set		policy_payment_status	= 'HOLD'
					,return_reason			= @p_return_reason
					--
					,mod_by					= @p_mod_by
					,mod_date				= @p_mod_date
					,mod_ip_address			= @p_mod_ip_address
			where	code = @p_code ;
		end ;
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
