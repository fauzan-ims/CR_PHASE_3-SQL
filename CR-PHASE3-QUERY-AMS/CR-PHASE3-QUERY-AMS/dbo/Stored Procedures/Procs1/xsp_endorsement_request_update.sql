CREATE PROCEDURE dbo.xsp_endorsement_request_update
(
	@p_code						   nvarchar(50)
	,@p_branch_code				   nvarchar(50)
	,@p_branch_name				   nvarchar(250)
	,@p_policy_code				   nvarchar(50)
	,@p_endorsement_request_status nvarchar(10)
	,@p_endorsement_request_date   datetime
	,@p_endorsement_request_type   nvarchar(10)
	,@p_endorsement_code		   nvarchar(50)
	,@p_request_reff_no			   nvarchar(50)
	,@p_request_reff_name		   nvarchar(250)
	--
	,@p_mod_date				   datetime
	,@p_mod_by					   nvarchar(15)
	,@p_mod_ip_address			   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	endorsement_request
		set		branch_code					= @p_branch_code
				,branch_name				= @p_branch_name
				,policy_code				= @p_policy_code
				,endorsement_request_status = @p_endorsement_request_status
				,endorsement_request_date	= @p_endorsement_request_date
				,endorsement_request_type	= @p_endorsement_request_type
				,endorsement_code			= @p_endorsement_code
				,request_reff_no			= @p_request_reff_no
				,request_reff_name			= @p_request_reff_name
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	code						= @p_code ;
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

