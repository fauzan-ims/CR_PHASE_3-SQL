CREATE PROCEDURE dbo.xsp_sys_eod_task_list_log_update
(
	@p_id			   int
	,@p_eod_code	   nvarchar(50)
	,@p_eod_date	   datetime
	,@p_start_time	   datetime
	,@p_end_time	   datetime
	,@p_status		   nvarchar(10)
	,@p_reason		   nvarchar(4000)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	sys_eod_task_list_log
		set		eod_code		= @p_eod_code
				,eod_date		= @p_eod_date
				,start_time		= @p_start_time
				,end_time		= @p_end_time
				,status			= @p_status
				,reason			= @p_reason
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	id				= @p_id ;
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
