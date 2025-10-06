CREATE PROCEDURE dbo.xsp_insurance_policy_main_proceed
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg			   nvarchar(max)
			,@status		   nvarchar(20)
			,@maintenance_code nvarchar(50)
			,@asset_code	   nvarchar(50)
			,@claim_type	   nvarchar(50)
			,@last_meter	   int ;

	begin try
		select	@status = policy_payment_status
		from	dbo.insurance_policy_main
		where	code = @p_code ;

		if (@status = 'ON PROCESS')
		begin
			--update	dbo.insurance_policy_main
			--set		policy_payment_status	= 'APPROVE'
			--		--
			--		,mod_date				= @p_mod_date
			--		,mod_by					= @p_mod_by
			--		,mod_ip_address			= @p_mod_ip_address
			--where	code					= @p_code

			exec dbo.xsp_insurance_policy_main_post_payment @p_code				= @p_code
															,@p_cre_date		= @p_mod_date
															,@p_cre_by			= @p_mod_by
															,@p_cre_ip_address	= @p_mod_ip_address
															,@p_mod_date		= @p_mod_date
															,@p_mod_by			= @p_mod_by
															,@p_mod_ip_address	= @p_mod_ip_address
			

		end ;
		else
		begin
			set @msg = N'Data Already Proceed' ;

			raiserror(@msg, 16, -1) ;
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