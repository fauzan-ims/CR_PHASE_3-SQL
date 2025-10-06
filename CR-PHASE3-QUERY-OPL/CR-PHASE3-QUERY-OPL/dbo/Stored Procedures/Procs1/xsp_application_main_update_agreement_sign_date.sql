CREATE PROCEDURE dbo.xsp_application_main_update_agreement_sign_date
(
	@p_application_no			 nvarchar(50)
	,@p_agreement_sign_date		 datetime
	--
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max);

	begin try
		if (@p_agreement_sign_date > dbo.xfn_get_system_date())
		begin
			set @msg = 'Agreement Sign Date must be less or equal than System Date' ;

			raiserror(@msg, 16, -1) ;
		end

		update	application_main
		set		agreement_sign_date			= @p_agreement_sign_date
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	application_no				= @p_application_no ;
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

