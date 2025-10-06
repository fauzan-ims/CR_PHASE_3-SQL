CREATE PROCEDURE dbo.xsp_eod_job
as
begin
    
	declare @msg						nvarchar(max)
			,@sys_date					datetime = dbo.xfn_get_system_date()
			,@cre_by					nvarchar(15)
			,@cre_date					datetime		
			,@cre_ip_address			nvarchar(15) = '10.0.9.205'	
			,@job_id					int
			,@date						datetime
			,@job_code					nvarchar(50)	
			,@job_desc					nvarchar(4000)	
			,@date_string				nvarchar(6)
			,@year						nvarchar(4)
			,@month						nvarchar(2)
			,@last_working_date			datetime
			,@err						int
			,@last_date_current_month	datetime

	begin try
		
		-- pending trx job for auto run eod process for weekend
		set @last_date_current_month = cast(dateadd(dd,-(day(dateadd(mm,1,@sys_date))),dateadd(mm,1,@sys_date)) as date)

		-- process depreciation =======================================================
		begin try
			select @last_working_date = dbo.xfn_get_last_working_date()
			if @sys_date = @last_working_date
			begin
				select	@job_code = 'DPRPR'
						,@job_desc= 'Depreciation Process'

				select	@cre_date		 = getdate()
						,@cre_by		 = @job_code
						,@date			 = getdate()
						,@sys_date		 = dbo.xfn_get_system_date()
						,@cre_ip_address = '10.0.9.205'
		
				set @date_string = convert(char(6),@sys_date,112)
				select	@year = left(@date_string,4)
						,@month = right(@date_string,2)

				exec ifinbam.dbo.xsp_sys_job_log_insert @p_id					= @job_id output
														 ,@p_job_code			= @job_code
														 ,@p_job_description	= @job_desc
														 ,@p_status				= 'NEW'
														 ,@p_start_date			= @date
														 ,@p_end_date			= null
														 ,@p_failed_remark		= ''
														 ,@p_failed_data_id		= 0
														 ,@p_cre_date			= @cre_date
														 ,@p_cre_by				= @cre_by
														 ,@p_cre_ip_address		= @cre_ip_address
														 ,@p_mod_date			= @cre_date
														 ,@p_mod_by				= @cre_by
														 ,@p_mod_ip_address		= @cre_ip_address		

				exec dbo.xsp_asset_depreciation_generate @p_year				= @year
														,@p_month				= @month
														,@p_company_code		= 'WOM'
														 ,@p_cre_date			= @cre_date
														 ,@p_cre_by				= @cre_by
														 ,@p_cre_ip_address		= @cre_ip_address
														 ,@p_mod_date			= @cre_date
														 ,@p_mod_by				= @cre_by
														 ,@p_mod_ip_address		= @cre_ip_address
			
		
				set	@date = getdate()
				exec ifinbam.dbo.xsp_sys_job_log_update @p_id				 = @job_id
														,@p_end_date		 = @date
														,@p_mod_date		 = @date		
														,@p_mod_by			 = @cre_by	
														,@p_mod_ip_address	 = @cre_ip_address
			end
		end try
		begin catch

			set @err = @@error ;

			if (@err = 2627)
			begin
				set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
			end ;
			else if (@err = 547)
			begin
				set @msg = dbo.xfn_get_msg_err_code_already_used() ;
			end ;

			if (len(@msg) <> 0)
			begin
				set @msg = 'V' + ';' + @msg ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;

			set @msg = isnull(@msg,'')
			exec ifinbam.dbo.xsp_sys_job_log_update_failed_info @p_id				 = @job_id
																,@p_end_date		 = @date
																,@p_failed_remark	 = @msg
																,@p_failed_data_id	 = 0
																,@p_mod_date		 = @date		
																,@p_mod_by			 = @cre_by	
																,@p_mod_ip_address	 = @cre_ip_address


			--raiserror(@msg, 16, -1) ;
			--return ;
		end catch ;
		-- process depreciation =======================================================
		
		-- process jurnal depreciation =======================================================
		begin try
			select @last_working_date = dbo.xfn_get_last_working_date()
			if @sys_date = @last_working_date
			begin
				select	@job_code = 'CRDPR'
						,@job_desc= 'Create Journal Depreciation'

				select	@cre_date		 = getdate()
						,@cre_by		 = @job_code
						,@date			 = getdate()
						,@sys_date		 = dbo.xfn_get_system_date()
						,@cre_ip_address = '10.0.9.205'
		
				set @date_string = convert(char(6),@sys_date,112)
				select	@year = left(@date_string,4)
						,@month = right(@date_string,2)

				exec ifinbam.dbo.xsp_sys_job_log_insert @p_id					= @job_id output
														 ,@p_job_code			= @job_code
														 ,@p_job_description	= @job_desc
														 ,@p_status				= 'NEW'
														 ,@p_start_date			= @date
														 ,@p_end_date			= null
														 ,@p_failed_remark		= ''
														 ,@p_failed_data_id		= 0
														 ,@p_cre_date			= @cre_date
														 ,@p_cre_by				= @cre_by
														 ,@p_cre_ip_address		= @cre_ip_address
														 ,@p_mod_date			= @cre_date
														 ,@p_mod_by				= @cre_by
														 ,@p_mod_ip_address		= @cre_ip_address		

				exec dbo.xsp_asset_depreciation_post @p_company_code	= 'WOM'
													,@p_month			= @month
													,@p_year			= @year
													,@p_mod_date		= @cre_date
													,@p_mod_by			= @cre_by
													,@p_mod_ip_address	= @cre_ip_address
				
				
				set	@date = getdate()
				exec ifinbam.dbo.xsp_sys_job_log_update @p_id				 = @job_id
														,@p_end_date		 = @date
														,@p_mod_date		 = @date		
														,@p_mod_by			 = @cre_by	
														,@p_mod_ip_address	 = @cre_ip_address
			end
		end try
		begin catch

			set @err = @@error ;

			if (@err = 2627)
			begin
				set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
			end ;
			else if (@err = 547)
			begin
				set @msg = dbo.xfn_get_msg_err_code_already_used() ;
			end ;

			if (len(@msg) <> 0)
			begin
				set @msg = 'V' + ';' + @msg ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;

			set @msg = isnull(@msg,'')
			exec ifinbam.dbo.xsp_sys_job_log_update_failed_info @p_id				 = @job_id
																,@p_end_date		 = @date
																,@p_failed_remark	 = @msg
																,@p_failed_data_id	 = 0
																,@p_mod_date		 = @date		
																,@p_mod_by			 = @cre_by	
																,@p_mod_ip_address	 = @cre_ip_address


			--raiserror(@msg, 16, -1) ;
			--return ;
		end catch ;
		-- process jurnal depreciation =======================================================
		
		-- update system date =======================================================
		begin try
		
			select	@job_code = 'SYSDT'
					,@job_desc= 'Update System Date'

			select	@cre_date		 = getdate()
					,@cre_by		 = @job_code
					,@cre_ip_address = '10.0.9.205'
					,@date			 = getdate()

			exec ifinbam.dbo.xsp_sys_job_log_insert @p_id					= @job_id output
													 ,@p_job_code			= @job_code
													 ,@p_job_description	= @job_desc
													 ,@p_status				= 'NEW'
													 ,@p_start_date			= @date
													 ,@p_end_date			= null
													 ,@p_failed_remark		= ''
													 ,@p_failed_data_id		= 0
													 ,@p_cre_date			= @cre_date
													 ,@p_cre_by				= @cre_by
													 ,@p_cre_ip_address		= @cre_ip_address
													 ,@p_mod_date			= @cre_date
													 ,@p_mod_by				= @cre_by
													 ,@p_mod_ip_address		= @cre_ip_address		

			exec dbo.xsp_job_eod_update_system_date
			exec ifinbam.dbo.xsp_job_eod_update_system_date
		
			set	@date = getdate()
			exec ifinbam.dbo.xsp_sys_job_log_update @p_id				 = @job_id
													,@p_end_date		 = @date
													,@p_mod_date		 = @date		
													,@p_mod_by			 = @cre_by	
													,@p_mod_ip_address	 = @cre_ip_address	
		
		end try
		begin catch

			set @err = @@error ;

			if (@err = 2627)
			begin
				set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
			end ;
			else if (@err = 547)
			begin
				set @msg = dbo.xfn_get_msg_err_code_already_used() ;
			end ;

			if (len(@msg) <> 0)
			begin
				set @msg = 'V' + ';' + @msg ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;

			set @msg = isnull(@msg,'')
			exec ifinbam.dbo.xsp_sys_job_log_update_failed_info @p_id				 = @job_id
																,@p_end_date		 = @date
																,@p_failed_remark	 = @msg
																,@p_failed_data_id	 = 0
																,@p_mod_date		 = @date		
																,@p_mod_by			 = @cre_by	
																,@p_mod_ip_address	 = @cre_ip_address


			--raiserror(@msg, 16, -1) ;
			--return ;
		end catch ;
		-- update system date =======================================================
	
		-- push reminder data maintenance =======================================================
		begin try
			select	@job_code = 'CRRMT'
					,@job_desc= 'Create Reminder Data Maintenance'
					
			select	@cre_date		 = getdate()
					,@cre_by		 = @job_code
					,@date			 = getdate()
					,@sys_date		 = dbo.xfn_get_system_date()

			exec ifinbam.dbo.xsp_sys_job_log_insert @p_id					= @job_id output
													 ,@p_job_code			= @job_code
													 ,@p_job_description	= @job_desc
													 ,@p_status				= 'NEW'
													 ,@p_start_date			= @date
													 ,@p_end_date			= null
													 ,@p_failed_remark		= ''
													 ,@p_failed_data_id		= 0
													 ,@p_cre_date			= @cre_date
													 ,@p_cre_by				= @cre_by
													 ,@p_cre_ip_address		= @cre_ip_address
													 ,@p_mod_date			= @cre_date
													 ,@p_mod_by				= @cre_by
													 ,@p_mod_ip_address		= @cre_ip_address		

			exec dbo.xsp_reminder_maintenance @p_eod_date			= @sys_date
											,@p_cre_date			= @cre_date
											,@p_cre_by				= @cre_by
											,@p_cre_ip_address		= @cre_ip_address
											,@p_mod_date			= @cre_date
											,@p_mod_by				= @cre_by
											,@p_mod_ip_address		= @cre_ip_address	
		
		
			set	@date = getdate()
			exec ifinbam.dbo.xsp_sys_job_log_update @p_id				 = @job_id
													,@p_end_date		 = @date
													,@p_mod_date		 = @date		
													,@p_mod_by			 = @cre_by	
													,@p_mod_ip_address	 = @cre_ip_address
		end try
		begin catch
		
			set @err = @@error ;

			if (@err = 2627)
			begin
				set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
			end ;
			else if (@err = 547)
			begin
				set @msg = dbo.xfn_get_msg_err_code_already_used() ;
			end ;

			if (len(@msg) <> 0)
			begin
				set @msg = 'V' + ';' + @msg ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;

			set @msg = isnull(@msg,'')
			exec ifinbam.dbo.xsp_sys_job_log_update_failed_info @p_id				 = @job_id
																,@p_end_date		 = @date
																,@p_failed_remark	 = @msg
																,@p_failed_data_id	 = 0
																,@p_mod_date		 = @date		
																,@p_mod_by			 = @cre_by	
																,@p_mod_ip_address	 = @cre_ip_address


			--raiserror(@msg, 16, -1) ;
			--return ;
		end catch ;
		-- push reminder data maintenance =======================================================
	
		-- push reminder data opname =======================================================
		begin try
		
			select	@job_code = 'CRROP'
					,@job_desc= 'Create Reminder Data Opname'

			select	@cre_date		 = getdate()
					,@cre_by		 = @job_code
					,@date			 = getdate()
					,@sys_date		 = dbo.xfn_get_system_date()

			exec ifinbam.dbo.xsp_sys_job_log_insert @p_id					= @job_id output
													 ,@p_job_code			= @job_code
													 ,@p_job_description	= @job_desc
													 ,@p_status				= 'NEW'
													 ,@p_start_date			= @date
													 ,@p_end_date			= null
													 ,@p_failed_remark		= ''
													 ,@p_failed_data_id		= 0
													 ,@p_cre_date			= @cre_date
													 ,@p_cre_by				= @cre_by
													 ,@p_cre_ip_address		= @cre_ip_address
													 ,@p_mod_date			= @cre_date
													 ,@p_mod_by				= @cre_by
													 ,@p_mod_ip_address		= @cre_ip_address		

			exec dbo.xsp_reminder_opname	@p_eod_date				= @sys_date
											,@p_cre_date			= @cre_date
											,@p_cre_by				= @cre_by
											,@p_cre_ip_address		= @cre_ip_address
											,@p_mod_date			= @cre_date
											,@p_mod_by				= @cre_by
											,@p_mod_ip_address		= @cre_ip_address	
		
		
			set	@date = getdate()
			exec ifinbam.dbo.xsp_sys_job_log_update @p_id				 = @job_id
													,@p_end_date		 = @date
													,@p_mod_date		 = @date		
													,@p_mod_by			 = @cre_by	
													,@p_mod_ip_address	 = @cre_ip_address
		end try
		begin catch

			set @err = @@error ;

			if (@err = 2627)
			begin
				set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
			end ;
			else if (@err = 547)
			begin
				set @msg = dbo.xfn_get_msg_err_code_already_used() ;
			end ;

			if (len(@msg) <> 0)
			begin
				set @msg = 'V' + ';' + @msg ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;

			set @msg = isnull(@msg,'')
			exec ifinbam.dbo.xsp_sys_job_log_update_failed_info @p_id				 = @job_id
																,@p_end_date		 = @date
																,@p_failed_remark	 = @msg
																,@p_failed_data_id	 = 0
																,@p_mod_date		 = @date		
																,@p_mod_by			 = @cre_by	
																,@p_mod_ip_address	 = @cre_ip_address


			--raiserror(@msg, 16, -1) ;
			--return ;
		end catch ;
		-- push reminder data opname =======================================================
		
		-- push archive data reject transaction =======================================================
		begin try
		
			select	@job_code = 'ARCDT'
					,@job_desc= 'Archive Data Reject Transaction'

			select	@cre_date		 = getdate()
					,@cre_by		 = @job_code
					,@date			 = getdate()
					,@sys_date		 = dbo.xfn_get_system_date()

			exec ifinbam.dbo.xsp_sys_job_log_insert @p_id					= @job_id output
													 ,@p_job_code			= @job_code
													 ,@p_job_description	= @job_desc
													 ,@p_status				= 'NEW'
													 ,@p_start_date			= @date
													 ,@p_end_date			= null
													 ,@p_failed_remark		= ''
													 ,@p_failed_data_id		= 0
													 ,@p_cre_date			= @cre_date
													 ,@p_cre_by				= @cre_by
													 ,@p_cre_ip_address		= @cre_ip_address
													 ,@p_mod_date			= @cre_date
													 ,@p_mod_by				= @cre_by
													 ,@p_mod_ip_address		= @cre_ip_address		

			exec dbo.xsp_archive_data_reject_transaction 
				
			set	@date = getdate()
			exec ifinbam.dbo.xsp_sys_job_log_update @p_id				 = @job_id
													,@p_end_date		 = @date
													,@p_mod_date		 = @date		
													,@p_mod_by			 = @cre_by	
													,@p_mod_ip_address	 = @cre_ip_address
		end try
		begin catch

			set @err = @@error ;

			if (@err = 2627)
			begin
				set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
			end ;
			else if (@err = 547)
			begin
				set @msg = dbo.xfn_get_msg_err_code_already_used() ;
			end ;

			if (len(@msg) <> 0)
			begin
				set @msg = 'V' + ';' + @msg ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;

			set @msg = isnull(@msg,'')
			exec ifinbam.dbo.xsp_sys_job_log_update_failed_info @p_id				 = @job_id
																,@p_end_date		 = @date
																,@p_failed_remark	 = @msg
																,@p_failed_data_id	 = 0
																,@p_mod_date		 = @date		
																,@p_mod_by			 = @cre_by	
																,@p_mod_ip_address	 = @cre_ip_address


			--raiserror(@msg, 16, -1) ;
			--return ;
		end catch ;
		-- push reminder data =======================================================
	
		-- end of year aset ending balance =======================================================
		begin try
		
			select	@job_code = 'EOYAS'
					,@job_desc= 'End of Year Aset Ending Balance Process'

			select	@cre_date		 = getdate()
					,@cre_by		 = @job_code
					,@date			 = getdate()
					,@sys_date		 = dbo.xfn_get_system_date()
			
			if right(convert(char(8),@sys_date,112),4) = '0101'
			begin
				exec ifinbam.dbo.xsp_sys_job_log_insert @p_id					= @job_id output
														 ,@p_job_code			= @job_code
														 ,@p_job_description	= @job_desc
														 ,@p_status				= 'NEW'
														 ,@p_start_date			= @date
														 ,@p_end_date			= null
														 ,@p_failed_remark		= ''
														 ,@p_failed_data_id		= 0
														 ,@p_cre_date			= @cre_date
														 ,@p_cre_by				= @cre_by
														 ,@p_cre_ip_address		= @cre_ip_address
														 ,@p_mod_date			= @cre_date
														 ,@p_mod_by				= @cre_by
														 ,@p_mod_ip_address		= @cre_ip_address		

				exec dbo.xsp_eoy_asset_process
				
				set	@date = getdate()
				exec ifinbam.dbo.xsp_sys_job_log_update @p_id				 = @job_id
														,@p_end_date		 = @date
														,@p_mod_date		 = @date		
														,@p_mod_by			 = @cre_by	
														,@p_mod_ip_address	 = @cre_ip_address
			end
		end try
		begin catch

			set @err = @@error ;

			if (@err = 2627)
			begin
				set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
			end ;
			else if (@err = 547)
			begin
				set @msg = dbo.xfn_get_msg_err_code_already_used() ;
			end ;

			if (len(@msg) <> 0)
			begin
				set @msg = 'V' + ';' + @msg ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;

			set @msg = isnull(@msg,'')
			exec ifinbam.dbo.xsp_sys_job_log_update_failed_info @p_id				 = @job_id
																,@p_end_date		 = @date
																,@p_failed_remark	 = @msg
																,@p_failed_data_id	 = 0
																,@p_mod_date		 = @date		
																,@p_mod_by			 = @cre_by	
																,@p_mod_ip_address	 = @cre_ip_address


			--raiserror(@msg, 16, -1) ;
			--return ;
		end catch ;
		-- end of year aset ending balance =======================================================
		

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
end
