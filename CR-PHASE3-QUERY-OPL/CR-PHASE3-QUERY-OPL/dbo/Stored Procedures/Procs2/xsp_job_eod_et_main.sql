CREATE PROCEDURE dbo.xsp_job_eod_et_main
as
begin
	declare @msg			 nvarchar(max)
			,@sysdate		 nvarchar(250)
			,@et_exp_date	 datetime
			,@code			 nvarchar(50)
			,@agreement_no	 nvarchar(50)
			,@mod_date		 datetime	  = getdate()
			,@mod_by		 nvarchar(15) = 'EOD'
			,@mod_ip_address nvarchar(15) = 'SYSTEM' ;

	begin try
		begin
			select	@sysdate = value
			from	sys_global_param
			where	code = 'SYSDATE' ;

			declare cur_etmain cursor for
			select	code
					,cast(et_exp_date as date)
					,agreement_no
			from	dbo.et_main
			where	et_status in
			(
				'HOLD'
			) ;

			open cur_etmain ;

			fetch next from cur_etmain
			into @code
				 ,@et_exp_date
				 ,@agreement_no ;

			while @@fetch_status = 0
			begin
				if @et_exp_date < @sysdate
				begin
					update	dbo.et_main
					set		et_status = 'EXPIRED'
					where	code = @code ;

					update	dbo.opl_interface_approval_request
					set		request_status = 'CANCEL'
					where	reff_no			   = @code
							and request_status = 'HOLD' ;

					-- update lms status
					exec dbo.xsp_agreement_main_update_opl_status @p_agreement_no	= @agreement_no
																  ,@p_status		= N'' 
				end ;

				fetch next from cur_etmain
				into @code
					 ,@et_exp_date
					 ,@agreement_no ;
			end ;

			close cur_etmain ;
			deallocate cur_etmain ;
		end ;
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
end ;
