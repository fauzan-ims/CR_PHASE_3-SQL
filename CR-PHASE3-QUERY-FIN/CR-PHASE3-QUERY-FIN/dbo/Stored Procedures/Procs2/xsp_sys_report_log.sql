CREATE PROCEDURE dbo.xsp_sys_report_log
(
	@p_report_code	nvarchar(250)
	,@p_employee	nvarchar(250)
	,@p_from_date	datetime
	,@p_to_date		datetime
)
as
begin

	declare @msg nvarchar(max) ;

	begin try
		
		select report_code			'Report Code'
			   ,report_name			'Report Name'
			   ,print_date			'Print Date'
			   ,print_by_code		'Employee Code'
			   ,print_by_name		'Employee Name'
			   ,print_by_ip			'Ip'
		from dbo.sys_report_log
		where report_code = @p_report_code
		and	  print_by_code = @p_employee
		and	  cast(print_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date)

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
end ;
