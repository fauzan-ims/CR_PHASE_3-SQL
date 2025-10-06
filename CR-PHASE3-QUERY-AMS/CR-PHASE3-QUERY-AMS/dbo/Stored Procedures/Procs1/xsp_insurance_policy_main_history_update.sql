CREATE PROCEDURE dbo.xsp_insurance_policy_main_history_update
(
	@p_id				bigint
	,@p_policy_code		nvarchar(50)
	,@p_history_date	datetime
	,@p_history_type	nvarchar(50)
	,@p_policy_status	nvarchar(20)
	,@p_history_remarks nvarchar(4000)
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	insurance_policy_main_history
		set		policy_code			= @p_policy_code
				,history_date		= @p_history_date
				,history_type		= @p_history_type
				,policy_status		= @p_policy_status
				,history_remarks	= @p_history_remarks
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	id					= @p_id ;
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

