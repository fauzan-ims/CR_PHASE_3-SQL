CREATE procedure dbo.xsp_maintenance_fin_interface_agreement_obligation_payment
as
declare @msg			 nvarchar(max)
		,@is_active		 nvarchar(1)
		,@mod_date		 datetime	  = getdate()
		,@mod_by		 nvarchar(15) = 'job'
		,@mod_ip_address nvarchar(15) = '127.0.0.1' ;

begin try
	/*	
		select tabel fin_interface_agreement_obligation_payment  uptae kurang dari 7 hari
		sp akan di panggil job , sehingga output nya masuk ke textfile	
	*/
	declare @date01 datetime
			,@path	nvarchar(50) ;

	set @date01 = dateadd(day, -7, getdate()) ;

	select	@path = value
	from	dbo.sys_global_param
	where	code = 'IMGMTN' ;

	begin
		select	*
		from	dbo.FIN_INTERFACE_AGREEMENT_OBLIGATION_PAYMENT
		where	CRE_DATE < @date01 ;

		update	MSDB.dbo.sysjobsteps
		set		output_file_name = @path + convert(varchar(50), format(getdate(), 'yyyy_MM_dd')) + '_IFINFIN_MAINTENANCE_FIN_INTERFACE_AGREEMENT_OBLIGATION_PAYMENT.TXT'
		where	step_name = 'IFINFIN_MAINTENANCE_FIN_INTERFACE_AGREEMENT_OBLIGATION_PAYMENT' ;
	end ;

	begin
		delete dbo.FIN_INTERFACE_AGREEMENT_OBLIGATION_PAYMENT
		where	CRE_DATE < @date01 ;
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
