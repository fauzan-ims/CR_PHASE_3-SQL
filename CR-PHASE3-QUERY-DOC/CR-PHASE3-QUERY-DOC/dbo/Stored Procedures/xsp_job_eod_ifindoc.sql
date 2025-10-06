
/*
exec xsp_job_eod_IFINDOC
*/ 
CREATE PROCEDURE dbo.[xsp_job_eod_ifindoc]
as
declare @msg				nvarchar(max)
		,@date_now			datetime
		,@start_date		datetime
		,@sysdate			nvarchar(250)
		,@eodrf				nvarchar(250)
		,@next_get_date_eod datetime
		,@last_id			bigint		 = 0
		,@last_id_job		bigint
		,@sp_name			nvarchar(250)
		,@code_sys_job		nvarchar(50)
		,@row_count			int = 1 ;

set nocount on ;

select	@eodrf = value
from	dbo.sys_global_param
where	code = 'EODRF' ;

select	@sysdate = value
from	dbo.sys_global_param
where	code = 'SYSDATE' ;

-- lakukan check jika global param  EODRF = 1, maka proses ini  jangan di jalankan
if @eodrf = 'NONE'
begin

	begin
		
		update	IFINSYS.dbo.sys_eod_module
		set		eod_status		= 'RUNNING'
		where	module_code		= 'IFINDOC' ;

		-- lakukan check sys_job_tasklist jika ada salah satu yang running, maka proses ini  jangan di jalankan
		if not exists
		(
			select	1
			from	dbo.sys_job_tasklist
			where	eod_status = 'RUNNING'
		)
		begin

			-- *lakukan update ke global param EODRF, set value = 1
			update	dbo.sys_global_param
			set		value = 'RUNNING'
			where	code = 'EODRF' ;

			begin /*region curson*/
				declare job_tasklist cursor local fast_forward read_only for
				select		sp_name
							,last_id
							,code
				from		dbo.sys_job_tasklist
				where		type		  = 'EOD'
							and is_active = '1'
							and eod_status in
				(
					'NONE', 'FAILED'
				) -- *tambahkan yang status nya ( NONE, FAILED)
				order by	order_no ;

				open job_tasklist ;

				fetch next from job_tasklist
				into @sp_name
					 ,@last_id_job
					 ,@code_sys_job ;

				while @@fetch_status = 0
				begin
					begin try
						begin transaction ;

						-- *update sys_job_tasklist EOD_STATUS = RUNNING
						update	dbo.sys_job_tasklist
						set		eod_status = 'RUNNING'
						where	code = @code_sys_job ;

						set @start_date = getdate() ;
						 
						exec @sp_name ;

						set @date_now = getdate() ;

						update	dbo.sys_job_tasklist
						set		last_id = @last_id
						where	code = @code_sys_job ;

						set @row_count += 1 ;

						begin /*insert into dbo.sys_job_tasklist_log*/
							exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code = @code_sys_job
																	 ,@p_status = 'Success'
																	 ,@p_start_date = @start_date
																	 ,@p_end_date = @date_now
																	 ,@p_log_description = ''
																	 ,@p_run_by = 'job'
																	 ,@p_from_id = 0
																	 ,@p_to_id = 0
																	 ,@p_number_of_rows = @row_count
																	 ,@p_cre_date = @date_now
																	 ,@p_cre_by = 'job'
																	 ,@p_cre_ip_address = '127.0.0.1'
																	 ,@p_mod_date = @date_now
																	 ,@p_mod_by = 'job'
																	 ,@p_mod_ip_address = '127.0.0.1' ;
						end ;

						-- *update sys_job_tasklist EOD_STATUS = DONE, EOD_REMARK = Success
						update	dbo.sys_job_tasklist
						set		eod_status = 'DONE'
								,eod_remark = 'SUCCESS'
						where	code = @code_sys_job ;

						commit transaction ;
					end try
					begin catch
						rollback transaction ;

						set @msg = error_message() ;
						set @date_now = getdate() ;

						-- *insert ke xsp_sys_job_tasklist_log_insert - gagal nya
						exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code = @code_sys_job
																 ,@p_status = 'FAILED'
																 ,@p_start_date = @start_date
																 ,@p_end_date = @date_now
																 ,@p_log_description = @msg
																 ,@p_run_by = 'job'
																 ,@p_from_id = 0
																 ,@p_to_id = 0
																 ,@p_number_of_rows = @row_count
																 ,@p_cre_date = @date_now
																 ,@p_cre_by = 'job'
																 ,@p_cre_ip_address = '127.0.0.1'
																 ,@p_mod_date = @date_now
																 ,@p_mod_by = 'job'
																 ,@p_mod_ip_address = '127.0.0.1' ;
																 
						-- *update sys_job_tasklist EOD_STATUS = FAILED, EOD_REMARK = ambil error exception nya
						update	dbo.sys_job_tasklist
						set		eod_status = 'FAILED'
								,eod_remark = @msg
						where	code = @code_sys_job ;

						-- *update update ke IFINSYS, set value = FAILED
						update	ifinsys.dbo.sys_eod_module
						set		eod_status = 'FAILED' 
						where	module_code = 'IFINDOC' ;

						-- *lakukan update ke global param EODRF, set value = FAILED
						update	dbo.sys_global_param
						set		value = 'NONE'
						where	code = 'EODRF' ;
					end catch ;

					fetch next from job_tasklist
					into @sp_name
						 ,@last_id_job
						 ,@code_sys_job ;
				end ;

				close job_tasklist ;
				deallocate job_tasklist ;
			end ; /*end region cursor*/
			
			if not exists(select 1 from dbo.sys_global_param where code = 'EODRF' and value = 'FAILED')
			begin

				-- *update update ke IFINSYS, set value = DONE
				update	ifinsys.dbo.sys_eod_module
				set		eod_status = 'DONE' 
				where	module_code = 'IFINDOC' ;

				--update EOD SUDAH SELESAI
				update	sys_job_tasklist
				set		eod_status = 'NONE'
				where	type		  = 'EOD'
						and is_active = '1' ;

				update	dbo.sys_global_param
				set		value = 'NONE'
				where	code = 'EODRF' ;

				exec IFINSYS.dbo.xsp_eod_update_job_schedule_time @p_parent_module_code = N'IFINDOC' ; -- nvarchar(50)
			end ;
		end ;
	end ;
end ;

set nocount off ;
