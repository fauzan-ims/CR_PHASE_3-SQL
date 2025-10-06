--created by, Rian at /05/2023 

CREATE procedure xsp_application_survey_bank_update
(
	@p_id						bigint
	,@p_application_survey_code nvarchar(50)
	,@p_bank_code				nvarchar(50)
	,@p_bank_account_no			nvarchar(50)
	,@p_bank_account_name		nvarchar(250)
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare	@msg	nvarchar(max)
	begin try
		update	dbo.application_survey_bank
		set		bank_code			= @p_bank_code
				,bank_account_no	= @p_bank_account_no
				,bank_account_name	= @p_bank_account_name
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	application_survey_code	= @p_application_survey_code
		and		id						= @p_id
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
