CREATE PROCEDURE dbo.xsp_client_kyc_update
(
	@p_client_code		 nvarchar(50)
	,@p_ao_remark		 nvarchar(100)	= ''
	,@p_ao_source_fund	 nvarchar(100)	= ''
	,@p_result_status	 nvarchar(20)	= null
	,@p_result_remark	 nvarchar(4000) = null
	,@p_kyc_officer_code nvarchar(50)	= null
	,@p_kyc_officer_name nvarchar(250)	= null
	--
	,@p_mod_date		 datetime
	,@p_mod_by			 nvarchar(15)
	,@p_mod_ip_address	 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	client_kyc
		set		ao_remark			= @p_ao_remark
				,ao_source_fund		= @p_ao_source_fund
				,result_status		= @p_result_status
				,result_remark		= @p_result_remark 
				,kyc_officer_code	= @p_kyc_officer_code
				,kyc_officer_name	= @p_kyc_officer_name
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	client_code			= @p_client_code ;
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

