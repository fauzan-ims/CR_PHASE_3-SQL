--SET QUOTED_IDENTIFIER ON|OFF
--SET ANSI_NULLS ON|OFF
--GO
CREATE PROCEDURE dbo.xsp_sys_job_tasklist_interface_in
    --@parameter_name as int
-- WITH ENCRYPTION, RECOMPILE, EXECUTE AS CALLER|SELF|OWNER| 'user_name'
as
    
	set xact_abort on --instructs SQL Server to rollback the entire transaction and abort the batch when a run-time error occurs

	declare	@msg			nvarchar(max)
			,@date_now		datetime
			,@last_id		bigint = 0
			,@last_id_job	bigint
			,@sp_name		nvarchar(250)
			,@code_sys_job	nvarchar(50)
			,@row_count		int

	begin try
		set nocount on;
		begin tran;

			set @date_now = getdate();
			
			begin /*region curson*/
				declare job_tasklist cursor local fast_forward read_only for

				select sp_name
					   ,last_id
					   ,code
				from dbo.sys_job_tasklist
				where type = 'IN'
				and is_active = '1'
				order by order_no
		
				open job_tasklist
		
				fetch next from job_tasklist into 
				@sp_name
				,@last_id_job
				,@code_sys_job
		
				while @@fetch_status = 0
				begin
					set @last_id = 0;
					set @row_count = 0;

		    
					exec @sp_name @last_id_job,  @last_id output, @row_count output

					update dbo.sys_job_tasklist 
					set last_id = @last_id 
					where code = @code_sys_job

					begin /*insert into dbo.sys_job_tasklist_log*/
					    exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code = @code_sys_job
					                                           , @p_status = N'Success'
					                                           , @p_start_date = @date_now
					                                           , @p_end_date = @date_now
					                                           , @p_log_description = N''
					                                           , @p_run_by = N'job'
					                                           , @p_from_id = 0
					                                           , @p_to_id = 0
					                                           , @p_number_of_rows = @row_count
					                                           , @p_cre_date = @date_now
					                                           , @p_cre_by = N'job'
					                                           , @p_cre_ip_address = N'127.0.0.1'
					                                           , @p_mod_date = @date_now
					                                           , @p_mod_by = N'job'
					                                           , @p_mod_ip_address = N'127.0.0.1'
					    
					end
					
		
					fetch next from job_tasklist into 
					@sp_name
					,@last_id_job
					,@code_sys_job
				end
		
				close job_tasklist
				deallocate job_tasklist
			end /*end region cursor*/

		commit tran;
		set nocount off;
	end try
	begin catch
		if (LEN(@msg) <> 0)  
		begin
			set @msg = 'V' + ';' + @msg;
		end
        else
		begin
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + ERROR_MESSAGE();
		end;

		raiserror(@msg, 16, -1) ;
		return ;  
	end catch;

