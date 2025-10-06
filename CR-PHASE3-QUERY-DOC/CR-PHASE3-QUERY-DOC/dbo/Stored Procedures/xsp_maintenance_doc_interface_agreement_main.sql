CREATE PROCEDURE dbo.xsp_maintenance_doc_interface_agreement_main
as
declare @msg			 nvarchar(max)
		,@is_active		 nvarchar(1)
		,@mod_date		 datetime	  = getdate()
		,@mod_by		 nvarchar(15) = 'job'
		,@mod_ip_address nvarchar(15) = '127.0.0.1' ;

begin try
	/*	
		select tabel doc_interface_agreement_main  uptae kurang dari 7 hari
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
		from	dbo.doc_interface_agreement_main
		where	CRE_DATE < @date01 ;

		update	MSDB.dbo.sysjobsteps
		set		output_file_name = @path + convert(varchar(50), format(getdate(), 'yyyy_MM_dd')) + '_IFINDOC_MAINTENANCE_DOC_INTERFACE_AGREEMENT_MAIN.TXT'
		where	step_name = 'IFINDOC_MAINTENANCE_DOC_INTERFACE_AGREEMENT_MAIN' ;
	end ;

	begin
		delete dbo.doc_interface_agreement_main
		where	CRE_DATE < @date01 ;
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
