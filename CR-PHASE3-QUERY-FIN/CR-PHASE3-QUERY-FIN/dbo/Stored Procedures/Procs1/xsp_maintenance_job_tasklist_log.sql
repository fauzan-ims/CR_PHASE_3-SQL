create PROCEDURE dbo.xsp_maintenance_job_tasklist_log
as
declare @msg			 nvarchar(max)
		,@is_active		 nvarchar(1)
		,@mod_date		 datetime	  = getdate()
		,@mod_by		 nvarchar(15) = 'job'
		,@mod_ip_address nvarchar(15) = '127.0.0.1' ;

begin try
	/*	
		select tabel log kurang dari hari ini
		sp akan di panggil job , sehingga output nya masuk ke textfile	
	*/
	begin
		select	*
		from	dbo.sys_job_tasklist_log
		where	cre_date < cast(getdate() as date) ;
	end ;

	update	MSDB.dbo.sysjobsteps
	set		output_file_name = 'F:\File Share\' + convert(varchar(50), format(getdate(), 'yyyy_MM_dd')) + '_IFINFIN_MAINTENANCE_JOB_TASKLIST.TXT'
	where	step_name = 'IFINFIN_MAINTENANCE_JOB_TASKLIST_LOG' ;

	begin
		delete dbo.SYS_JOB_TASKLIST_LOG
		where	CRE_DATE < cast(getdate() as date) ;
	end ;
end try
begin catch
	if (len(@msg) <> 0)
	begin
		set @msg = 'V' + ';' + @msg ;
	end ;
	else
	begin
		set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
	end ;

	raiserror(@msg, 16, -1) ;

	return ;
end catch ;
