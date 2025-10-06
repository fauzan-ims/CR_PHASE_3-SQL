CREATE PROCEDURE dbo.xsp_job_eod_update_system_date
as
begin

	declare @msg								nvarchar(max)  
			,@sysdate							nvarchar(250)
            ,@mod_date							datetime = getdate()
			,@mod_by							nvarchar(15) ='EOD'
			,@mod_ip_address					nvarchar(15) ='SYSTEM'


	begin try
		begin			
			select @sysdate = value
			from dbo.sys_global_param
			where code = 'SYSDATE'

			--update sysdate
			update	dbo.sys_global_param
			set		value = convert(varchar, dateadd(day, 1, cast(@sysdate as date)), 23)
			where	code = 'SYSDATE'
			
		end
	end try
	begin catch
		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			set @msg = 'E;There is an error.' + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
	
end
	

