create PROCEDURE dbo.xsp_job_eod_update_system_date
as
begin
	declare @msg			 nvarchar(max)
			,@sysdate		 nvarchar(250)
			,@mod_date		 datetime	  = getdate()
			,@mod_by		 nvarchar(15) = 'EOD'
			,@mod_ip_address nvarchar(15) = 'SYSTEM' ;

	begin try
		begin
			select	@sysdate = value
			from	dbo.sys_global_param
			where	code = 'SYSDATE' ;

			--update sysdate
			update	dbo.sys_global_param
			set		value = convert(varchar, dateadd(day, 1, cast(@sysdate as date)), 23)
			where	code = 'SYSDATE' ;

			select	'IFINPROC'
					,@sysdate ;
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
