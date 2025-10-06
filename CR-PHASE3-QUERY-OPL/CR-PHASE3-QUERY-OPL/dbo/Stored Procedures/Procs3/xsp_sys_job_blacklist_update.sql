CREATE PROCEDURE dbo.xsp_sys_job_blacklist_update
(
	@p_code			   nvarchar(50)
	,@p_status		   nvarchar(10)
	,@p_source		   nvarchar(250)
	,@p_job_code	   nvarchar(50)
	,@p_entry_date	   datetime
	,@p_entry_reason   nvarchar(4000)
	,@p_exit_date	   datetime
	,@p_exit_reason	   nvarchar(4000)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	sys_job_blacklist
		set		status			= @p_status
				,source			= @p_source
				,job_code		= @p_job_code
				,entry_date		= @p_entry_date
				,entry_reason	= @p_entry_reason
				,exit_date		= @p_exit_date
				,exit_reason	= @p_exit_reason
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	code			= @p_code ;
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
